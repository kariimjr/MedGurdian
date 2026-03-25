import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

// Widget Imports
import 'package:medgurdian/modules/Home/widgets/HomeHeader.dart';
import 'package:medgurdian/modules/Home/widgets/HomeHealthSummary.dart';
import 'package:medgurdian/modules/Home/widgets/HomeMapCard.dart';
import 'package:medgurdian/modules/Home/widgets/HomeQuickActions.dart';
import 'package:medgurdian/modules/Home/widgets/MedicineListItem.dart';

// Data imports
import 'package:medgurdian/modules/MedicineScreen/medicine_model.dart';
import 'package:medgurdian/modules/MedicineScreen/medicine_service.dart';

class HealthHomeScreen extends StatefulWidget {
  const HealthHomeScreen({super.key});

  @override
  State<HealthHomeScreen> createState() => _HealthHomeScreenState();
}

class _HealthHomeScreenState extends State<HealthHomeScreen> {
  final MedicineService _medicineService = MedicineService();

  // 🔥 Variables to prevent reloads
  late String _currentQuote;
  late Future<Position> _locationFuture;

  final List<String> _quotes = [
    "Healing takes time — be patient with yourself.",
    "Small progress is still progress.",
    "Your health matters more than anything.",
    "Recovery begins with hope.",
    "One step at a time.",
  ];

  @override
  void initState() {
    super.initState();
    // 1. Pick the quote once
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];

    // 2. 🔥 Start the location search ONCE.
    // This stops the map from reloading every time you take a medicine.
    _locationFuture = _determinePosition();
  }

  // --- LOGIC ---
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return Future.error('Permissions denied');
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> _launchMaps(String query, double lat, double lng) async {
    final Uri uri = Uri.parse("geo:$lat,$lng?q=$query");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: CustomScrollView(
        slivers: [
          HomeHeader(
            greeting: DateTime.now().hour < 12 ? "Good Morning" : "Good Evening",
            userName: FirebaseAuth.instance.currentUser?.email?.split('@')[0] ?? "User",
            quote: _currentQuote,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeHealthSummary(),
                  const SizedBox(height: 30),
                  _sectionLabel("Quick Actions"),
                  const HomeQuickActions(),
                  const SizedBox(height: 30),
                  _sectionLabel("Nearby Facilities"),
                  _buildMapSection(),
                  const SizedBox(height: 30),
                  _sectionLabel("Today's Schedule", trailing: "See All"),
                  _buildMedicineStream(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return FutureBuilder<Position>(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 250,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Container(
            height: 250,
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(20)),
            child: Center(child: Text("Enable GPS to see Map")),
          );
        }

        return HomeMapCard(
          userLocation: LatLng(snapshot.data!.latitude, snapshot.data!.longitude),
          onSearch: (q) => _launchMaps(q, snapshot.data!.latitude, snapshot.data!.longitude),
        );
      },
    );
  }

  Widget _buildMedicineStream() {
    return StreamBuilder<List<Medicine>>(
      stream: _medicineService.getMedicines(),
      builder: (context, snapshot) {
        // 1. Check if we are still connecting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        // 3. If there is data, show the list
        final meds = snapshot.data!.take(3).toList();
        return Column(
          children: meds.map((med) => MedicineListItem(
            med: med,
            onTake: () => _medicineService.takeDose(med.id, med.currentDoses, med.targetDoses),
          )).toList(),
        );
      },
    );
  }  Widget _sectionLabel(String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A237E))),
          if (trailing != null) TextButton(onPressed: () {}, child: Text(trailing)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Lottie.asset(
              'assets/json/Tablet.json',
              fit: BoxFit.contain,
              height: 100,
              width: 100,
              errorBuilder: (context, error, stackTrace) => const CircleAvatar(
                radius: 80,
                backgroundColor: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "No medicine scheduled",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Your schedule is clear for today!",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }



}