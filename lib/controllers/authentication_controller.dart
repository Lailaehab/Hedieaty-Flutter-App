import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sign-Up Method
  Future<String?> signUp(String name, String email, String password, String phoneNumber) async {
    try {
      // Validate email and password
      if (email.isEmpty || password.length < 6) {
        throw Exception("Invalid email or password.");
      }

      // Create user in Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user to Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePicture': '', // Placeholder
        'friends': [],
        'pledgedGifts': [],
      });

      return credential.user!.uid;
    } catch (e) {
      print('Sign-Up Error: $e');
      return null;
    }
  }

  // Log-In Method
  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      print('Log-In Error: ${e.message}');
      return null;
    }
  }

  // Log-Out Method
  Future<void> logOut() async {
    await _auth.signOut();
  }

  // Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
