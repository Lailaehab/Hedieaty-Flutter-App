import 'package:flutter/material.dart';

class FriendEventListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Friend Events')),
      body: ListView.builder(
        itemCount: 5, // Replace with actual friend events count
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Friend Event $index'),
              subtitle: Text('Date: 2024-02-01, Location: Friend Venue $index'),
              trailing: IconButton(
                icon: Icon(Icons.card_giftcard),
                onPressed: () {
                  Navigator.pushNamed(context, '/friendGifts');
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
