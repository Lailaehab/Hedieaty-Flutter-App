import 'package:cloud_firestore/cloud_firestore.dart';
import 'gift_controller.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GiftController _giftController = GiftController();

  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set(userData);
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    DocumentSnapshot snapshot = await _firestore.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).update(userData);
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<List<Map<String, dynamic>>> getPledgedGifts(String userId) async {
    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    final pledgedGiftIds = List<String>.from(userSnapshot.data()?['pledgedGifts'] ?? []);

    final pledgedGifts = <Map<String, dynamic>>[];
    for (var giftId in pledgedGiftIds) {
      final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
      final giftData = giftSnapshot.data()!;
      
      final giftOwnerName = await _giftController.getGiftOwner(giftId);

      pledgedGifts.add({
        'id': giftId,
        'giftName': giftData['name'],
        'Friend': giftOwnerName, // Friend is the gift owner name
        'category': giftData['category'],
        'price': giftData['price'],
        'description': giftData['description'],
        'image': giftData['imageUrl'], 
        'ownerId':giftData['ownerId'] ,
      });
    }
    return pledgedGifts;
  }

  Future<String> addFriendByPhoneNumber(String userId, String phoneNumber) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .get();

      if (snapshot.docs.isEmpty) {
        return 'No user found with this phone number.';
      }

      String friendId = snapshot.docs.first.id;

      if (friendId == userId) {
        return 'You cannot add yourself as a friend.';
      }

      DocumentReference userRef = _firestore.collection('users').doc(userId);
      await userRef.update({
        'friends': FieldValue.arrayUnion([friendId]),
      });

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
