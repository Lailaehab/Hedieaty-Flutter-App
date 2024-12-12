import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';

class EditEvent extends StatelessWidget {
  final Event event;
  final EventController _eventController = EventController();

  EditEvent({required this.event});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Pre-fill the form fields
    _nameController.text = event.name;
    _categoryController.text = event.category;
    _locationController.text = event.location;
    _dateController.text = event.date.toDate().toString().split(' ')[0];
    _timeController.text = event.date.toDate().toString().split(' ')[1].substring(0, 5);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Event')),
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

                  final updatedEvent = Event(
                    eventId: event.eventId,
                    userId: event.userId,
                    name: _nameController.text,
                    category: _categoryController.text,
                    status: event.status,
                    location: _locationController.text,
                    date: timestamp,
                    giftIds: event.giftIds,
                  );

                  updatedEvent.status=_eventController.getEventStatus(updatedEvent.date);
                  await _eventController.saveEvent(updatedEvent);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event updated successfully')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
