import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String eventId;
  final String userId; 
  final String name;
  final String category;
  final String status;
  final String location;
  final Timestamp date;
  final List<String> giftIds;

  Event({
    required this.eventId,
    required this.userId,
    required this.name,
    required this.category,
    required this.status,
    required this.location,
    required this.date,
    required this.giftIds,
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
      giftIds: List<String>.from(data['giftIds']),
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
      'giftIds': giftIds,
    };
  }
}
