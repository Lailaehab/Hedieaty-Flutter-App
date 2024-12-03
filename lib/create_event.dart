import 'package:flutter/material.dart';

class CreateEvent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Event Name')),
            TextField(decoration: InputDecoration(labelText: 'Date')),
            TextField(decoration: InputDecoration(labelText: 'Time')),
            TextField(decoration: InputDecoration(labelText: 'Location')),
            ElevatedButton(
              onPressed: () {
                // Add event logic
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
