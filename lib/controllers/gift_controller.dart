import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/gift.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GiftController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Stream<List<Map<String, dynamic>>> getGiftsForEvent(String eventId) {
  return _firestore
      .collection('gifts')
      .where('eventId', isEqualTo: eventId)
      .snapshots()
      .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
}

  Future<Map<String, dynamic>?> getGiftById(String giftId) async {
    final docSnapshot = await _firestore.collection('gifts').doc(giftId).get();

    if (docSnapshot.exists) {
      return {...docSnapshot.data()!, 'id': docSnapshot.id};
    } else {
      return null; 
    }
  }

  Future<void> createGift(Gift gift) async {
    await FirebaseFirestore.instance
        .collection('gifts')
        .doc(gift.giftId)
        .set(gift.toFirestore());
  }

  Future<void> updateGift(String giftId, Map<String, dynamic> data) async {
    await _firestore.collection('gifts').doc(giftId).update(data);
  }

  Future<void> deleteGift(String giftId) async {
    await _firestore.collection('gifts').doc(giftId).delete();
  }

  Future<String> getGiftOwner(String giftId) async {
    final giftSnapshot = await _firestore.collection('gifts').doc(giftId).get();
    final giftData = giftSnapshot.data()!;
    final eventId = giftData['eventId'];

    final eventSnapshot = await _firestore.collection('events').doc(eventId).get();
    final eventOwnerId = eventSnapshot.data()?['userId']; 
    final eventOwnerSnapshot = await _firestore.collection('users').doc(eventOwnerId).get();
    final eventOwnerName = eventOwnerSnapshot.data()?['name'] ?? 'Event Owner';
    return eventOwnerName;
    }

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
  final eventData = eventSnapshot.data();
  final eventName = eventData?['name'] ?? 'Event Name';

  await _firestore.collection('gifts').doc(giftId).update({
    'status': 'pledged',
    'pledgedBy': currentUserId,
  });

  final userRef = _firestore.collection('users').doc(currentUserId);
  await userRef.update({
    'pledgedGifts': FieldValue.arrayUnion([giftId]),
  });

  await _firestore.collection('notifications').add({
    'userId': eventOwnerId,
    'title': 'Gift Pledged',
    'message': 'Hey $eventOwnerName, $currentUserName pledged to buy "${giftData['name']}" from the event "$eventName.',
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

    final FirebaseAuth auth = FirebaseAuth.instance;
    final currentUserId = auth.currentUser?.uid;

  if (currentUserId == null) {
    print('No user logged in.');
    return;
  }

    final currentUserSnapshot = await _firestore.collection('users').doc(currentUserId).get();
    final currentUserName = currentUserSnapshot.data()?['name'] ?? 'Unknown User';

    final giftData = giftSnapshot.data()!;
    final eventId = giftData['eventId'];

    final eventSnapshot = await _firestore.collection('events').doc(eventId).get();
    final eventOwnerId = eventSnapshot.data()?['userId']; 
    final eventOwnerSnapshot = await _firestore.collection('users').doc(eventOwnerId).get();
    final eventOwnerName = eventOwnerSnapshot.data()?['name'] ?? 'Event Owner';
    final eventData = eventSnapshot.data();
    final eventName = eventData?['name'] ?? 'Event Name';

    await _firestore.collection('gifts').doc(giftId).update({
      'status': 'available',
      'pledgedBy': FieldValue.delete(),
    });

    final userRef = _firestore.collection('users').doc(userId);
    await userRef.update({
      'pledgedGifts': FieldValue.arrayRemove([giftId]),
    });

    await _firestore.collection('notifications').add({
      'userId': eventOwnerId,
      'title': 'Gift Unpledged',
      'message': 'Hey $eventOwnerName, $currentUserName unpledged "${giftData['name']}" from the event "$eventName.',
      'timestamp': FieldValue.serverTimestamp(),
      'read': false,
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
