import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<String> getGiftOwner(String giftId) async {
    final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
    final giftData = giftSnapshot.data()!;
    final eventId = giftData['eventId'];

    // Fetch event data to get the event owner's ID (Alex in the example)
    final eventSnapshot = await _firestore.collection('events').doc(eventId).get();
    final eventOwnerId = eventSnapshot.data()?['userId']; // Assuming the event has a userId field
    final eventOwnerSnapshot = await _firestore.collection('users').doc(eventOwnerId).get();
    final eventOwnerName = eventOwnerSnapshot.data()?['name'] ?? 'Event Owner';
    return eventOwnerName;
    }
  // Pledge a gift
Future<void> pledgeGift(String giftId, String pledgedBy) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final currentUserId = auth.currentUser?.uid;

  if (currentUserId == null) {
    print('No user logged in.');
    return;
  }

  final currentUserSnapshot = await _firestore.collection('users').doc(currentUserId).get();
  final currentUserName = currentUserSnapshot.data()?['name'] ?? 'Unknown User';

  final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
  final giftData = giftSnapshot.data()!;
  final eventId = giftData['eventId'];

  final eventSnapshot = await _firestore.collection('events').doc(eventId).get();
  final eventOwnerId = eventSnapshot.data()?['userId']; 
  final eventOwnerSnapshot = await _firestore.collection('users').doc(eventOwnerId).get();
  final eventOwnerName = eventOwnerSnapshot.data()?['name'] ?? 'Event Owner';

  await _firestore.collection('gifts').doc(giftId).update({
    'status': 'pledged',
    'pledgedBy': currentUserId,
  });

  final userRef = _firestore.collection('users').doc(currentUserId);
  await userRef.update({
    'pledgedGifts': FieldValue.arrayUnion([giftId]),
  });
  // Add notification for the gift list creator
  await _firestore.collection('notifications').add({
    'userId': eventOwnerId,
    'title': 'Gift Pledged',
    'message': '$currentUserName pledged to buy "${giftData['name']}" for your event.',
    'timestamp': FieldValue.serverTimestamp(),
    'read': false,
  });
}

  Future<void> unpledgeGift(String giftId, String userId) async {
    final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
    if (!giftSnapshot.exists) {
      print("Gift does not exist.");
      return;
    }

    await _firestore.collection('gifts').doc(giftId).update({
      'status': 'available',
      'pledgedBy': FieldValue.delete(),
    });

    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'pledgedGifts': FieldValue.arrayRemove([giftId]),
    });

    print("Gift unpledged successfully.");
  }

  Future<DateTime?> getGiftDueDate(String giftId) async {
  final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
  final giftData = giftSnapshot.data();
  
  if (giftData == null) {
    return null;
  }

  final eventId = giftData['eventId'];
  final eventSnapshot = await _firestore.collection('events').doc(eventId).get();
  final eventData = eventSnapshot.data();
  
  if (eventData == null) {
    return null;
  }
  
  return (eventData['date'] as Timestamp).toDate();
}

Future<void> updateGiftImageUrl(String giftId, String imageUrl) async {
    await _firestore.collection('gifts').doc(giftId).update({
      'imageUrl': imageUrl,
    });
  }
}
