import 'package:flutter_bloc/flutter_bloc.dart';
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

// --- STATES ---
abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {}
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

    // Handle Login
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await authRepository.login(email: event.email, password: event.password);
        emit(AuthSuccess());
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });
  }
}