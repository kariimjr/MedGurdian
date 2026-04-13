
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/patient_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign Up & Save Data
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required int age,
    required String gender,
    required String phone,
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      PatientModel newPatient = PatientModel(
        uid: cred.user!.uid,
        email: email,
        fullName: fullName,
        age: age,
        gender: gender,
        phoneNumber: phone,
      );

      await _firestore
          .collection('patients')
          .doc(cred.user!.uid)
          .set(newPatient.toMap());

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An unknown error occurred");
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}