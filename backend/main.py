"""Explainable multi-stop Egyptian heritage trip planner. Run: uvicorn main:app --reload"""
from __future__ import annotations

import csv
import math
import re
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path
from typing import Literal

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from payments import router as payments_router
from booking_links import official_booking
from pydantic import BaseModel, Field, model_validator

DATA_PATH = Path(__file__).with_name('places.csv')
AVERAGE_SPEED_KMH = 22.0  # Rough urban assumption, not live roads data
TRANSFER_BUFFER_MIN = 10
DEFAULT_MAX_RADIUS_KM = 25.0
MAX_CANDIDATES = 35
BEAM_WIDTH = 80


def haversine(lat1, lon1, lat2, lon2):
    r = 6371.0088
    a1, a2 = math.radians(lat1), math.radians(lat2)
    dlat = a2 - a1
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2)**2 + math.cos(a1) * math.cos(a2) * math.sin(dlon / 2)**2
    return 2 * r * math.asin(min(1, math.sqrt(a)))


def transfer_minutes(km):
    return math.ceil(km / AVERAGE_SPEED_KMH * 60) + TRANSFER_BUFFER_MIN


def numeric_price(value):
    """Unknown or bundled entry is not zero; only explicit Free or numeric are safe."""
    s = str(value or '').strip()
    if re.fullmatch(r'(?i)free(?:\s*\(.*\))?', s):
        return 0.0
    if re.fullmatch(r'\d+(?:\.\d+)?', s):
        return float(s)
    return None


def duration_minutes(value):
    s = str(value or '').lower().strip()
    match = re.fullmatch(r'(\d+(?:\.\d+)?)(?:\s*-\s*(\d+(?:\.\d+)?))?\s*(hours?|hrs?|min(?:utes?)?)', s)
    if not match:
        return None
    hi = float(match.group(2) or match.group(1))
    return math.ceil(hi * (60 if match.group(3).startswith(('hour', 'hr')) else 1))


def minutes_clock(s):
    s = s.strip().upper()
    match = re.fullmatch(r'(\d{1,2}):(\d\d)\s*(AM|PM)?', s)
    if not match:
        return None
    hour, minute = int(match.group(1)), int(match.group(2))
    ampm = match.group(3)
    if minute >= 60 or (ampm and not 1 <= hour <= 12) or (not ampm and not 0 <= hour <= 23):
        return None
    if ampm:
        hour = (hour % 12) + (12 if ampm == 'PM' else 0)
    return hour * 60 + minute


def opening_windows(value):
    """Only confidently machine-readable schedules. No inference for daylight/varies."""
    s = str(value or '').strip()
    if s.lower().startswith('24 hours'):
        return [(0, 24 * 60)]
    windows = []
    # Each comma-separated window may be '9:00 AM - 2:00 PM' or '5:00-9:00 PM'.
    for part in s.split(','):
        match = re.fullmatch(r'\s*(\d{1,2}:\d\d)\s*(AM|PM)?\s*-\s*(\d{1,2}:\d\d)\s*(AM|PM)\s*', part, re.I)
        if not match:
            return []
        start, a1, end, a2 = match.groups()
        # Infer missing AM/PM on left when possible. 5:00-9:00 PM => PM.
        left = minutes_clock(start + (' ' + (a1 or a2)))
        right = minutes_clock(end + ' ' + a2)
        if left is None or right is None or right <= left:
            return []
        windows.append((left, right))
    return windows


def fits_opening(windows, start_minute, end_minute):
    return any(start_minute >= start and end_minute <= end for start, end in windows)


def family_suitability(row):
    """Heuristic, not a verified accessibility/safety or age suitability label."""
    t = f"{row['Type']} {row['Category']}".lower()
    if any(word in t for word in ('garden', 'aquarium', 'museum')):
        return 1.0
    if any(word in t for word in ('tomb', 'pyramid interior', 'remote', 'quarry', 'necropolis')):
        return 0.35
    return 0.65


@dataclass(frozen=True)
class Place:
    name: str
    governorate: str
    city: str
    lat: float
    lon: float
    adult_price: float
    foreign_price: float | None
    duration: int
    hours: str
    windows: tuple[tuple[int, int], ...]
    kind: str
    suitability: float
    booking: str | None


def load_places():
    places = []
    with DATA_PATH.open(encoding='utf-8-sig', newline='') as file:
        for row in csv.DictReader(file):
            try:
                lat = float(row['Latitude'])
                lon = float(row['Longitude'])
            except (ValueError, TypeError):
                continue
            if not (-90 <= lat <= 90 and -180 <= lon <= 180):
                continue
            price = numeric_price(row.get('Price - Egyptian Adult (EGP)'))
            duration = duration_minutes(row.get('Suggested Visit Duration'))
            windows = opening_windows(row.get('Opening Hours'))
            if price is None or duration is None or not windows:
                continue
            link = official_booking(row['Site Name'].strip(), price)
            places.append(Place(
                name=row['Site Name'].strip(), governorate=row['Governorate'].strip(),
                city=row['City/Area'].strip(), lat=lat, lon=lon,
                adult_price=price, foreign_price=numeric_price(row.get('Price - Foreigner Adult (EGP)')),
                duration=duration, hours=row['Opening Hours'],
                windows=tuple(windows), kind=(row.get('Type') or '').strip(),
                suitability=family_suitability(row), booking=link
            ))
    return places


PLACES = load_places()


class TripRequest(BaseModel):
    latitude: float = Field(ge=-90, le=90)
    longitude: float = Field(ge=-180, le=180)
    budget_egp: float = Field(ge=0)
    family_size: int = Field(ge=1, le=30)
    children_count: int = Field(default=0, ge=0)
    available_hours: float = Field(gt=0, le=16)
    period: Literal['morning', 'evening'] = 'morning'
    visitor_type: Literal['egyptian', 'international'] = 'egyptian'
    start_time: str | None = None  # HH:MM 24-hour. Defaults: 09:00 / 18:00.
    max_radius_km: float = Field(default=DEFAULT_MAX_RADIUS_KM, gt=0, le=150)
    max_stops: int = Field(default=4, ge=1, le=6)
    number_of_trips: int = Field(default=3, ge=1, le=10)
    excluded_places: list[str] = Field(default_factory=list, max_length=140)

    @model_validator(mode='after')
    def check(self):
        if self.children_count > self.family_size:
            raise ValueError('children_count cannot exceed family_size')
        if self.start_time is not None and not re.fullmatch(r'(?:[01]\d|2[0-3]):[0-5]\d', self.start_time):
            raise ValueError('start_time must be HH:MM (24-hour format)')
        return self


def fmt_clock(total_min):
    return f'{total_min // 60:02}:{total_min % 60:02}'


def make_trips(req: TripRequest):
    start = minutes_clock(req.start_time or ('09:00' if req.period == 'morning' else '18:00'))
    available_min = math.floor(req.available_hours * 60)
    if start + available_min > 24 * 60:
        raise HTTPException(status_code=422, detail='Trip end must be on the same calendar day')

    # Adult prices vary by visitor category. Currency remains EGP; foreign visitors
    # with missing foreign prices are excluded, not silently charged local prices.
    def visitor_price(place):
        return place.foreign_price if req.visitor_type == 'international' else place.adult_price

    # Strictly keep places inside radius of the USER, not just nearby each other.
    excluded = {name.strip().casefold() for name in req.excluded_places}
    candidates = [(p, haversine(req.latitude, req.longitude, p.lat, p.lon))
                  for p in PLACES if p.name.casefold() not in excluded]
    candidates = [(p, d) for p, d in candidates
                  if d <= req.max_radius_km and visitor_price(p) is not None
                  and req.family_size * visitor_price(p) <= req.budget_egp]
    candidates.sort(key=lambda item: item[1])
    candidates = candidates[:MAX_CANDIDATES]

    # Partial state: indices, elapsed minutes, admission EGP, cumulative distance, per-stop details.
    beam = [((), 0, 0.0, 0.0, [])]
    completed = []
    for depth in range(req.max_stops):
        next_beam = []
        for used, elapsed, cost, dist, stops in beam:
            for idx, (p, user_km) in enumerate(candidates):
                if idx in used:
                    continue
                if used:
                    prev = candidates[used[-1]][0]
                    km = haversine(prev.lat, prev.lon, p.lat, p.lon)
                else:
                    km = user_km
                travel = transfer_minutes(km)
                arrive = start + elapsed + travel
                leave = arrive + p.duration
                return_km = haversine(p.lat, p.lon, req.latitude, req.longitude)
                # Include return-to-origin travel in the total time and distance.
                return_min = transfer_minutes(return_km)
                new_cost = cost + visitor_price(p) * req.family_size
                if leave + return_min > start + available_min or new_cost > req.budget_egp:
                    continue
                if not fits_opening(p.windows, arrive, leave):
                    continue
                new_elapsed = leave - start
                new_stops = stops + [{
                    'name': p.name, 'governorate': p.governorate, 'city': p.city,
                    'type': p.kind, 'latitude': p.lat, 'longitude': p.lon,
                    'arrival_time': fmt_clock(arrive), 'departure_time': fmt_clock(leave),
                    'visit_minutes': p.duration, 'travel_from_previous_minutes': travel,
                    'distance_from_previous_km': round(km, 2),
                    'entry_price_per_person_egp': round(visitor_price(p), 2),
                    'entry_cost_egp': round(visitor_price(p) * req.family_size, 2),
                    'opening_hours_source': p.hours, 'family_suitability_heuristic': p.suitability,
                    'booking_link': p.booking,
                    'booking_available': bool(p.booking),
                    'entry_is_free': visitor_price(p) == 0,
                }]
                new_used = used + (idx,)
                new_dist = dist + km
                state = (new_used, new_elapsed, new_cost, new_dist, new_stops)
                next_beam.append(state)
                total_duration = new_elapsed + return_min
                mean_fit = sum(x['family_suitability_heuristic'] for x in new_stops) / len(new_stops)
                # Prioritize richer itineraries, with smaller distance and family penalties.
                score = 100 * len(new_stops) + (25 * mean_fit if req.children_count > 0 else 0) - 0.6 * (new_dist + return_km) - 0.025 * new_cost
                completed.append({
                    '_signature': frozenset(new_used), '_score': score,
                    'stops': new_stops,
                    'total_entry_cost_egp': round(new_cost, 2),
                    'group_budget_egp': round(req.budget_egp, 2),
                    'family_size': req.family_size,
                    'remaining_budget_egp': round(req.budget_egp - new_cost, 2),
                    'total_duration_minutes': total_duration,
                    'return_to_origin_minutes': return_min,
                    'estimated_total_distance_km': round(new_dist + return_km, 2),
                    'start_time': fmt_clock(start), 'estimated_return_time': fmt_clock(start + total_duration),
                })
        if not next_beam:
            break
        # Beam search controls combinatorial explosion; non-exhaustive route search.
        next_beam.sort(key=lambda s: (-len(s[0]), s[3], s[2]))
        beam = next_beam[:BEAM_WIDTH]

    completed.sort(key=lambda x: x['_score'], reverse=True)
    trips = []
    seen = set()
    for trip in completed:
        if trip['_signature'] in seen:
            continue
        seen.add(trip['_signature'])
        trip.pop('_signature')
        trip['score'] = round(trip.pop('_score'), 2)
        trips.append(trip)
        if len(trips) >= req.number_of_trips:
            break
    return {
        'trips': trips, 'matched_locations': len(candidates),
        'request_context': req.model_dump(),
        'warnings': [
            'Prices in the dataset may be outdated; confirm before booking.',
            'Ticket estimates use the selected Egyptian/international adult rate in EGP; actual concessions differ.',
            'Children are budgeted at the adult admission rate as a conservative estimate; child-specific rates are unavailable.',
            'The submitted budget is the TOTAL for the entire group, not a per-person budget.',
            'Budget covers entrance tickets only, NOT transport, meals or guide fees.',
            'Travel times are rough straight-line-distance estimates, NOT road-routing or live traffic.',
            'Family suitability is a text-based heuristic, NOT verified child safety/accessibility.',
            'Opening hours are interpreted from the dataset and do NOT include holidays or date-specific changes.',
            'Places with unknown price, duration, hours, or coordinates are excluded.',
            'Routes use a limited beam search and are not guaranteed globally optimal.',
            'Book Tickets links lead to the venue official portal. The app does not sell entrance tickets.'
        ],
    }


app = FastAPI(title='Egypt Family Trip Planner', version='1.0')
# Development localhost origin only; set explicit origins before deployment.
app.add_middleware(CORSMiddleware,
    allow_origin_regex=r'http://(localhost|127\.0\.0\.1):[0-9]+',
    allow_methods=['GET', 'POST'], allow_headers=['Content-Type'])
app.include_router(payments_router)


@app.get('/health')
def health():
    return {'status': 'ok', 'eligible_places': len(PLACES)}


@app.post('/recommend')
def recommend(request: TripRequest):
    return make_trips(request)


# Manual trip starting point. Never uses GPS or device location permissions.
# The returned point is an approximation based on dataset site coordinates.
# Precise addresses require a separate geocoding provider.
class LocationRequest(BaseModel):
    name: str = Field(min_length=2, max_length=100)


_AR_GOV = {
    'القاهرة':'Cairo', 'الجيزة':'Giza', 'الاسكندرية':'Alexandria', 'الإسكندرية':'Alexandria',
    'المنيا':'Minya', 'بني سويف':'Beni Suef', 'الفيوم':'Fayoum', 'أسيوط':'Assiut',
    'اسيوط':'Assiut', 'سوهاج':'Sohag', 'قنا':'Qena', 'الأقصر':'Luxor', 'اسوان':'Aswan',
    'أسوان':'Aswan', 'البحر الأحمر':'Red Sea', 'مطروح':'Matrouh', 'الوادي الجديد':'New Valley',
    'بورسعيد':'Port Said', 'دمياط':'Damietta', 'الإسماعيلية':'Ismailia', 'الاسماعيلية':'Ismailia',
    'السويس':'Suez', 'شمال سيناء':'North Sinai', 'جنوب سيناء':'South Sinai',
    'القليوبية':'Qalyubia', 'الدقهلية':'Dakahlia', 'الشرقية':'Sharqia',
    'الغربية':'Gharbia', 'المنوفية':'Monufia', 'كفر الشيخ':'Kafr El Sheikh',
    'البحيرة':'Beheira', 'ملوي':'Mallawi', 'مالوي':'Mallawi',
}


def _location_key(text: str) -> str:
    text = text.strip().casefold().replace('’', "'")
    return re.sub(r'[^\w\u0621-\u064a]+', '', text)


def resolve_manual_location(name: str):
    term = _AR_GOV.get(name.strip(), name.strip())
    term = {'Assiut':'Asyut', 'Assiout':'Asyut', 'Mallawi':'Minya', 'Malawi':'Minya', 'Qalyubia':'Cairo'}.get(term, term)
    key = _location_key(term)
    rows = []
    with DATA_PATH.open('r', encoding='utf-8-sig', newline='') as source:
        rows = list(csv.DictReader(source))
    # Prefer matching named city/area; fallback to governorate-level tourist-area centroid.
    for col in ('City/Area', 'Governorate'):
        matched = [row for row in rows if _location_key(row.get(col, '')) == key]
        valid = []
        for row in matched:
            try:
                lat, lon = float(row['Latitude']), float(row['Longitude'])
                if -90 <= lat <= 90 and -180 <= lon <= 180:
                    valid.append((lat, lon))
            except (TypeError, ValueError, KeyError):
                pass
        if valid:
            # Mean coordinates are an approximation, not user's exact location.
            return {'name': term, 'latitude': round(sum(x[0] for x in valid) / len(valid), 6),
                    'longitude': round(sum(x[1] for x in valid) / len(valid), 6),
                    'precision': 'approximate_city_area' if col == 'City/Area' else 'approximate_governorate',
                    'note': 'Approximate start point from landmark coordinates; not your current position.'}
    raise HTTPException(status_code=404, detail='Location not in our current dataset. Choose a listed governorate or city.')


@app.get('/locations/choices')
def location_choices():
    with DATA_PATH.open('r', encoding='utf-8-sig', newline='') as source:
        rows = list(csv.DictReader(source))
    return {'governorates': sorted({r['Governorate'].strip() for r in rows if r.get('Governorate')}),
            'cities': sorted({r['City/Area'].strip() for r in rows if r.get('City/Area')})}


@app.post('/locations/resolve')
def manual_location(body: LocationRequest):
    return resolve_manual_location(body.name)
