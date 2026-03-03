import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medgurdian/data/repositories/auth_repository.dart';
import 'package:medgurdian/core/route/route_gen.dart';
import 'package:medgurdian/core/route/app_routes_name.dart';
import 'package:medgurdian/modules/auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Don't forget this!

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();

    // The Provider MUST wrap the MaterialApp
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
      ],
      // MaterialApp is the CHILD of the Provider
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedGuardian',
        theme: ThemeData(primarySwatch: Colors.blue),
        onGenerateRoute: RouteGen.onGenerateRoute,
        initialRoute: RouteName.Splash,
      ),
    );
  }
}