import 'package:flutter/material.dart';

class MainNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainNavigationBar({
    required this.currentIndex,
    required this.onTap,
  }) ;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.teal,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      onTap: onTap,
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
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_active),
          label: 'Notifications',
        ),
      ],
    );
  }
}
