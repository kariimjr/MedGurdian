import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'medicine_service.dart';
import 'medicine_model.dart';

class MedicineReminderScreen extends StatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  State<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends State<MedicineReminderScreen> {
  final MedicineService _service = MedicineService();
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  int _targetDoses = 1;
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'pill';

  // Icon Mapping
  final Map<String, IconData> _medicineIcons = {
    'pill': Icons.medication,
    'capsule': Icons.medication_rounded,
    'syrup': Icons.liquor,
    'injection': Icons.vaccines,
    'cream': Icons.opacity,
    'inhaler': Icons.air,
    'drops': Icons.water_drop,
    'patch': Icons.layers,
  };

  String get _greetingName {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    } else if (user?.email != null) {
      return user!.email!.split('@')[0];
    }
    return "User";
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                    "New Medication",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0277BD))
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Medicine Name",
                    prefixIcon: const Icon(Icons.drive_file_rename_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val!.isEmpty ? "Enter medicine name" : null,
                  onChanged: (val) => _name = val,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: "Form Factors",
                    prefixIcon: Icon(_medicineIcons[_selectedType]),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _medicineIcons.keys.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Row(
                        children: [
                          Icon(_medicineIcons[type], size: 20, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(type[0].toUpperCase() + type.substring(1)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setSheetState(() => _selectedType = val!),
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<int>(
                  value: _targetDoses,
                  decoration: InputDecoration(
                    labelText: "Daily Frequency",
                    prefixIcon: const Icon(Icons.repeat),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [1, 2, 3].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value time(s) daily"),
                    );
                  }).toList(),
                  onChanged: (val) => setSheetState(() => _targetDoses = val!),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("First dose time: ${_selectedTime.format(context)}"),
                  trailing: const Icon(Icons.access_time, color: Colors.blue),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: _selectedTime);
                    if (time != null) setState(() => _selectedTime = time);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _service.addMedicine(_name, _selectedTime.format(context), _targetDoses, _selectedType);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Create Reminder", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F9FF),
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Medication Reminder", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF0277BD),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _showAddSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: _service.getMedicines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          final meds = snapshot.data!;
          return ListView.builder(
            itemCount: meds.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemBuilder: (context, index) {
              final med = meds[index];

              bool isFinished = med.currentDoses >= med.targetDoses;
              bool hasStarted = med.currentDoses > 0;
              double progress = med.currentDoses / med.targetDoses;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.blue.withOpacity(0.1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: isFinished ? Colors.green.shade50 : Colors.blue.shade50,
                          child: Icon(
                              isFinished ? Icons.check_circle : (_medicineIcons[med.type] ?? Icons.medication),
                              color: isFinished ? Colors.green : Colors.blue
                          ),
                        ),
                        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        subtitle: Text(
                          isFinished
                              ? "Next dose: Tomorrow"
                              : hasStarted
                              ? ""
                              : "Next dose at ${med.time}",
                          style: TextStyle(
                              color: isFinished ? Colors.orange.shade800 : Colors.grey.shade600,
                              fontWeight: isFinished ? FontWeight.bold : FontWeight.normal
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            isFinished ? Icons.verified : Icons.add_circle,
                            color: isFinished ? Colors.green : Colors.blue,
                            size: 32,
                          ),
                          onPressed: () => _service.takeDose(med.id, med.currentDoses, med.targetDoses),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(isFinished ? Colors.green : Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("${med.currentDoses} of ${med.targetDoses} doses taken",
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            GestureDetector(
                              onTap: () => _confirmDelete(med.id),
                              child: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 32),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/json/Tablet.json',
            fit: BoxFit.contain,
            height: 200,
            width: 200,
            errorBuilder: (context, error, stackTrace) => const CircleAvatar(
              radius: 80,
              backgroundColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 16),
          const Text("No medicine scheduled", style: TextStyle(color: Colors.blueGrey, fontSize: 18)),
          const Text("Add your prescriptions to stay on track", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Medication?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () { _service.deleteMedicine(id); Navigator.pop(context); },
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}