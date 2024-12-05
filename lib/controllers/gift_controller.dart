import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gift.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save a Gift for a Specific Event
  Future<void> saveGiftForEvent(String userId, String eventId, Gift gift) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(gift.giftId)
          .set(gift.toFirestore());
    } catch (e) {
      print('Error saving gift: $e');
    }
  }

  // Get All Gifts for a Specific Event
  Stream<List<Gift>> getGiftsForEvent(String userId, String eventId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(eventId)
        .collection('gifts')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Gift.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update a Gift's Details
  Future<void> updateGift(String userId, String eventId, Gift gift) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(gift.giftId)
          .update(gift.toFirestore());
    } catch (e) {
      print('Error updating gift: $e');
    }
  }

  // Delete a Gift
  Future<void> deleteGift(String userId, String eventId, String giftId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .delete();
    } catch (e) {
      print('Error deleting gift: $e');
    }
  }

  // Pledge a Gift
  Future<void> pledgeGift(String userId, String eventId, String giftId, String pledgedBy) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({
        'status': 'pledged',
        'pledgedBy': pledgedBy,
      });
    } catch (e) {
      print('Error pledging gift: $e');
    }
  }

  // Mark a Gift as Purchased
  Future<void> markGiftAsPurchased(String userId, String eventId, String giftId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('events')
          .doc(eventId)
          .collection('gifts')
          .doc(giftId)
          .update({'status': 'purchased'});
    } catch (e) {
      print('Error marking gift as purchased: $e');
    }
  }
}
