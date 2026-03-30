import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';
import 'package:medgurdian/modules/auth/bloc/auth_bloc.dart';
import 'package:lottie/lottie.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedGender = 'Male';
  final List<String> genders = ['Male', 'Female'];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
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
              // 1. MODERN GRADIENT HEADER
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFFE1F5FE),
                foregroundColor: const Color(0xFF01579B), // Back arrow color
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFB3E5FC),
                          Color(0xFFE1F5FE),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Lottie.asset(
                        'assets/json/Security.json', // Reuse security or use a 'User' json
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. REGISTRATION FORM PANEL
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 30, 24, 50),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(80),
                      topRight: Radius.circular(80),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF01579B),
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          "Join MedGuardian to track your health",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 35),

                        // Full Name
                        _buildInputContainer(
                          icon: Icons.person_outline_rounded,
                          child: TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              hintText: "Full Name",
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value!.isEmpty ? "Enter your name" : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Age & Gender Row
                        Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildInputContainer(
                                icon: Icons.cake_outlined,
                                child: TextFormField(
                                  controller: ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: "Age",
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) =>
                                      value!.isEmpty ? "!" : null,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 1,
                              child: _buildInputContainer(
                                icon: Icons.wc_rounded,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedGender,
                                    isExpanded: true,
                                    items: genders.map((String gender) {
                                      return DropdownMenuItem(
                                        value: gender,
                                        child: Text(gender),
                                      );
                                    }).toList(),
                                    onChanged: (val) =>
                                        setState(() => selectedGender = val!),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Phone Number
                        _buildInputContainer(
                          icon: Icons.phone_android_rounded,
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: "Phone Number",
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value!.length < 10 ? "Invalid phone" : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email
                        _buildInputContainer(
                          icon: Icons.alternate_email_rounded,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "Email Address",
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value!.contains('@') ? null : "Invalid email",
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Password
                        _buildInputContainer(
                          icon: Icons.lock_open_rounded,
                          child: TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                            ),
                            validator: (value) =>
                                value!.length < 6 ? "Min 6 chars" : null,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- SUBMIT BUTTON ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: const Color(0xFF0277BD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            elevation: 8,
                            shadowColor: Colors.blue.withOpacity(0.3),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                RegisterRequested(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  fullName: nameController.text.trim(),
                                  age: int.parse(ageController.text.trim()),
                                  gender: selectedGender,
                                  phone: phoneController.text.trim(),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            "CREATE ACCOUNT",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Back to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color: Color(0xFF0277BD),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
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

  // REUSABLE CAPSULE INPUT (Matches Login Screen)
  Widget _buildInputContainer({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blue.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0277BD), size: 22),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}
