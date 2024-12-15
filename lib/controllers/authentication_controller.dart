import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> signUp(String name, String email, String password, String phoneNumber) async {
    try {
      // Validate email and password
      if (email.isEmpty || password.length < 6) {
        throw Exception("Invalid email or password.");
      }

    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

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

  Future<void> logOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        await currentUser.reload();
        currentUser = _auth.currentUser;
      }
    } catch (e) {
      throw Exception("Error updating password: $e");
    }
  }
}
