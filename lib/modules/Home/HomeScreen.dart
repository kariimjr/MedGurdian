import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medgurdian/modules/MedicineScreen/medicine_model.dart';
import 'package:medgurdian/modules/MedicineScreen/medicine_service.dart';


class HealthHomeScreen extends StatefulWidget {
  const HealthHomeScreen({super.key});

  @override
  State<HealthHomeScreen> createState() => _HealthHomeScreenState();
}

class _HealthHomeScreenState extends State<HealthHomeScreen> {
  final MedicineService _medicineService = MedicineService();
  String _quote = "Loading your daily inspiration...";

  // Health quotes - In production, load this from rootBundle.loadString('assets/quotes.json')
  final List<String> _quotes = [
    "Health is not valued till sickness comes.",
    "A journey of a thousand miles begins with a single step.",
    "Your body hears everything your mind says. Stay positive.",
    "Water is the driving force of all nature.",
    "Eat to live, not live to eat."
  ];

  @override
  void initState() {
    super.initState();
    _quote = _quotes[Random().nextInt(_quotes.length)];
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String get _userName {
    final user = FirebaseAuth.instance.currentUser;
    return user?.displayName?.split(' ')[0] ?? user?.email?.split('@')[0] ?? "User";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: CustomScrollView(
        slivers: [
          // 1. Header Section
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Colors.blue.shade700,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${_getGreeting()},", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                      Text(_userName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      _buildQuoteCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Health Stats Summary
                  _buildHealthSummary(),
                  const SizedBox(height: 25),

                  // 3. Quick Actions
                  const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildQuickActions(),
                  const SizedBox(height: 25),

                  // 4. Map Section
                  const Text("Nearby Facilities", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildMapPreview(),
                  const SizedBox(height: 25),

                  // 5. Today's Medicines
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Today's Schedule", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(onPressed: () {}, child: const Text("See All")),
                    ],
                  ),
                  _buildMedicineStream(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.format_quote, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _quote,
              style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Hydration", "80%", Icons.water_drop, Colors.blue),
          _divider(),
          _statItem("Sleep", "7h 20m", Icons.bedtime, Colors.indigo),
          _divider(),
          _statItem("Activity", "4.2k", Icons.directions_walk, Colors.orange),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _divider() => Container(height: 40, width: 1, color: Colors.grey.shade200);

  Widget _buildQuickActions() {
    return Row(
      children: [
        _actionCard("Add Med", Icons.add_moderator, Colors.green.shade50, Colors.green),
        const SizedBox(width: 15),
        _actionCard("Tips", Icons.lightbulb_outline, Colors.orange.shade50, Colors.orange),
        const SizedBox(width: 15),
        _actionCard("Reports", Icons.bar_chart, Colors.purple.shade50, Colors.purple),
      ],
    );
  }

  Widget _actionCard(String title, IconData icon, Color bg, Color iconColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(15)),
        child: Column(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: iconColor, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPreview() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: NetworkImage('https://i.pinimg.com/1200x/53/04/0f/53040fbd2c6fc53ce39e0920714f5755.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [Colors.black.withOpacity(0.4), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_hospital, size: 16),
              label: const Text("Hospitals"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.blue),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.local_pharmacy, size: 16),
              label: const Text("Pharmacies"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineStream() {
    return StreamBuilder<List<Medicine>>(
      stream: _medicineService.getMedicines(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final meds = snapshot.data!.take(3).toList(); // Show top 3 for home screen

        if (meds.isEmpty) return const Text("No medicines scheduled for today.");

        return Column(
          children: meds.map((med) => _buildMedicineCard(med)).toList(),
        );
      },
    );
  }

  Widget _buildMedicineCard(Medicine med) {
    bool isDone = med.currentDoses >= med.targetDoses;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isDone ? Colors.green.shade50 : Colors.blue.shade50,
            child: Icon(isDone ? Icons.check : Icons.access_time, color: isDone ? Colors.green : Colors.blue, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(isDone ? "Completed Today" : "Next dose at ${med.time}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!isDone)
            IconButton(
              onPressed: () => _medicineService.takeDose(med.id, med.currentDoses, med.targetDoses),
              icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            ),
        ],
      ),
    );
  }
}