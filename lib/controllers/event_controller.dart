import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/services/database.dart';
import '/models/event.dart';
import 'package:intl/intl.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> saveEvent(Event event) async {
    try {
      print("########### Editing the Database table Events##########");
      await _databaseHelper.updateEvent(event);
      if(event.published == 'true'){
        await _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
      }
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  Stream<List<Event>> getEventsForUser(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  Future<Event?> getEvent(String eventId) async {
    // try {
    //   final snapshot = await _firestore.collection('events').doc(eventId).get();
    //   if (snapshot.exists) {
    //     return Event.fromFirestore(eventId, snapshot.data()!);
    //   }
    // } catch (e) {
    //   print('Error fetching event: $e');
    // }
    // return null;
    return await _databaseHelper.getEvent(eventId);
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      // Fetch gifts associated with the event
      final gifts = await _databaseHelper.getGiftsByEventId(eventId);
      
      // Delete each gift from Firestore and SQLite
      for (var gift in gifts) {
            await _databaseHelper.deleteGift(gift.giftId);
     try {
      await _firestore.collection('gifts').doc(gift.giftId).delete();
    } catch (e) {
      print('Error deleting gift: $e');
    }
      }

      // Delete the event from Firestore
      await _firestore.collection('events').doc(eventId).delete();
      
      // Delete the event from SQLite
      await _databaseHelper.deleteEvent(eventId);
      
    } catch (e) {
      print('Error deleting event and its gifts: $e');
    }
  }

    String getEventStatus(Timestamp eventDate,Event event) {
        final DateTime now = DateTime.now();
  final DateTime eventDateTime = eventDate.toDate();
  final DateTime eventDateOnly = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);
  final DateTime nowDateOnly = DateTime(now.year, now.month, now.day);

  if (eventDateOnly.isBefore(nowDateOnly)) {
    event.status = 'Past';
    _databaseHelper.updateEventStatus(event.eventId, 'Past'); 
      if (event.published == 'true'){
     _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
  }
    return 'Past';
  } else if (eventDateOnly.isAtSameMomentAs(nowDateOnly)) {
    event.status = 'Current';
    _databaseHelper.updateEventStatus(event.eventId, 'Current');
      if (event.published == 'true'){
     _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
  }
    return 'Current';
  } else if (eventDateOnly.isAfter(nowDateOnly)) {
    event.status = 'Upcoming';
    _databaseHelper.updateEventStatus(event.eventId, 'Upcoming'); 
      if (event.published == 'true'){
     _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
  }
    return 'Upcoming';
  }

  event.status = 'Unknown';
  _databaseHelper.updateEventStatus(event.eventId, 'Unknown'); 
    if (event.published == 'true'){
     _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
  }
  return 'Unknown';

}
  
    String formatEventTime(Timestamp eventDate) {
    final eventDateTime = eventDate.toDate();
    return DateFormat('HH:mm').format(eventDateTime);
  }

  // Method to fetch events for a specific user
  Future<List<Event>> getDbEventsByUser(String userId) async {
    try {
      print("############Fetching Database Events##########");
      return await _databaseHelper.getEventsByUserId(userId); 
    } catch (e) {
      print('Error fetching events: $e');
      return [];
    }
  }

}
