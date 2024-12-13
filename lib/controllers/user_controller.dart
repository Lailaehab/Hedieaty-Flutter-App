import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/models/user.dart';
import 'gift_controller.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GiftController _giftController = GiftController();

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

   // Fetch pledged gifts for a user
  Future<List<Map<String, dynamic>>> getPledgedGifts(String userId) async {
    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    final pledgedGiftIds = List<String>.from(userSnapshot.data()?['pledgedGifts'] ?? []);

    final pledgedGifts = <Map<String, dynamic>>[];
    for (var giftId in pledgedGiftIds) {
      final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
      final giftData = giftSnapshot.data()!;
      // Fetch the owner of the gift (Friend field in the previous code)
      final giftOwnerName = await _giftController.getGiftOwner(giftId);

      pledgedGifts.add({
        'id': giftId,
        'giftName': giftData['name'],
        'Friend': giftOwnerName, // Friend is now the gift owner name
        'category': giftData['category'],
        'price': giftData['price'],
        'description': giftData['description'],
        'image': giftData['imageUrl'], 
        'ownerId':giftData['ownerId'] ,// Assuming image URL is stored
      });
    }
    return pledgedGifts;
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

      // add the current user to the friend's friend list
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
