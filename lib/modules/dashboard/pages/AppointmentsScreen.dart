import 'package:flutter/material.dart';

class Appointmentsscreen extends StatefulWidget {
  const Appointmentsscreen({super.key});

  @override
  State<Appointmentsscreen> createState() => _AppointmentsscreenState();
}

class _AppointmentsscreenState extends State<Appointmentsscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          "Appointments",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
