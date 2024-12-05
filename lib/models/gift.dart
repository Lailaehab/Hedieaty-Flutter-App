import 'package:cloud_firestore/cloud_firestore.dart';

class Gift {
  final String giftId;
  final String eventId; // ID of the event this gift belongs to
  final String name;
  final String description;
  final String category;
  final double price;
  final String status; // e.g., "available", "pledged", "purchased"
  final String? pledgedBy; // User ID of the person who pledged this gift
  final String? imageUrl;

  Gift({
    required this.giftId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.pledgedBy,
    this.imageUrl,
  });

  factory Gift.fromFirestore(String giftId, Map<String, dynamic> data) {
    return Gift(
      giftId: giftId,
      eventId: data['eventId'],
      name: data['name'],
      description: data['description'],
      category: data['category'],
      price: data['price'],
      status: data['status'],
      pledgedBy: data['pledgedBy'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'pledgedBy': pledgedBy,
      'imageUrl': imageUrl,
    };
  }
}
