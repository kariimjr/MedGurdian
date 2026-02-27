
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';
import 'package:medgurdian/core/theme/app_colors.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInDown(
                duration: Duration(seconds: 2),
                onFinish: (direction) {
                  Navigator.pushReplacementNamed(context, RouteName.Login);
                },
                child: Image.asset(
                  "assets/logo/MedGLogo.png",
                  height: 274,
                  width: 207,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }
}
