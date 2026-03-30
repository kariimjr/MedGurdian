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
      height: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: userLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                  userAgentPackageName: 'com.example.medguardian',
                ),                MarkerLayer(
                  markers: [
                    Marker(
                      point: userLocation,
                      width: 50,
                      height: 50,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. The Drop Shadow (a small dark circle at the bottom)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 12,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.all(Radius.elliptical(12, 6)),
                              ),
                            ),
                          ),
                          // 2. The Main Teardrop Pin
                          const Icon(
                            Icons.location_on,
                            color: Colors.red, // Google's signature red is often #EA4335
                            size: 45,
                          ),
                          // 3. The White Center Dot
                          const Positioned(
                            top: 10,
                            child: Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 15,
              left: 15,
              right: 15,
              child: Row(
                children: [
                  _mapBtn(
                    "Hospitals",
                    Icons.local_hospital,
                    Colors.blue,
                    () => onSearch('hospitals'),
                  ),
                  const SizedBox(width: 10),
                  _mapBtn(
                    "Pharmacies",
                    Icons.local_pharmacy,
                    Colors.red,
                    () => onSearch('pharmacies'),
                  ),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9), // Glass effect
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
