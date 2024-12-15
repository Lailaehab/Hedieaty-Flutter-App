class Gift {
  String giftId;
  String eventId; // ID of the event this gift belongs to
  String name;
  String description;
  String category;
  double price;
  String status; // "available", "pledged"
  String? pledgedBy; // User ID of the person who pledged this gift
  String? imageUrl;
  String ownerId;

  Gift({
    required this.giftId,
    required this.eventId,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    required this.ownerId,
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
      price: (data['price'] as num).toDouble(),
      status: data['status'],
      pledgedBy: data['pledgedBy'],
      imageUrl: data['imageUrl'],
      ownerId: data['ownerId']
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
      'ownerId':ownerId,
    };
  }
}
