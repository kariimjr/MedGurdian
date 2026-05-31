import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medgurdian/modules/Home/pages/individual_chat_screen.dart';

class ChatWithDoctor extends StatelessWidget {
  const ChatWithDoctor({super.key});

  // 📸 Dynamic Image Decoding Engine
  Widget _buildDoctorAvatar(String avatarUrl) {
    if (avatarUrl.startsWith('data:image')) {
      try {
        // Extract the raw Base64 data substring by removing the data URI header config
        final String base64Content = avatarUrl.split(',').last;
        return Image.memory(
          base64Decode(base64Content),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
        );
      } catch (e) {
        return _buildFallbackImage();
      }
    }

    // Default standard HTTP network path rendering route
    if (avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }

    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    return Image.network(
      "https://images.unsplash.com/photo-1559839734-2b71ea197ec2?q=80&w=400&auto=format&fit=crop",
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            "Available Care Specialists",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0277BD),
            ),
          ),
        ),
        SizedBox(
          height: 250,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('doctors')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0277BD)),
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Connection error.",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                );
              }

              final rawDocs = snapshot.data?.docs ?? [];

              if (rawDocs.isEmpty) {
                return const Center(
                  child: Text(
                    "No specialists found.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              }

              // 🎯 SMART SORTING: Push "online" doctors to the front of the list
              final docs = rawDocs.toList();
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                final aIsOnline = aData['status'] == 'online';
                final bIsOnline = bData['status'] == 'online';

                if (aIsOnline && !bIsOnline) return -1; // 'a' goes first
                if (!aIsOnline && bIsOnline) return 1;  // 'b' goes first
                return 0; // Leave them in their current order if both are the same
              });

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  final String docId = doc.id;
                  final String rawName = data['name'] ?? "Unknown";
                  final String name = rawName.startsWith("Dr.") ? rawName : "Dr. $rawName";
                  final String specialty = data['specialty'] ?? "Medicine Specialist";

                  final bool isOnline = data['status'] == 'online';
                  final String avatar = data['avatar'] ?? "";

                  final Color bgColor = const Color(0xFF90CAF9).withOpacity(0.4);
                  final List<IconData> icons = [Icons.healing_outlined, Icons.air_rounded, Icons.opacity_rounded];

                  // 🎯 FIX: Wrapped with Opacity Widget to cleanly separate online vs offline visuals
                  return Opacity(
                    opacity: isOnline ? 1.0 : 0.65,
                    child: Container(
                      width: 200,
                      margin: const EdgeInsets.only(right: 16, bottom: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          children: [
                            // 1. Doctor Portrait Background
                            Container(
                              color: bgColor,
                              height: double.infinity,
                              width: double.infinity,
                              child: _buildDoctorAvatar(avatar),
                            ),

                            // 2. Translucent Bottom Info Panel
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.92),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Color(0xFF152A38),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // 🟢 Dynamic Online Dot
                                        if (isOnline)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            margin: const EdgeInsets.only(left: 6, right: 2),
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      specialty,
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),

                                    // 3. Micro Chips Icons Row Layout
                                    Row(
                                      children: icons.map((icon) {
                                        return Container(
                                          margin: const EdgeInsets.only(right: 6),
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.grey.shade300),
                                            color: Colors.white,
                                          ),
                                          child: Icon(icon, size: 12, color: Colors.blueGrey.shade700),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 4. Consultation Button
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: GestureDetector(
                                onTap: () {
                                  final String? patientId = FirebaseAuth.instance.currentUser?.uid;
                                  if (patientId == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Please log in first")),
                                    );
                                    return;
                                  }

                                  final String chatId = "${patientId}_$docId";

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => IndividualChatScreen(
                                        chatId: chatId,
                                        doctorName: name,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF00364D),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.north_east_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}