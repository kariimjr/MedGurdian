import 'package:flutter/material.dart';
import 'package:medgurdian/modules/auth/pages/login_screen.dart';
import 'package:medgurdian/modules/auth/pages/register_screen.dart';
import 'package:medgurdian/modules/cancer_detection/pages/ScanScreen.dart';
import 'package:medgurdian/modules/chat/pages/MedicalChatScreen.dart';
import 'package:medgurdian/modules/dashboard/pages/layout_Screen.dart';
import 'package:medgurdian/modules/splashScreen/pages/splashScreen.dart';
import 'app_routes_name.dart';

class RouteGen {
  static Route<dynamic> onGenerateRoute(RouteSettings setting) {
    switch (setting.name) {
      case RouteName.Splash:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SplashScreen(),
        );

      case RouteName.Login:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LoginScreen(),
        );

      case RouteName.CreateAccount:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RegisterScreen(),
        );

      case RouteName.Layout:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LayoutScreen(),
        );
      case RouteName.ScanScreen:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ScanScreen(),
        );
      case RouteName.MedicalChat:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
          MedicalChatScreen(),
        );
      default:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SplashScreen(),
        );
    }
  }
}
