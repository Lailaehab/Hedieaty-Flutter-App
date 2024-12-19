import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/services/database.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart';

class FirestoreSyncController {
  final String userId;
  late StreamSubscription eventSubscription;
  late StreamSubscription giftSubscription;

  FirestoreSyncController({required this.userId});

  /// Initialize the controller to start syncing
  void startSyncing() {
    // Listen to Firestore 'events' collection
    // eventSubscription = FirebaseFirestore.instance
    //     .collection('events')
    //     .snapshots()
    //     .listen((eventSnapshot) async {
    //   Database db = await DatabaseHelper().database; // Await database instance
    //   for (var docChange in eventSnapshot.docChanges) {
    //     final data = docChange.doc.data() as Map<String, dynamic>;

    //     // Check if the event belongs to the current user
    //     if (data['userId'] == userId) {
    //       switch (docChange.type) {
    //         case DocumentChangeType.added:
    //         case DocumentChangeType.modified:
    //           await _insertOrUpdateEvent(db, data);
    //           break;
    //         case DocumentChangeType.removed:
    //           await _deleteEvent(db, data['eventId']);
    //           break;
    //       }
    //     }
    //   }
    // });

    // Listen to Firestore 'gifts' collection
    giftSubscription = FirebaseFirestore.instance
        .collection('gifts').where('ownerId', isEqualTo: 'userId') 
        .where('status', isEqualTo: 'available') 
        .snapshots()
        .listen((giftSnapshot) async {
      Database db = await DatabaseHelper().database; // Await database instance
      for (var docChange in giftSnapshot.docChanges) {
        final data = docChange.doc.data() as Map<String, dynamic>;

        // Check if the gift belongs to an event in the local database
        // List<Map<String, dynamic>> eventResult = await db.query(
        //   'Events',
        //   where: 'id = ?',
        //   whereArgs: [data['eventId']],
        // );

        // if (eventResult.isNotEmpty) {
        //   switch (docChange.type) {
        //     case DocumentChangeType.added:
        //     case DocumentChangeType.modified:
         if (docChange.type == DocumentChangeType.modified) {

              await _insertOrUpdateGift(db, data);
              // break;
            // case DocumentChangeType.removed:
            //   await _deleteGift(db, data['giftId']);
            //   break;
          }
        }
      }
    );
  }

  /// Insert or update an event in the local database
  // Future<void> _insertOrUpdateEvent(Database db, Map<String, dynamic> data) async {
  //   await db.insert(
  //     'Events',
  //     {
  //       'id': data['eventId'],
  //       'name': data['name'],
  //       'date': data['date'],
  //       'location': data['location'],
  //       'description': data['description'] ?? '',
  //       'user_id': data['userId'],
  //       'status': data['status'] ?? '',
  //     },
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  //   print("Event synced locally: ${data['eventId']}");
  // }

  // /// Delete an event from the local database
  // Future<void> _deleteEvent(Database db, String eventId) async {
  //   await db.delete(
  //     'Events',
  //     where: 'id = ?',
  //     whereArgs: [eventId],
  //   );
  //   print("Event deleted locally: $eventId");
  // }

  /// Insert or update a gift in the local database
  Future<void> _insertOrUpdateGift(Database db, Map<String, dynamic> data) async {
    await db.insert(
      'Gifts',
      {
        'id': data['giftId'],
        'name': data['name'],
        'description': data['description'],
        'category': data['category'],
        'price': data['price'],
        'status': data['status'] ,
        'eventId': data['eventId'],
        'imageUrl': data['imageUrl'] ?? '',
        'ownerId': userId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print("Gift synced locally: ${data['giftId']}");
  }

  /// Delete a gift from the local database
  // Future<void> _deleteGift(Database db, String giftId) async {
  //   await db.delete(
  //     'Gifts',
  //     where: 'id = ?',
  //     whereArgs: [giftId],
  //   );
  //   print("Gift deleted locally: $giftId");
  // }

  /// Stop syncing when needed
  void stopSyncing() {
    eventSubscription.cancel();
    giftSubscription.cancel();
    print("Firestore sync stopped.");
  }
}
