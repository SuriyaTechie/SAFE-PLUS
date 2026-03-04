import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/location_service.dart';
import '../utils/nav_utils.dart';
import '../widgets/main_bottom_nav.dart';
import 'emergency_history_page.dart';
import 'emergency_page.dart';
import 'home_page.dart';
import 'profile_page.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const LatLng _indiaCenter = LatLng(22.5937, 78.9629);

  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  LatLng? _myLocation;
  bool _loadingLocation = false;

  void _handleNavTap(int index) {
    if (index == 3) return;

    if (index == 0) {
      Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(context, noAnimationRoute(const EmergencyPage()));
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(context, noAnimationRoute(const EmergencyHistoryPage()));
      return;
    }
    if (index == 4) {
      Navigator.pushReplacement(context, noAnimationRoute(const ProfilePage()));
    }
  }

  Future<void> _goToMyLocation() async {
    if (_loadingLocation) return;

    setState(() => _loadingLocation = true);
    try {
      final position = await _locationService.getCurrentLocation();
      final target = LatLng(position.latitude, position.longitude);

      _mapController.move(target, 14);
      setState(() => _myLocation = target);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Location: ${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to get location: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[
      const Marker(
        point: _indiaCenter,
        width: 40,
        height: 40,
        child: Icon(Icons.flag_circle, color: Color(0xFF3B82F6), size: 34),
      ),
      if (_myLocation != null)
        Marker(
          point: _myLocation!,
          width: 44,
          height: 44,
          child: const Icon(Icons.my_location, color: Color(0xFFE11D48), size: 34),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
              return;
            }
            Navigator.pushReplacement(context, noAnimationRoute(const HomePage()));
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: const Text('India Map'),
        backgroundColor: const Color(0xFFF8FAFC),
      ),
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _indiaCenter,
              initialZoom: 5.2,
              minZoom: 3,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.ai_emergency_shouter',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            left: 14,
            right: 14,
            top: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                _myLocation == null
                    ? 'Map centered on India. Tap "Locate Me" to get your live location.'
                    : 'Lat: ${_myLocation!.latitude.toStringAsFixed(5)}  Lon: ${_myLocation!.longitude.toStringAsFixed(5)}',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToMyLocation,
        backgroundColor: const Color(0xFFE11D48),
        label: Text(_loadingLocation ? 'Locating...' : 'Locate Me'),
        icon: Icon(_loadingLocation ? Icons.sync : Icons.my_location),
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: 3,
        onTap: _handleNavTap,
      ),
    );
  }
}
