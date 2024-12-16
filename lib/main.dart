import 'package:flutter/material.dart';
import 'home_page.dart';
import 'my_event_list.dart';
import 'my_gift_details.dart';
import 'my_gift_list.dart';
import 'friend_event_list.dart';
import 'friend_gift_list.dart';
import 'profile_page.dart';
import 'create_event.dart';
import 'my_pledged_gifts.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'signup.dart';
import 'add_gift.dart';
import 'edit_event.dart';
import 'models/event.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(HedieatyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/signup',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/myGifts':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => MyGiftListPage(eventId: args['eventId']),
            );
          case '/myGiftDetails':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => MyGiftDetailsPage(giftId: args['giftId']),
            );
          case '/addGift':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AddGiftPage(eventId: args['eventId']),
            );
          case '/signup':
            return MaterialPageRoute(
              builder: (context) => SignUpScreen(),
            );
          case '/login':
            return MaterialPageRoute(
              builder: (context) => LoginPage(),
            );
          case '/home':
            return MaterialPageRoute(
              builder: (context) => HomePage(),
            );
          case '/myEvents':
            return MaterialPageRoute(
              builder: (context) => MyEventListPage(),
            );
          case '/friendEvents':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FriendEventListPage(friendId: args['friendId']),
            );
          case '/friendGifts':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FriendGiftListPage(eventId: args['eventId']),
            );
          case '/pledgedGifts':
            return MaterialPageRoute(
              builder: (context) => MyPledgedGiftsPage(),
            );
          case '/profile':
            return MaterialPageRoute(
              builder: (context) => ProfilePage(),
            );
          case '/createEvent':
            return MaterialPageRoute(
              builder: (context) => CreateEvent(),
            );
          case '/editEvent':
            final args = settings.arguments as Map<String, dynamic>;
            final event = args['event'] as Event;
            return MaterialPageRoute(
              builder: (context) => EditEvent(event: event),
            );
          default:
            return null;
        }
      },
    );
  }
}

// Notification Listener Widget
class NotificationListenerWidget extends StatefulWidget {
  final Widget child;

  NotificationListenerWidget({required this.child});

  @override
  _NotificationListenerWidgetState createState() =>
      _NotificationListenerWidgetState();
}

class _NotificationListenerWidgetState extends State<NotificationListenerWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .where('userId', isEqualTo: FirebaseMessaging.instance.getToken() ?? '')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => {...doc.data(), 'id': doc.id})
              .toList()),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading notifications.'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          for (var notification in snapshot.data!) {
            // Trigger dialog for new notification
            Future.delayed(Duration.zero, () {
              _showPopupDialog(context, notification);
            });
          }
        }

        return widget.child; // Return the actual content of the page
      },
    );
  }

  void _showPopupDialog(BuildContext context, Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['title'] ?? 'New Notification'),
          content: Text(notification['message'] ?? 'You have a new message.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
