import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hedieaty/services/database.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Helper function to update FCM Token in Firestore
  Future<void> _updateFcmToken(String userId) async {
    try {
      String? fcmToken = await _messaging.getToken();
      if (fcmToken != null) {
        await _firestore.collection('users').doc(userId).update({'fcmToken': fcmToken});
        print('FCM Token updated: $fcmToken');
      }
    } catch (e) {
      print('Error updating FCM Token: $e');
    }
  }

  Future<String?>getFcmToken(String ownerId) async{
  try {
    // Fetch the user document by ID
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(ownerId).get();

    if (userDoc.exists) {
      // Extract the FCM token
      String? fcmToken = userDoc['fcmToken'];
      if (fcmToken != null && fcmToken.isNotEmpty) {
        return fcmToken;
      } else {
        print('FCM token is not available for user with ID: $ownerId');
        return null;
      }
    } else {
      print('User document does not exist for ID: $ownerId');
      return null;
    }
  } catch (e) {
    print('Error fetching FCM token: $e');
    return null;
  }
}
  Future<String?> signUp(String name, String email, String password, String phoneNumber) async {
    try {
      // Validate email and password
      if (email.isEmpty || password.length < 6) {
        throw Exception("Invalid email or password.");
      }

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = credential.user!.uid;

      // Add user to Firestore
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'profilePicture': 'assets/default_profile.jpg', // Placeholder
        'friends': [],
        'pledgedGifts': [],
        'notificationsEnabled':true,
      });

      // Update FCM Token
      await _updateFcmToken(userId);

      // 3. Fetch and store locally in SQLite
    await saveUserLocally(userId, email,name, phoneNumber, 'assets/default_profile.jpg');

      return userId;
    } catch (e) {
      print('Sign-Up Error: $e');
      return null;
    }
  }

  // Save User Data to SQLite
Future<void> saveUserLocally(String authId, String email,String name, String phoneNumber, String profilePicturePath) async {
  final db = await DatabaseHelper().database; // Access the local database
  await db.insert('Users', {
    'id': authId,
    'email': email,
    'name':name,
    'phone_number': phoneNumber,
    'profile_picture': profilePicturePath,
    'notificationsEnabled': true,
  });
}

  Future<User?> logIn(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = credential.user!.uid;

      // Update FCM Token on login
      await _updateFcmToken(userId);
      // Store all data locally
      await storeUserDataLocally(userId);
      return credential.user;

    } on FirebaseAuthException catch (e) {
      print('Log-In Error: ${e.message}');
      return null;
    }
  }

  Future<void> logOut() async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId != null) {
        // Optionally, remove FCM Token on logout
        await _firestore.collection('users').doc(userId).update({'fcmToken': null});
        print('FCM Token removed on logout.');
      }
      await _auth.signOut();
    } catch (e) {
      print('Log-Out Error: $e');
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.updatePassword(newPassword);
        await currentUser.reload();
        currentUser = _auth.currentUser;
      }
    } catch (e) {
      throw Exception("Error updating password: $e");
    }
  }

  Future<void> storeUserDataLocally(String userId) async {
  try {
    final db = await DatabaseHelper().database;

    // Fetch user data
    final userSnapshot = await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      await db.insert('Users', {
        'id': userId,
        'name': userData?['name'] ,
        'email': userData?['email'],
        'phone_number': userData?['phoneNumber'] ,
        'profile_picture': userData?['profilePicture'] ?? '',
        'notificationsEnabled':userData?['notificationsEnabled'],
      });
    }

    // Fetch events linked to userId
    final eventsSnapshot = await _firestore
        .collection('events')
        .where('userId', isEqualTo: userId)
        .get();

    for (var eventDoc in eventsSnapshot.docs) {
      final eventData = eventDoc.data();
      final eventId = eventDoc.id;

      await db.insert('Events', {
        'id': eventId,
        'name': eventData['name'],
        'category': eventData['category'] ,
        'date': eventData['date'].toDate().toString(),
        'status': eventData['status'] ,
        'location': eventData['location'] ,
        'userId': userId,
        'published':eventData['published'],
      });

      // Fetch gifts for this event
      final giftsSnapshot = await _firestore
          .collection('gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      for (var giftDoc in giftsSnapshot.docs) {
        final giftData = giftDoc.data();
        await db.insert('Gifts', {
          'id': giftDoc.id,
          'name': giftData['name'] ,
          'description': giftData['description'] ,
          'category': giftData['category'] ,
          'status': giftData['status'] ?? 'available',
          'price': giftData['price'] ,
          'imageUrl': giftData['image'] ?? '',
          'eventId': eventId,
          'ownerId': giftData['ownerId'],
        });
      }
    }

    print("User data, events, and gifts stored locally.");
  } catch (e) {
    print("Error storing data locally: $e");
  }
}
  
}
