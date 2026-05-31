import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:medgurdian/modules/auth/bloc/auth_bloc.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0277BD)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSuccess) {
            // 1. Hide the "Sending code..." snackbar if it's still there
            ScaffoldMessenger.of(context).hideCurrentSnackBar();

            // 2. Show a green success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Reset email sent! Please check your inbox and spam folder."),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 5),
              ),
            );

            // 3. Automatically pop back to the Login Screen so they can log in
            Navigator.pop(context);
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
              // 1. Header Section with Animation matching Login
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE1F5FE), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Lottie.asset(
                        'assets/json/Security.json', // Reusing your security file or change to a lock asset
                        fit: BoxFit.contain,
                        height: 220,
                        errorBuilder: (context, error, stackTrace) {
                          return const CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 55,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Main Content Panel
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
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0277BD),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Enter your email address below. We will send you a verification code to reset your password.",
                          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 35),

                        // --- Simple Email Input Capsule ---
                        _buildInputContainer(
                          icon: Icons.mail_outlined,
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: "example@email.com",
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter your email";
                              }
                              if (!value.contains('@')) {
                                return "Enter a valid email";
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 35),

                        // 🔥 Action Button to Send Code
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF0277BD),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 4,
                            shadowColor: Colors.blue.withOpacity(0.3),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Sending code...")),
                              );

                              // !!! MAKE SURE THIS LINE IS NOT COMMENTED OUT !!!
                              context.read<AuthBloc>().add(ForgotPasswordRequested(emailController.text.trim()));
                            }
                          },
                          child: const Text(
                            "SEND CODE",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                          ),
                        ),
                        const SizedBox(height: 20),
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

  // Matching container wrapper from LoginScreen
  Widget _buildInputContainer({required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0277BD)),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}