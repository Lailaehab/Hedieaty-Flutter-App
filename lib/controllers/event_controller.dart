import 'package:cloud_firestore/cloud_firestore.dart';
import '/models/event.dart';

class EventController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create or Update an Event
  Future<void> saveEvent(Event event) async {
    try {
      await _firestore.collection('events').doc(event.eventId).set(event.toFirestore());
    } catch (e) {
      print('Error saving event: $e');
    }
  }

  // Retrieve an Event by ID
  Future<Event?> getEvent(String eventId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('events').doc(eventId).get();
      if (snapshot.exists) {
        return Event.fromFirestore(snapshot.id, snapshot.data() as Map<String, dynamic>);
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

  // Stream to listen for real-time updates to all Events
  Stream<List<Event>> getEvents() {
    return _firestore
        .collection('events')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Event.fromFirestore(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}