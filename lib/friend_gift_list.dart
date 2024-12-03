import 'package:flutter/material.dart';

class FriendGiftListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friend Gifts')),
      body: ListView.builder(
        itemCount: 10, // Replace with actual friend gifts count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Friend Gift $index'),
              subtitle: Text('Category: Books'),
              trailing: ElevatedButton(
                onPressed: () {
                  // Pledge gift logic
                },
                child: Text('Pledge'),
              ),
            ),
          );
        },
      ),
    );
  }
}
