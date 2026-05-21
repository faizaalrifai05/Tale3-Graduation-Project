import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class OptimizedRoute {
  final List<LatLng> polylinePoints;
  final List<LatLng> orderedPickups;
  final List<int> waypointOrder;

  const OptimizedRoute({
    required this.polylinePoints,
    required this.orderedPickups,
    required this.waypointOrder,
  });
}

class MapsService {
  // Pass a restricted key at build time:
  //   flutter run --dart-define=MAPS_API_KEY=your_key
  // The default value is the development key — replace it with an
  // API-key restriction in Google Cloud Console (limit to this app's
  // package name / bundle ID so it cannot be abused if extracted).
  static const String apiKey = String.fromEnvironment(
    'MAPS_API_KEY',
    defaultValue: 'AIzaSyC-vojKL49r_IXRvuONNevWDBEPPhLnkmQ',
  );

  static const Map<String, LatLng> _cities = {
    'amman':     LatLng(31.9539, 35.9106),
    'zarqa':     LatLng(32.0728, 36.0878),
    'irbid':     LatLng(32.5556, 35.8500),
    'aqaba':     LatLng(29.5269, 35.0065),
    'madaba':    LatLng(31.7167, 35.8000),
    'jerash':    LatLng(32.2833, 35.9000),
    'ajloun':    LatLng(32.3333, 35.7500),
    'karak':     LatLng(31.1833, 35.7000),
    'mafraq':    LatLng(32.3417, 36.2042),
    'salt':      LatLng(32.0333, 35.7167),
    'russeifa':  LatLng(32.0417, 36.0583),
    'ramtha':    LatLng(32.5667, 36.0000),
    'tafilah':   LatLng(30.8333, 35.6000),
    'ma\'an':    LatLng(30.2000, 35.7333),
    'maan':      LatLng(30.2000, 35.7333),
    'petra':     LatLng(30.3217, 35.4789),
    'wadi musa': LatLng(30.3217, 35.4789),
    'azraq':     LatLng(31.8417, 36.8167),
  };

  /// Returns the coordinates of a Jordan city by name, or null if unknown.
  static LatLng? cityCoords(String name) =>
      _cities[name.toLowerCase().trim()];

  // Known city-pair driving times in minutes (bidirectional).
  static const Map<String, int> _cityPairMinutes = {
    'amman-irbid': 90,     'amman-zarqa': 35,
    'amman-aqaba': 240,    'amman-madaba': 30,
    'amman-jerash': 70,    'amman-ajloun': 80,
    'amman-karak': 130,    'amman-mafraq': 80,
    'amman-salt': 35,      'amman-russeifa': 25,
    'amman-ramtha': 110,   'amman-tafilah': 160,
    'amman-maan': 200,     "amman-ma'an": 200,
    'amman-petra': 210,    'amman-wadi musa': 210,
    'amman-azraq': 110,
    'irbid-zarqa': 100,    'irbid-mafraq': 50,
    'irbid-ramtha': 20,    'irbid-ajloun': 30,
    'irbid-jerash': 45,
    'zarqa-russeifa': 15,  'zarqa-mafraq': 55,
    'zarqa-ramtha': 90,
    'aqaba-karak': 130,    'aqaba-maan': 90,    "aqaba-ma'an": 90,
    'karak-maan': 80,      "karak-ma'an": 80,
    'karak-tafilah': 50,   'maan-petra': 30,    "ma'an-petra": 30,
    'maan-wadi musa': 30,  "ma'an-wadi musa": 30,
  };

  /// Returns a formatted driving-time estimate (e.g. "1h 30m") between two
  /// Jordanian cities.  Uses a lookup table for known pairs and falls back to
  /// a distance-based estimate (90 km/h avg + 15 min overhead) for unknown ones.
  static String estimatedDuration(String origin, String destination) {
    final from = origin.toLowerCase().trim();
    final to = destination.toLowerCase().trim();
    if (from == to) return '—';

    int? minutes = _cityPairMinutes['$from-$to'] ?? _cityPairMinutes['$to-$from'];

    if (minutes == null) {
      final a = cityCoords(from);
      final b = cityCoords(to);
      if (a != null && b != null) {
        final km = distanceKm(a, b);
        minutes = (km / 90 * 60 + 15).round();
      }
    }

    if (minutes == null) return '—';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  /// Haversine distance in km between two points.
  static double distanceKm(LatLng a, LatLng b) {
    const r = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  /// Perpendicular distance (km) from [pickup] to the straight line between
  /// the origin and destination city centres.  Returns 0 if either city is
  /// not in the lookup table.
  static double detourKm(LatLng pickup, String origin, String destination) {
    final a = cityCoords(origin);
    final b = cityCoords(destination);
    if (a == null || b == null) return 0;
    return _pointToSegmentKm(pickup, a, b);
  }

  /// Minimum distance (km) from point [p] to the segment [a]→[b].
  static double _pointToSegmentKm(LatLng p, LatLng a, LatLng b) {
    final dx = b.longitude - a.longitude;
    final dy = b.latitude - a.latitude;
    if (dx == 0 && dy == 0) return distanceKm(p, a);
    final t = ((p.longitude - a.longitude) * dx +
            (p.latitude - a.latitude) * dy) /
        (dx * dx + dy * dy);
    final tc = t.clamp(0.0, 1.0);
    return distanceKm(
        p, LatLng(a.latitude + tc * dy, a.longitude + tc * dx));
  }

  /// Fetches the driving duration between two cities from the Directions API.
  /// Falls back to the static lookup table if the API call fails.
  static Future<String> fetchDrivingDuration(
      String origin, String destination) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${Uri.encodeComponent('$origin, Jordan')}'
        '&destination=${Uri.encodeComponent('$destination, Jordan')}'
        '&mode=driving'
        '&key=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return estimatedDuration(origin, destination);
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return estimatedDuration(origin, destination);
      final seconds =
          data['routes'][0]['legs'][0]['duration']['value'] as int;
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      if (h == 0) return '${m}m';
      if (m == 0) return '${h}h';
      return '${h}h ${m}m';
    } catch (_) {
      return estimatedDuration(origin, destination);
    }
  }

  /// Returns decoded polyline points for the route between two addresses.
  static Future<List<LatLng>> getRoute(String origin, String destination) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${Uri.encodeComponent('$origin, Jordan')}'
        '&destination=${Uri.encodeComponent('$destination, Jordan')}'
        '&key=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return [];
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return [];
      final encoded =
          data['routes'][0]['overview_polyline']['points'] as String;
      return _decode(encoded);
    } catch (e) {
      debugPrint('MapsService.getRoute error: $e');
      return [];
    }
  }

  /// Returns the bounding box of the route.
  static Future<LatLngBounds?> getBounds(
      String origin, String destination) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${Uri.encodeComponent('$origin, Jordan')}'
        '&destination=${Uri.encodeComponent('$destination, Jordan')}'
        '&key=$apiKey',
      );
      final response = await http.get(url);
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['status'] != 'OK') return null;
      final bounds = data['routes'][0]['bounds'] as Map<String, dynamic>;
      final sw = bounds['southwest'] as Map<String, dynamic>;
      final ne = bounds['northeast'] as Map<String, dynamic>;
      return LatLngBounds(
        southwest: LatLng((sw['lat'] as num).toDouble(), (sw['lng'] as num).toDouble()),
        northeast: LatLng((ne['lat'] as num).toDouble(), (ne['lng'] as num).toDouble()),
      );
    } catch (_) {
      return null;
    }
  }

  /// Calls the Directions API with optimize:true waypoints.
  /// [origin] and [destination] are city name strings (Jordan).
  /// [pickups] are the passengers' GPS coords in booking order.
  /// Returns null on any failure.
  static Future<OptimizedRoute?> getOptimizedRoute({
    required String origin,
    required String destination,
    required List<LatLng> pickups,
  }) async {
    if (pickups.isEmpty) return null;
    try {
      final originCoord = cityCoords(origin);
      final destCoord = cityCoords(destination);
      if (originCoord == null || destCoord == null) {
        debugPrint('MapsService: unknown city — origin="$origin" destination="$destination"');
        return null;
      }

      // Build waypoints string: "optimize:true|lat,lng|lat,lng|..."
      final waypointParts = pickups
          .map((p) => '${p.latitude},${p.longitude}')
          .join('|');
      final waypointsParam = 'optimize:true|$waypointParts';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${originCoord.latitude},${originCoord.longitude}'
        '&destination=${destCoord.latitude},${destCoord.longitude}'
        '&waypoints=${Uri.encodeComponent(waypointsParam)}'
        '&key=$apiKey',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        debugPrint('Directions API error ${response.statusCode}: ${response.body}');
        return null;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      debugPrint('Directions API status: ${data['status']}');
      if (data['status'] != 'OK') {
        debugPrint('Directions API body: ${response.body}');
        return null;
      }

      final route = (data['routes'] as List).first as Map<String, dynamic>;
      final encoded = route['overview_polyline']['points'] as String;
      final points = _decode(encoded);

      final rawOrder = route['waypoint_order'] as List? ?? [];
      final order = rawOrder.map((e) => (e as num).toInt()).toList();

      final orderedPickups = order.isEmpty
          ? List<LatLng>.from(pickups)
          : order.map((i) => pickups[i]).toList();

      return OptimizedRoute(
        polylinePoints: points,
        orderedPickups: orderedPickups,
        waypointOrder: order,
      );
    } catch (e) {
      debugPrint('MapsService.getOptimizedRoute error: $e');
      return null;
    }
  }

  static List<LatLng> _decode(String encoded) {
    final points = <LatLng>[];
    int index = 0, lat = 0, lng = 0;
    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
