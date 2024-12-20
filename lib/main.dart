import 'package:flutter/material.dart';
import 'package:hedieaty/services/user_manager.dart';
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
import 'signup.dart';
import 'add_gift.dart';
import 'edit_event.dart';
import 'models/event.dart';
import 'models/gift.dart';
import 'login.dart';
import './services/global_notifications.dart';
final GlobalKey <NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Request notifications permissions
  await FCMService.requestPermission();
  // Initialize FCM Service and notifications service
  FCMService? fcmServiceInstance = await FCMService.initialize();
  UserManager.updateFCMService(fcmServiceInstance);

  // await FirebaseApi().initNotification();
    // AuthController authController = AuthController();

    // final user = authController.getCurrentUser();
    // if (user == null) {
    //   runApp(MaterialApp(
    //         debugShowCheckedModeBanner: false,
    //         home: LoginPage(),)
    //   );
    // }
    // else{
    // final UserId = user.uid;}
  // FirestoreSyncController syncController = FirestoreSyncController(userId:UserId);
  // syncController.startSyncing();
  // FirebaseMessaging messaging = FirebaseMessaging.instance;
  // await messaging.requestPermission();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(HedieatyApp());
}


class HedieatyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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
            final gift = args['gift'] as Gift;
            return MaterialPageRoute(
              builder: (context) => MyGiftDetailsPage(gift: gift),
            );
          case '/addGift':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => AddGiftPage(eventId: args['eventId']),
            );
          case'/signup': return MaterialPageRoute(
              builder: (context) => SignUpScreen(),);
          case'/login': return MaterialPageRoute(
              builder: (context) => LoginPage(),);
          case'/home': return MaterialPageRoute(
                builder: (context) => HomePage(),);
          case'/myEvents':return MaterialPageRoute(
                builder: (context) => MyEventListPage(),);
          case'/friendEvents':final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FriendEventListPage(friendId: args['friendId']),);
          case'/friendGifts': final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => FriendGiftListPage(eventId: args['eventId']),
            );
          case'/pledgedGifts': return MaterialPageRoute(
                builder:(context) => MyPledgedGiftsPage(),);
          case'/profile': return MaterialPageRoute(
                builder:(context) => ProfilePage(),);
          case'/createEvent': return MaterialPageRoute(
                builder:(context) => CreateEvent(),);
          case '/editEvent':final args = settings.arguments as Map<String, dynamic>;
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