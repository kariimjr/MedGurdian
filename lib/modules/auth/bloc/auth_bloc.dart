import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medgurdian/data/repositories/auth_repository.dart';

// ==========================================
// --- EVENTS ---
// ==========================================
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

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  ForgotPasswordRequested(this.email);
}

class GoogleSignInRequested extends AuthEvent {}

// ==========================================
// --- STATES ---
// ==========================================
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {}

class ForgotPasswordSuccess extends AuthState {}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

// ==========================================
// --- BLOC ---
// ==========================================
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {

    // --- Handle Register ---
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

    // --- Handle Login (Email/Password) ---
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(email: event.email, password: event.password);

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doctorDoc = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(user.uid)
              .get();

          if (doctorDoc.exists) {
            await authRepository.logout(); // Centralized unified logout
            emit(AuthFailure("Access Denied: Doctors must use the Web Portal."));
            return;
          }
        }

        emit(AuthSuccess());
      } catch (e) {
        String errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        emit(AuthFailure(errorMessage));
      }
    });

    // --- Handle Forgot Password ---
    on<ForgotPasswordRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: event.email);
        emit(ForgotPasswordSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    // --- Handle Google Sign-In ---
    on<GoogleSignInRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final userCredential = await authRepository.signInWithGoogle();

        if (userCredential == null) {
          emit(AuthInitial()); // User canceled
          return;
        }

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doctorDoc = await FirebaseFirestore.instance
              .collection('doctors')
              .doc(user.uid)
              .get();

          if (doctorDoc.exists) {
            await authRepository.logout(); // Centralized unified logout
            emit(AuthFailure("Access Denied: Doctors must use the Web Portal."));
            return;
          }
        }

        emit(AuthSuccess());
      } catch (e) {
        String errorMessage = e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim();
        emit(AuthFailure(errorMessage));
      }
    });
  }
}