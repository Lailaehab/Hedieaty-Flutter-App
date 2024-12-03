import 'package:flutter/material.dart';

class MyGiftDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gift Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Name')),
            TextField(decoration: InputDecoration(labelText: 'Description')),
            TextField(decoration: InputDecoration(labelText: 'Category')),
            TextField(decoration: InputDecoration(labelText: 'Price')),
            ElevatedButton(
              onPressed: () {
                // Save modifications logic
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
