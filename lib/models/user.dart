class User {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? profilePicture;
  final List<String> friends;
  final List<String>? pledgedGifts;

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.profilePicture,
    required this.friends,
    this.pledgedGifts,
  });

  factory User.fromFirestore(String userId, Map<String, dynamic> data) {
    return User(
      userId: userId,
      name: data['name'],
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      profilePicture: data['profilePicture'],
      friends: List<String>.from(data['friends']),
      pledgedGifts: List<String>.from(data['pledgedGifts']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'friends': friends,
      'pledgedGifts': pledgedGifts,
    };
  }
}
