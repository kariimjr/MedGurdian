import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medgurdian/modules/auth/bloc/auth_bloc.dart';
import 'package:lottie/lottie.dart'; // Make sure lottie is in your pubspec.yaml
import '../../../core/route/app_routes_name.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Standard professional background
      extendBodyBehindAppBar: true, // Seamless design
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, RouteName.Layout);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              // 1. Animated Header Section (Pops like the image)
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFE1F5FE), // Your light medical blue
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(
                      child: Lottie.asset(
                        'assets/json/Security.json', // Your JSON file
                        fit: BoxFit.contain,
                        height: 300,
                        // Add an errorBuilder as a placeholder
                        errorBuilder: (context, error, stackTrace) {
                          return const CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.security,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Main Login Panel (Modern, rounded corner style)
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Welcome Back,",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Login to your MedGuardian account.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 35),

                        // --- Email Input (Using modern capsule style from image) ---
                        _buildInputContainer(
                          icon: Icons.mail_outlined,
                          child: TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              hintText: "example@email.com",
                              border: InputBorder.none,
                            ),
                            validator: (value) => value!.contains('@')
                                ? null
                                : "Enter a valid email",
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Password Input (Capsule style) ---
                        _buildInputContainer(
                          icon: Icons.lock_outline_rounded,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "•••••••••••",
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value!.length > 5 ? null : "Min 6 characters",
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- Forgot & Login Row ---
                        Row(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      RouteName.Forget,
                                    );
                                  },
                                  child: const Text(
                                    "Forgot Password?",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),

                            // 🔥 Modern Primary Action Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 16,
                                ),
                                backgroundColor: const Color(
                                  0xFF0277BD,
                                ), // Your main blue
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                elevation: 5,
                                shadowColor: Colors.blue.withOpacity(0.4),
                              ),
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                    LoginRequested(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    ),
                                  );
                                }
                              },
                              child: const Text("LOGIN"),
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // --- Social Login Section ---
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.grey)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                "Or sign in with",
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // 🔥 Sign In with Google Only
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              // Trigger Google SignIn event here (future edit)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Google SignIn - Coming Soon"),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Lottie.asset(
                                'assets/json/GoogleLogo.json', // Your JSON file
                                fit: BoxFit.contain,
                                height: 70,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // --- Create Account Section ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.grey),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteName.CreateAccount,
                                );
                              },
                              child: const Text(
                                "Create Account",
                                style: TextStyle(
                                  color: Color(0xFF0277BD),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Helper widget to build the modern input capsules from the image
  Widget _buildInputContainer({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // Soft accent background like the image
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF0277BD)),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
