import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medgurdian/data/repositories/auth_repository.dart';

// --- EVENTS ---
abstract class AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;
  final int age;
  final String gender;
  final String phone;

  RegisterRequested({
    required this.email,
    required this.password,
    required this.fullName,
    required this.age,
    required this.gender,
    required this.phone,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

// NEW EVENT: Added for Forget Password
class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

// --- STATES ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
// NEW STATE: Tells UI that the reset code went through successfully
class ForgotPasswordSuccess extends AuthState {}
class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// --- BLOC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {

    // Handle Register
    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.signUp(
          email: event.email,
          password: event.password,
          fullName: event.fullName,
          age: event.age,
          gender: event.gender,
          phone: event.phone,
        );
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // Handle Login (INVERTED GUARD: BLOCKS DOCTORS)
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // 1. Log in via Firebase Auth
        await authRepository.login(email: event.email, password: event.password);

        // 2. Check if the user exists in the 'doctors' collection
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doctorDoc = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(user.uid)
              .get();

          // If the document EXISTS in 'doctors', they are a doctor and must be blocked.
          if (doctorDoc.exists) {
            await FirebaseAuth.instance.signOut();
            emit(AuthFailure("Access Denied: Doctors must use the Web Portal."));
            return;
          }
        }

        // 3. Success (They are not a doctor, so they can enter)
        emit(AuthSuccess());
      } catch (e) {
        // Clean up the error message for the UI
        String errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        emit(AuthFailure(errorMessage));
      }
    });

    // Handle Forgot Password
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
        emit(ForgotPasswordSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}