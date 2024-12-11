import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'friend_gift_list.dart';
import 'models/event.dart';
import '/controllers/event_controller.dart';

class FriendEventListPage extends StatelessWidget {
  final String friendId;
  final EventController _eventController = EventController();

  FriendEventListPage({required this.friendId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friend's Events")),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getEventsForUser(friendId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          final events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text(
                    'Category: ${event.category}\n'
                    'Date: ${event.date.toDate().toString().split(' ')[0]}\n'
                    'Location: ${event.location}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 30.0, // Set the desired size
                        color: Colors.green, // Set the desired color
                      ),
                      SizedBox(width: 8.0), // Spacing between icon and text
                      Text(
                        'View Gifts',
                        style: TextStyle(color: Colors.green), // Match text color with icon
                      ),
                    ],
                  ),
                  onTap: () {
                    // Handle navigation to event details or gift list
                    Navigator.pushNamed(
                      context,
                      '/friendGifts',
                      arguments: {'eventId': event.eventId},
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
