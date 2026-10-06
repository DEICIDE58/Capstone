import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/abtc_data.dart';
import '../services/location_service.dart';

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

  Future<void> findNearestAbtc() async {
    setState(() {
      loading = true;
      errorMessage = null;
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

  Future<void> openDirections() async {
    if (nearestAbtc == null) {
      return;
    }

    final query = Uri.encodeComponent(nearestAbtc!.address);

    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query',
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

                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: openDirections,
                            icon: const Icon(Icons.directions),
                            label: const Text('Get Directions'),
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
            ],
          ),
        ),
      ),
    );
  }
}