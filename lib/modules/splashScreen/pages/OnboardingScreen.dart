import 'package:flutter/material.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // 🟢 Matches the sleek deep blue to black gradient from the image mockup
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF64B5F6), // Soft bright blue glow at top right
              Color(0xFF0D47A1), // Deep navy blue transitions
              Color(0xFF030A16), // Near black at the bottom base
              Color(0xFF010408), // Pitch black bottom edge
            ],
            stops: [0.0, 0.35, 0.75, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 3),

                // 🟢 App Branding Logo Header Layout Area
                Row(
                  children: [
                    Image.asset(
                      'assets/logo/MedGLogo.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "MedGuardian",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.95),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      TextSpan(
                        text: "Own Your Health,\nShape ",
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: "Your Life.",
                        style: TextStyle(
                          color: Color(0xFF42A5F5), // Distinct vibrant blue accent emphasis color
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 🟢 Supporting Body Text Describer block
                Text(
                  "From tracking smart to scanning wise, your healthcare and wellness goals begin to rise.",
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: Colors.white.withOpacity(0.6),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),

                // 🟢 Custom Progress Page Indicators
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildInactiveDot(),
                    const SizedBox(width: 6),
                    _buildInactiveDot(),
                  ],
                ),

                const Spacer(flex: 2),

                // 🟢 BUTTON 1: Log In Button Container
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2), // High-vibrancy button matching your image
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.Login);
                    },
                    child: const Text(
                      "Log In",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.25), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteName.CreateAccount);
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInactiveDot() {
    return Container(
      width: 6,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}