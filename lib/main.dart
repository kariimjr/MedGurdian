import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medgurdian/data/repositories/auth_repository.dart';
import 'package:medgurdian/logic/auth_bloc/auth_bloc.dart';
import 'package:medgurdian/core/route/route_gen.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Don't forget this!

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Initialize Repository
    final authRepository = AuthRepository();

    return MultiBlocProvider(
      // 2. Provide the Bloc
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedGuardian',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          // Add your AppColors here later
        ),
        // 3. Setup Navigation
        onGenerateRoute: RouteGen.onGenerateRoute,
        initialRoute: RouteName.Splash,
      ),
    );
  }
}