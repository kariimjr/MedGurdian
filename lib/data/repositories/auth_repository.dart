import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/patient_model.dart'; // Make sure this path is correct

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- Sign Up & Save Data ---
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

  // --- Email & Password Login ---
  Future<void> login({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // --- Google Sign-In Flow (UPDATED FOR v7.0+) ---
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Get the new singleton instance
      final googleSignIn = GoogleSignIn.instance;

      // 2. Mandatory initialization step for v7.0+
      await googleSignIn.initialize();

      // 3. Trigger the Google Sign-In prompt (signIn is now authenticate)
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } catch (e) {
        // The user closed the prompt or backed out
        return null;
      }

      if (googleUser == null) {
        return null;
      }

      // 4. Get the Authentication token (IdToken)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 5. Explicitly request Authorization scopes to get the AccessToken (New in v7.0+)
      final clientAuth = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);

      // 6. Create Firebase credential combining both tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: clientAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 7. Authenticate into Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Provision a default patient document if it's their very first time logging in
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        PatientModel newPatient = PatientModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          fullName: userCredential.user!.displayName ?? 'New Patient',
          age: 0,
          gender: 'Not Specified',
          phoneNumber: userCredential.user!.phoneNumber ?? '',
        );

        await _firestore
            .collection('patients')
            .doc(userCredential.user!.uid)
            .set(newPatient.toMap());
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception("An error occurred during Google Sign In: $e");
    }
  }

  // --- Unified Logout ---
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Uses the new instance format for sign out
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      throw Exception("Error during logout: $e");
    }
  }
}