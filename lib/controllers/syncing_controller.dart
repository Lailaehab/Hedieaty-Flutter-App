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
 
    // Listen to Firestore 'gifts' collection
    giftSubscription = FirebaseFirestore.instance
        .collection('gifts').where('ownerId', isEqualTo: 'userId') 
        .where('status', isEqualTo: 'available') 
        .snapshots()
        .listen((giftSnapshot) async {
      Database db = await DatabaseHelper().database; 
      for (var docChange in giftSnapshot.docChanges) {
        final data = docChange.doc.data() as Map<String, dynamic>;

         if (docChange.type == DocumentChangeType.modified) {

              await _insertOrUpdateGift(db, data);
          }
        }
      }
    );
  }

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

  /// Stop syncing when needed
  void stopSyncing() {
    eventSubscription.cancel();
    giftSubscription.cancel();
    print("Firestore sync stopped.");
  }
}
