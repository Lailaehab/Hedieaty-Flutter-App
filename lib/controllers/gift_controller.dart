import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/gift.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all gifts for an event
Stream<List<Map<String, dynamic>>> getGiftsForEvent(String eventId) {
  return _firestore
      .collection('gifts')
      .where('eventId', isEqualTo: eventId)
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
}


  // Fetch gift by ID
  Future<Map<String, dynamic>?> getGiftById(String giftId) async {
    final docSnapshot = await _firestore.collection('gifts').doc(giftId).get();

    if (docSnapshot.exists) {
      return {...docSnapshot.data()!, 'id': docSnapshot.id};
    } else {
      return null; // Return null if the document does not exist
    }
  }

  // Create a gift for an event
  Future<void> createGift(Gift gift) async {
    await FirebaseFirestore.instance
        .collection('gifts')
        .doc(gift.giftId)
        .set(gift.toFirestore());
  }

  // Update a gift
  Future<void> updateGift(String giftId, Map<String, dynamic> data) async {
    await _firestore.collection('gifts').doc(giftId).update(data);
  }

  // Delete a gift
  Future<void> deleteGift(String giftId) async {
    await _firestore.collection('gifts').doc(giftId).delete();
  }

  // Pledge a gift
  Future<void> pledgeGift(String giftId, String pledgedBy) async {
    await _firestore.collection('gifts').doc(giftId).update({
      'status': 'pledged',
      'pledgedBy': pledgedBy,
    });
    _sendNotification(pledgedBy, giftId);
  }

  // Send a notification to the gift owner
  Future<void> _sendNotification(String pledgedBy, String giftId) async {
    final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
    final eventSnapshot = await _firestore
        .collection('events')
        .doc(giftSnapshot.data()!['eventId'])
        .get();

    final eventName = eventSnapshot.data()!['name'];

    // Assume a Firebase Messaging Service is integrated
    print(
        'Notification: $pledgedBy pledged a gift for the event "$eventName".');
  }
}
