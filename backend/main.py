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
            link = (row.get('Official Booking Link') or '').strip()
            # Do not represent an instruction like 'search site name' as a direct booking link.
            if 'search site name' in link.lower():
                link = ''
            places.append(Place(
                name=row['Site Name'].strip(), governorate=row['Governorate'].strip(),
                city=row['City/Area'].strip(), lat=lat, lon=lon,
                adult_price=price, duration=duration, hours=row['Opening Hours'],
                windows=tuple(windows), kind=(row.get('Type') or '').strip(),
                suitability=family_suitability(row), booking=link or None
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
    start_time: str | None = None  # HH:MM 24-hour. Defaults: 09:00 / 18:00.
    max_radius_km: float = Field(default=DEFAULT_MAX_RADIUS_KM, gt=0, le=150)
    max_stops: int = Field(default=4, ge=1, le=6)
    number_of_trips: int = Field(default=3, ge=1, le=10)

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

    # Strictly keep places inside radius of the USER, not just nearby each other.
    candidates = [(p, haversine(req.latitude, req.longitude, p.lat, p.lon)) for p in PLACES]
    candidates = [(p, d) for p, d in candidates
                  if d <= req.max_radius_km and req.family_size * p.adult_price <= req.budget_egp]
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
                new_cost = cost + p.adult_price * req.family_size
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
                    'entry_cost_egp': round(p.adult_price * req.family_size, 2),
                    'opening_hours_source': p.hours, 'family_suitability_heuristic': p.suitability,
                    'booking_link': p.booking,
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
        'warnings': [
            'Prices in the dataset may be outdated; confirm before booking.',
            'Children are budgeted at the adult admission rate as a conservative estimate; child-specific rates are unavailable.',
            'Budget covers entrance tickets only, NOT transport, meals or guide fees.',
            'Travel times are rough straight-line-distance estimates, NOT road-routing or live traffic.',
            'Family suitability is a text-based heuristic, NOT verified child safety/accessibility.',
            'Opening hours are interpreted from the dataset and do NOT include holidays or date-specific changes.',
            'Places with unknown price, duration, hours, or coordinates are excluded.',
            'Routes use a limited beam search and are not guaranteed globally optimal.'
        ],
    }


app = FastAPI(title='Egypt Family Trip Planner', version='1.0')


@app.get('/health')
def health():
    return {'status': 'ok', 'eligible_places': len(PLACES)}


@app.post('/recommend')
def recommend(request: TripRequest):
    return make_trips(request)
