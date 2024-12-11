import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../controllers/authentication_controller.dart';

class CreateEvent extends StatelessWidget {
  final EventController _eventController = EventController();
  final AuthController _authController = AuthController();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
              ),
              TextField(
                controller: _timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:MM)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  // Validate inputs
                  if (_nameController.text.isEmpty ||
                      _categoryController.text.isEmpty ||
                      _locationController.text.isEmpty ||
                      _dateController.text.isEmpty ||
                      _timeController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields are required')),
                    );
                    return;
                  }

                  // Combine date and time
                  final dateTime = DateTime.parse('${_dateController.text}T${_timeController.text}');
                  final timestamp = Timestamp.fromDate(dateTime);

                  // Get the logged-in user's ID
                  final user = _authController.getCurrentUser();
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final userId = user.uid;

                  // Create a new Event
                  final event = Event(
                    eventId: const Uuid().v4(),
                    userId: userId,
                    name: _nameController.text,
                    category: _categoryController.text,
                    status: 'Upcoming', // Default status
                    location: _locationController.text,
                    date: timestamp,
                    giftIds: [], // No gifts initially
                  );

                  // Save the event using the controller
                  await _eventController.saveEvent( event);

                  // Notify user and go back
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
