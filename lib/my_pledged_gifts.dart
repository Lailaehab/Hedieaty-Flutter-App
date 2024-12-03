import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pledged Gifts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 5, // Replace with actual pledged gifts count
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                title: Text('Gift ${index + 1}'),
                subtitle: Text('Category: Toys, Status: Pledged'),
                trailing: Icon(Icons.check_circle, color: Colors.teal),
                onTap: () {
                  // Logic for viewing gift details
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
