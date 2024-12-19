import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/database.dart';
import 'package:flutter/material.dart';
import 'authentication_controller.dart';

class PublishingController {
final AuthController authController = AuthController();

Future<void> syncEventsAndGiftsToFirestore(String userId) async {
  final db = await DatabaseHelper().database;

  try {
    // Fetch all events from local database
    List<Map<String, dynamic>> events = await db.query('Events', where: 'user_id = ?', whereArgs: [userId]);

    // Upload events to Firestore
    for (var event in events) {
      String eventId = event['id']; //'id' is the event primary key

      await FirebaseFirestore.instance.collection('events').doc(eventId).set({
        'eventId': eventId,
        'userId': userId,
        'name': event['name'],
        'category': event['category'],
        'status': event['status'],
        'location': event['location'],
        'date': event['date'],
      });

      // Fetch gifts related to this event
      List<Map<String, dynamic>> gifts = await db.query('Gifts', where: 'event_id = ?', whereArgs: [eventId]);

      // Upload gifts to Firestore
      for (var gift in gifts) {
        String giftId = gift['id'];
        await FirebaseFirestore.instance.collection('gifts').doc(giftId).set({
          'giftId' : giftId,
          'name': gift['name'],
          'description': gift['description'],
          'category': gift['category'],
          'price': gift['price'],
          'status': gift['status'],
          'eventId': eventId,
          'imageUrl': gift['imageUrl'],
          'pledgedBy': null, // Default
          'ownerId': userId,
        });
      }
    }
  } catch (e) {
    print("Error syncing events and gifts: $e");
  }
}

  Future<void> showSyncAlertDialog(BuildContext context, String userId) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Save Data'),
        content: Text('Do you want to save your events and gifts to Firestore before logging out?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () async {
              await syncEventsAndGiftsToFirestore(userId);
              await authController.logOut();
              Navigator.of(context).pushReplacementNamed('/signup');
            },
          ),
        ],
      );
    },
  );
}

// Function to publish a single event and its gifts to Firestore
Future<void> publishEvent( String eventId) async {
  final db = await DatabaseHelper().database;
  try {
    //Fetch the event from the local database using its ID
    List<Map<String, dynamic>> eventResult = await db.query(
      'Events',
      where: 'id = ?',
      whereArgs: [eventId],
    );

    // Check if the event exists
    if (eventResult.isEmpty) {
      print("Event not found in the local database.");
      return;
    }

    // Extract the event data
    var event = eventResult.first;

        await db.update(
      'Events',
      {'published': 'true'},
      where: 'id = ?',
      whereArgs: [eventId],
    );
    print("Event 'published' field updated in local database.");


    //  Upload the event to Firestore
    await FirebaseFirestore.instance.collection('events').doc(eventId).set({
      'userId': event['userId'],
      'name': event['name'],
      'category': event['category'], 
      'status': event['status'],
      'location': event['location'],
      'date': event['date'],
      'published':event['published'],
    });

    print("Event uploaded successfully: $eventId");

    // Fetch all gifts associated with this event
    List<Map<String, dynamic>> giftsResult = await db.query(
      'Gifts',
      where: 'eventId = ?',
      whereArgs: [eventId],
    );

    // Upload each gift to Firestore
    for (var gift in giftsResult) {
      String giftId = gift['id'].toString();

      await FirebaseFirestore.instance.collection('gifts').doc(giftId).set({
        'name': gift['name'],
        'description': gift['description'],
        'category': gift['category'],
        'price': gift['price'],
        'status': gift['status'],
        'eventId': eventId,
        'imageUrl': gift['imageUrl'],
        'pledgedBy': null, // Default value for pledgedBy
      });

      print("Gift uploaded successfully: $giftId");
    }

    print("All gifts for event $eventId uploaded successfully.");
  } catch (e) {
    print("Error publishing event and gifts: $e");
  }
}

}
