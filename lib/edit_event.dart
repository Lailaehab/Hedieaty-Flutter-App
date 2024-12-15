import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import 'package:intl/intl.dart';

class EditEvent extends StatelessWidget {
  final Event event;
  final EventController _eventController = EventController();

  EditEvent({required this.event});

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Initialize field values with event data
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
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: event.date.toDate(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    _dateController.text = pickedDate.toIso8601String().split('T')[0];
                  }
                },
              ),
              TextFormField(
                controller: _timeController,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(_timeController.text.split(':')[0]),
                      minute: int.parse(_timeController.text.split(':')[1]),
                    ),
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (pickedTime != null) {
                    final now = DateTime.now();
                    final time = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                    _timeController.text = DateFormat('HH:mm').format(time);
                  }
                },
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

                  // Combine date and time fields into a DateTime object
                  final dateTime = DateTime.parse('${_dateController.text}T${_timeController.text}');
                  final timestamp = Timestamp.fromDate(dateTime);

                  // Create updated Event object
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

                  // Update event status
                  updatedEvent.status = _eventController.getEventStatus(updatedEvent.date, updatedEvent);

                  // Save updated event
                  await _eventController.saveEvent(updatedEvent);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event updated successfully')),
                  );

                  // Navigate back
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
