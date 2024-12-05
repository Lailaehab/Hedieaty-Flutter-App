import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../controllers/authentication_controller.dart';

class MyEventListPage extends StatelessWidget {
  final EventController _eventController = EventController();
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's ID
    final user = _authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Events')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('My Events')),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getEventsForUser(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found.'));
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
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // Handle navigation to event details or gift list
                    Navigator.pushNamed(context, '/myGifts');
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
