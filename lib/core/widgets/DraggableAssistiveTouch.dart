import 'package:flutter/material.dart';

class DraggableAssistiveTouch extends StatefulWidget {
  final VoidCallback onTap;
  const DraggableAssistiveTouch({super.key, required this.onTap});

  @override
  State<DraggableAssistiveTouch> createState() => _DraggableAssistiveTouchState();
}

class _DraggableAssistiveTouchState extends State<DraggableAssistiveTouch> {
  // Initial position
  Offset position = const Offset(20, 100);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // 1. Calculate the raw new position
            double newDx = position.dx + details.delta.dx;
            double newDy = position.dy + details.delta.dy;

            // 2. Define your Top and Bottom Boundaries
            double topPadding = MediaQuery.of(context).padding.top;
            double appBarHeight = kToolbarHeight; // Default AppBar height
            double navBarHeight = 80.0; // Estimate of your Bottom Navigation Bar height
            double screenHeight = MediaQuery.of(context).size.height;

            double minY = topPadding + appBarHeight;
            double maxY = screenHeight - navBarHeight - 70.0; // 70 is button size

            // 3. Apply the Clamp
            position = Offset(
              newDx,
              newDy.clamp(minY, maxY), // This prevents it from going over Appbar/Navbar
            );
          });
        },
        onPanEnd: (details) {
          double screenWidth = MediaQuery.of(context).size.width;
          double hiddenOffset = 35.0;

          setState(() {
            var isDragging = false;
            // Snap to sides, but keep the clamped Y position
            if (position.dx + 35 < screenWidth / 2) {
              position = Offset(-hiddenOffset, position.dy);
            } else {
              position = Offset(screenWidth - hiddenOffset, position.dy);
            }
          });
        },
        onTap: widget.onTap, // Navigate to your screen
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: const Center(
            child: Icon(Icons.auto_awesome, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}