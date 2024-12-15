import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/event.dart';
import 'package:intl/intl.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
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

  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
    }
  }

    String getEventStatus(Timestamp eventDate,Event event) {
    final DateTime eventDateTime = eventDate.toDate();
    final DateTime now = DateTime.now();

    final DateTime eventDateOnly = DateTime(eventDateTime.year, eventDateTime.month, eventDateTime.day);
    final DateTime nowDateOnly = DateTime(now.year, now.month, now.day);

    if (eventDateOnly.isBefore(nowDateOnly)) {
      event.status='Past';
      _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
      return 'Past';
    } else if (eventDateOnly.isAtSameMomentAs(nowDateOnly)) {
      event.status='Current';
      _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
      return 'Current';
    } else if (eventDateOnly.isAfter(nowDateOnly)) {
      event.status='Upcoming';
      _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
      return 'Upcoming';
    }
    event.status='Unknown';
    _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
    return 'Unknown';
  }

    String formatEventTime(Timestamp eventDate) {
    final eventDateTime = eventDate.toDate();
    return DateFormat('HH:mm').format(eventDateTime);
  }
}
