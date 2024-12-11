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
          case'/signup': return MaterialPageRoute(
              builder: (context) => SignUpScreen(),);
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
          default:
            return null;
        }
      },

      // routes: {
      //   '/signup': (context) => SignUpScreen(),
      //   '/home': (context) => HomePage(),
      //   '/myEvents': (context) => MyEventListPage(),
      //   '/friendEvents': (context) => FriendEventListPage(),
      //   '/myGifts': (context) => MyGiftListPage(),
      //   '/friendGifts': (context) => FriendGiftListPage(),
      //   '/myGiftDetails': (context) => MyGiftDetailsPage(),
      //   '/pledgedGifts': (context) => MyPledgedGiftsPage(),
      //   '/profile': (context) => ProfilePage(),
      //   '/createEvent': (context) => CreateEvent(),
      // },
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    MyEventListPage(),
    MyPledgedGiftsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Pledged Gifts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}