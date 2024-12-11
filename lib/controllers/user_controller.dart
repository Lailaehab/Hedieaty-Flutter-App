import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/user.dart';

class UserController {
  Stream<List<Map<String, dynamic>>> getUserEvents(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // Stream for real-time updates of event's gifts
  Stream<List<Map<String, dynamic>>> getEventGifts(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add User to Firestore
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  // Get User by ID
  Future<Map<String, dynamic>?> getUser(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  // Update User
  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).update(userData);
  }

  // Delete User
  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<String> addFriendByPhoneNumber(String userId, String phoneNumber) async {
    try {
      // Query Firestore for a user with the given phone number
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'No user found with this phone number.';
      }

      // Get the friend's user ID
      String friendId = snapshot.docs.first.id;

      if (friendId == userId) {
        return 'You cannot add yourself as a friend.';
      }

      // Add the friend to the current user's friend list
      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

      // Optionally, add the current user to the friend's friend list
      DocumentReference friendRef = _firestore.collection('users').doc(friendId);
      await friendRef.update({
        'friends': FieldValue.arrayUnion([userId]),
      });

      return 'Friend added successfully.';
    } catch (e) {
      return 'Error adding friend: $e';
    }
  }
}
