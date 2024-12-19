import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../controllers/authentication_controller.dart';
import 'package:intl/intl.dart';
import 'services/database.dart';

class CreateEvent extends StatelessWidget {
  // final EventController _eventController = EventController();
  final AuthController _authController = AuthController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.event, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text('Create Event', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Color.fromARGB(255, 111, 6, 120)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Event Name'),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Category'),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _locationController,
                        decoration: const InputDecoration(labelText: 'Location'),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _dateController,
                        decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                        readOnly: true,
                        onTap: () async {
                          DateTime? selectedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(), // Prevent past dates
                            lastDate: DateTime(2100),
                          );
                          if (selectedDate != null) {
                            _dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
                          }
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _timeController,
                        decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
                        readOnly: true,
                        onTap: () async {
                          TimeOfDay? selectedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) {
                              return MediaQuery(
                                data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              );
                            },
                          );
                          if (selectedTime != null) {
                            final now = DateTime.now();
                            final time = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            _timeController.text = DateFormat('HH:mm').format(time); // Format in 24-hour format
                          }
                        },
                      ),
                    ],
                  ),
                ),
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

                  // Parse the selected date and time into a valid DateTime object
                  final date = DateTime.parse(_dateController.text); // Parse the date directly
                  final timeParts = _timeController.text.split(':');
                  final timeOfDay = TimeOfDay(
                    hour: int.parse(timeParts[0]),
                    minute: int.parse(timeParts[1]),
                  );

                  // Combine date and time into a valid DateTime
                  final dateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    timeOfDay.hour,
                    timeOfDay.minute,
                  );
                  // final timestamp = Timestamp.fromDate(dateTime);

                  // Get the logged-in user's ID
                  final user = _authController.getCurrentUser();
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final userId = user.uid;

                  final event = {
                    'name': _nameController.text,
                    'date': dateTime.toIso8601String(),
                    'location': _locationController.text,
                    'category': _categoryController.text,
                    'userId': userId, 
                    'status': 'Upcoming',
                    'published':'false',
                  };

                  final eventid= await _databaseHelper.insertEvent(event);

                  final new_event = (
                    eventId:eventid,
                    name: _nameController.text,
                    date: dateTime.toIso8601String(),
                    location: _locationController.text,
                    category: _categoryController.text,
                    userId: userId, 
                    status: 'Upcoming',
                    published:'false',
                  );

                  // Notify user and go back
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Event created successfully')),
                  );
                  Navigator.pop(context, new_event);
                },
                child: const Text('Create Event', style: TextStyle(fontSize: 22,color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  backgroundColor: Color.fromARGB(255, 111, 6, 120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}