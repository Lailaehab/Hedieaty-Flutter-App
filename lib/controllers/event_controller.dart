import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/event.dart';
import 'package:intl/intl.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save an Event
  Future<void> saveEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  // Get Events for a Specific User
  Stream<List<Event>> getEventsForUser(String userId) {
    return _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Retrieve an Event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      final snapshot = await _firestore.collection('events').doc(eventId).get();
      if (snapshot.exists) {
        return Event.fromFirestore(eventId, snapshot.data()!);
      }
    } catch (e) {
      print('Error fetching event: $e');
    }
    return null;
  }

  // Delete an Event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

  // Get the status of an event
  // String getEventStatus(Timestamp eventDate) {
  //   final DateTime eventDateTime = eventDate.toDate();
  //   final DateTime now = DateTime.now();
  //   if (eventDateTime.isBefore(now) && eventDateTime.day != now.day) {
  //     return 'Past';
  //   } else if (eventDateTime.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
  //     return 'Current';
  //   } else if (eventDateTime.isAfter(now)) {
  //     return 'Upcoming';
  //   }
  //   return 'Unknown';
  // }
    String getEventStatus(Timestamp eventDate) {
    final DateTime eventDateTime = eventDate.toDate();
    final DateTime now = DateTime.now();

    // Extract date parts for comparison
    final DateTime eventDateOnly = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);
    final DateTime nowDateOnly = DateTime(now.year, now.month, now.day);

    if (eventDateOnly.isBefore(nowDateOnly)) {
      return 'Past';
    } else if (eventDateOnly.isAtSameMomentAs(nowDateOnly)) {
      return 'Current';
    } else if (eventDateOnly.isAfter(nowDateOnly)) {
      return 'Upcoming';
    }
    return 'Unknown';
  }

    String formatEventTime(Timestamp eventDate) {
    final eventDateTime = eventDate.toDate();
    return DateFormat('HH:mm').format(eventDateTime);
  }
}
