// lib/components/google_login_button.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// You will need to add google_sign_in dependency to your pubspec.yaml
// and configure it for your platform (iOS, Android, Web)
// import 'package:google_sign_in/google_sign_in.dart';

class GoogleLoginButton extends StatelessWidget {
  final Function(User?) onSuccess;

  const GoogleLoginButton({super.key, required this.onSuccess});

  // This is a simplified placeholder.
  // Real Google Sign-In in Flutter requires more setup (google_sign_in package, Firebase console setup).
  Future<void> _signInWithGoogle() async {
    try {
      // This part is highly simplified.
      // A real implementation would involve:
      // 1. Initializing GoogleSignIn: GoogleSignIn _googleSignIn = GoogleSignIn();
      // 2. Signing in: final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // 3. Getting auth details: final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      // 4. Creating Firebase credential: final AuthCredential credential = GoogleAuthProvider.credential(
      //    accessToken: googleAuth.accessToken,
      //    idToken: googleAuth.idToken,
      // );
      // 5. Signing in to Firebase with credential: UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // For demonstration, we'll simulate a successful login with a dummy user.
      // In a real app, you'd get the actual user from Firebase after successful Google sign-in.
      print("Simulating Google Sign-In...");
      // Simulate a delay for async operation
      await Future.delayed(const Duration(seconds: 1));

      // This is where you would call the actual Google Sign-In for Flutter
      // For now, we'll just call onSuccess with a null user to avoid crashing
      // You NEED to replace this with actual Google Sign-In logic.
      onSuccess(
        null,
      ); // Pass null or a dummy user for now, or the actual user after implementation
    } catch (e) {
      print("Error during Google Sign-In: $e");
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black, // Text color
          side: const BorderSide(color: Colors.grey), // Border color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        icon: Image.asset(
          'assets/google_logo.png', // You'll need a Google logo asset
          height: 24,
        ),
        label: const Text("Entrar com Google", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
