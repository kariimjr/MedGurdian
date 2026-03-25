import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class HomeMapCard extends StatelessWidget {
  final LatLng userLocation;
  final Function(String query) onSearch;

  const HomeMapCard({
    super.key,
    required this.userLocation,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: userLocation, initialZoom: 15.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.medgurdian',
                ),
                MarkerLayer(markers: [
                  Marker(point: userLocation, width: 50, height: 50, child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40))
                ]),
              ],
            ),
            Positioned(
              bottom: 15, left: 15, right: 15,
              child: Row(
                children: [
                  _mapBtn("Hospitals", Icons.local_hospital, Colors.blue, () => onSearch('hospitals')),
                  const SizedBox(width: 10),
                  _mapBtn("Pharmacies", Icons.local_pharmacy, Colors.red, () => onSearch('pharmacies')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapBtn(String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}