import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/abtc_data.dart';
import '../services/location_service.dart';
import 'feedback_screen.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final LocationService locationService = LocationService();

  Abtc? nearestAbtc;
  Position? userPosition;
  double? distance;

  bool loading = false;
  String? errorMessage;

  // Route shown inside the app
  List<LatLng> routePoints = [];
  double? routeMeters;
  double? routeSeconds;
  bool routing = false;

  Future<void> findNearestAbtc() async {
    setState(() {
      loading = true;
      errorMessage = null;
      routePoints = [];
      routeMeters = null;
      routeSeconds = null;
    });

    try {
      Position position = await locationService.getCurrentLocation();

      Abtc nearest = locationService.findNearestAbtc(position);

      double nearestDistance = locationService.getDistance(position, nearest);

      if (!mounted) {
        return;
      }

      setState(() {
        userPosition = position;
        nearestAbtc = nearest;
        distance = nearestDistance;
        loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
        errorMessage = error.toString();
      });
    }
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} meters away';
    }

    return '${(meters / 1000).toStringAsFixed(1)} km away';
  }

  String formatDuration(double seconds) {
    final minutes = (seconds / 60).round();

    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final rest = minutes % 60;

    return rest == 0 ? '$hours hr' : '$hours hr $rest min';
  }

  // Gets the route and draws it on the in-app map.
  Future<void> openDirections() async {
    if (nearestAbtc == null || userPosition == null) {
      return;
    }

    setState(() {
      routing = true;
    });

    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${userPosition!.longitude},${userPosition!.latitude};'
            '${nearestAbtc!.longitude},${nearestAbtc!.latitude}'
            '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode != 200) {
        throw Exception('Route request failed');
      }

      final data = jsonDecode(response.body);
      final routes = data['routes'] as List;

      if (routes.isEmpty) {
        throw Exception('No route found');
      }

      final route = routes[0];
      final coords = route['geometry']['coordinates'] as List;

      if (!mounted) {
        return;
      }

      setState(() {
        routePoints = coords
            .map(
              (c) => LatLng(
            (c[1] as num).toDouble(),
            (c[0] as num).toDouble(),
          ),
        )
            .toList();
        routeMeters = (route['distance'] as num).toDouble();
        routeSeconds = (route['duration'] as num).toDouble();
        routing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        routing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not load the route. Check your connection.'),
        ),
      );
    }
  }

  // Optional: full turn-by-turn navigation in Google Maps (leaves the app).
  Future<void> openInGoogleMaps() async {
    if (nearestAbtc == null) {
      return;
    }

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&destination=${nearestAbtc!.latitude},${nearestAbtc!.longitude}'
          '&travelmode=driving',
    );

    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Widget buildMap() {
    final user = LatLng(userPosition!.latitude, userPosition!.longitude);
    final target = LatLng(nearestAbtc!.latitude, nearestAbtc!.longitude);

    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            initialCameraFit: CameraFit.coordinates(
              coordinates: [user, target],
              padding: const EdgeInsets.all(50),
              maxZoom: 17,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.rabiz_check',
            ),
            // Route line (drawn under the pins)
            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 5,
                    color: Colors.blue,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                // Other ABTCs
                for (final abtc in abtcList)
                  if (abtc != nearestAbtc)
                    Marker(
                      point: LatLng(abtc.latitude, abtc.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                // Nearest ABTC
                Marker(
                  point: target,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 46,
                  ),
                ),
                // You
                Marker(
                  point: user,
                  width: 28,
                  height: 28,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              ],
            ),
            const RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    findNearestAbtc();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ABTC Referral')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Find an Animal Bite Treatment Center',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'RabizCheck uses your location to '
                    'identify the nearest Animal Bite '
                    'Treatment Center in the app database.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),

              if (loading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 15),
                      Text('Finding nearby ABTCs...'),
                    ],
                  ),
                ),

              if (errorMessage != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Unable to get your location',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(errorMessage!),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: findNearestAbtc,
                            child: const Text('Try Again'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              if (nearestAbtc != null && distance != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nearest ABTC',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          nearestAbtc!.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          nearestAbtc!.address,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatDistance(distance!),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Phone: ${nearestAbtc!.phone}',
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(height: 15),

                        if (userPosition != null) buildMap(),

                        if (routeMeters != null && routeSeconds != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Route: ${(routeMeters! / 1000).toStringAsFixed(1)} km, '
                                '~${formatDuration(routeSeconds!)} by car',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],

                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: routing ? null : openDirections,
                            icon: routing
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                                : const Icon(Icons.directions),
                            label: Text(
                              routePoints.isEmpty
                                  ? 'Get Directions'
                                  : 'Refresh Route',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: openInGoogleMaps,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open in Google Maps'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              const Card(
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    'Important: The referral provided '
                        'by RabizCheck is based on location '
                        'and the facilities stored in the '
                        'application. It does not replace '
                        'professional medical evaluation.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FeedbackScreen(),
                      ),
                    );
                  },
                  child: const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}