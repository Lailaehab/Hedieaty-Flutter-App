import 'package:flutter/material.dart';
import '/controllers/gift_controller.dart';
import '/models/gift.dart';

class MyGiftListPage extends StatelessWidget {
  final String eventId;

  const MyGiftListPage({required this.eventId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GiftController giftController = GiftController();

    return Scaffold(
      appBar: AppBar(title: Text('Gifts for Event')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: giftController.getGiftsForEvent(eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No gifts found for this event.'));
          }

          final gifts = snapshot.data!;
          return ListView.builder(
            itemCount: gifts.length,
            itemBuilder: (context, index) {
              final gift = Gift.fromFirestore(gifts[index]['id'], gifts[index]);
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(gift.name),
                  subtitle: Text('Category: ${gift.category}\nStatus: ${gift.status}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (gift.status != 'pledged')
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/myGiftDetails',
                              arguments: {'giftId': gift.giftId},
                            );
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          giftController.deleteGift(gift.giftId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gift deleted.')),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/addGift',
            arguments: {'eventId': eventId},
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
