// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Importe o GoogleSignIn

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // Instancie o GoogleSignIn

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  // MÉTODO PARA LOGIN COM E-MAIL E SENHA (EXISTENTE, MAS CHAMEI DE signInWithEmailAndPassword)
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(
        'Firebase Auth Exception (Email/Password): ${e.code} - ${e.message}',
      );
      rethrow;
    } catch (e) {
      print('Generic Sign In Exception (Email/Password): $e');
      rethrow;
    }
  }

  // MÉTODO PARA LOGIN COM GOOGLE (ADICIONADO)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // Usuário cancelou o login
      }
      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await _firebaseAuth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(
        "FirebaseAuthException during Google Sign-In: ${e.code} - ${e.message}",
      );
      rethrow;
    } catch (e) {
      print("Error during Google Sign-In: $e");
      rethrow;
    }
  }

  // Exemplo de método de registro (se você tiver um)
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredential.user?.updateDisplayName(displayName);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception (Create User): ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('Generic Create User Exception: $e');
      rethrow;
    }
  }

  // MÉTODO DE LOGOUT (ADICIONADO _googleSignIn.signOut())
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Desloga da conta Google
    await _firebaseAuth.signOut(); // Desloga do Firebase
  }
}
