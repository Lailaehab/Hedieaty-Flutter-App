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

void main() {
  runApp(HedieatyApp());
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
      // initialRoute: '/',
      routes: {
        // '/': (context) => HomePage(),
        '/myEvents': (context) => MyEventListPage(),
        '/friendEvents': (context) => FriendEventListPage(),
        '/myGifts': (context) => MyGiftListPage(),
        '/friendGifts': (context) => FriendGiftListPage(),
        '/myGiftDetails': (context) => MyGiftDetailsPage(),
        '/pledgedGifts': (context) => MyPledgedGiftsPage(),
        '/profile': (context) => ProfilePage(),
        '/createEvent': (context) => CreateEvent(),
      },
      home: MainNavigationPage(),
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