// services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // Example sign-in method (adapt as needed)
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      print('Firebase Auth Exception: ${e.code} - ${e.message}');
      rethrow; // Rethrow to be caught by UI
    } catch (e) {
      print('Generic Sign In Exception: $e');
      rethrow;
    }
  }

  // Example sign-up method
  Future<UserCredential> createUserWithEmailAndPassword(String email, String password, String displayName) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(displayName);
      // You might want to store additional user data in Firestore here
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}