import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
   String eventId;
   String userId; 
   String name;
   String category;
   String status;
   String location;
   Timestamp date;
   String published;

  Event({
    required this.eventId,
    required this.userId,
    required this.name,
    required this.category,
    required this.status,
    required this.location,
    required this.date,
    required this.published,
  });

  factory Event.fromFirestore(String eventId, Map<String, dynamic> data) {
    return Event(
      eventId: eventId,
      userId: data['userId'], 
      name: data['name'],
      category: data['category'],
      status: data['status'],
      location: data['location'],
      date: data['date'],
      published:data['published'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId, 
      'name': name,
      'category': category,
      'status': status,
      'location': location,
      'date': date,
      'published':published,
    };
  }
    // Factory constructor for SQLite data
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventId: map['id'].toString(), 
      userId: map['userId'].toString(),
      name: map['name'],
      category: map['category'], 
      status: map['status'],
      location: map['location'],
      date: Timestamp.fromDate(DateTime.parse(map['date'])), // Parse SQLite TEXT date
      published: map['published']
    );
  }

  // Convert Event object to SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': eventId, // SQLite uses 'id' for primary keys
      'userId': userId,
      'name': name,
      'category': category,
      'status': status,
      'location': location,
      'date': date.toDate().toIso8601String(), // Convert Timestamp to ISO string
      'published':published,
    };
  }

}
