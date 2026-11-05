"""Run: python -m unittest test_trip_features.py"""
import unittest
from main import PLACES, TripRequest, make_trips

class TripFeatureTests(unittest.TestCase):
    def test_visited_sites_are_excluded(self):
        req=TripRequest(latitude=28.0871, longitude=30.7618,
            budget_egp=2000, family_size=4, available_hours=6,
            period='morning', max_radius_km=60)
        first=make_trips(req)
        self.assertTrue(first['trips'])
        name=first['trips'][0]['stops'][0]['name']
        second=make_trips(req.model_copy(update={'excluded_places':[name]}))
        self.assertTrue(all(stop['name'] != name
                for trip in second['trips'] for stop in trip['stops']))
        self.assertEqual(second['request_context']['excluded_places'],[name])

    def test_budget_is_total_for_entire_group(self):
        req = TripRequest(latitude=28.0871, longitude=30.7618,
            budget_egp=5000, family_size=4, available_hours=6,
            period='morning', max_radius_km=60)
        results = make_trips(req)
        self.assertTrue(results['trips'])
        for trip in results['trips']:
            self.assertEqual(trip['group_budget_egp'], 5000)
            self.assertEqual(trip['family_size'], 4)
            self.assertLessEqual(trip['total_entry_cost_egp'], 5000)
            self.assertAlmostEqual(trip['total_entry_cost_egp'] + trip['remaining_budget_egp'], 5000)
            self.assertAlmostEqual(sum(stop['entry_cost_egp'] for stop in trip['stops']), trip['total_entry_cost_egp'])
            for stop in trip['stops']:
                self.assertAlmostEqual(stop['entry_cost_egp'], stop['entry_price_per_person_egp'] * 4)

    def test_free_and_unknown_booking(self):
        self.assertTrue(all(not p.booking for p in PLACES if p.adult_price == 0))
        self.assertTrue(all(p.booking is None or p.booking.startswith('https://') for p in PLACES))

    def test_international_ticket_prices(self):
        eg=make_trips(TripRequest(latitude=28.0871,longitude=30.7618,
            budget_egp=10000,family_size=2,available_hours=6,max_radius_km=60,
            visitor_type='egyptian'))
        foreign=make_trips(TripRequest(latitude=28.0871,longitude=30.7618,
            budget_egp=10000,family_size=2,available_hours=6,max_radius_km=60,
            visitor_type='international'))
        self.assertTrue(eg['trips'] and foreign['trips'])
        self.assertNotEqual(eg['trips'][0]['total_entry_cost_egp'],
                            foreign['trips'][0]['total_entry_cost_egp'])

if __name__ == '__main__': unittest.main()
