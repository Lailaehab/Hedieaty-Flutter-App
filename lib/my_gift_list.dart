import 'package:flutter/material.dart';
import '/controllers/gift_controller.dart';
import '/models/gift.dart';
import 'reusable/sorting_utils.dart';

class MyGiftListPage extends StatefulWidget {
  final String eventId;

  const MyGiftListPage({required this.eventId, Key? key}) : super(key: key);

  @override
  _MyGiftListPageState createState() => _MyGiftListPageState();
}

class _MyGiftListPageState extends State<MyGiftListPage> {
  SortOption _sortOption = SortOption.name; // Default sort by name
  bool _ascending = true; // Default sorting order: ascending

  @override
  Widget build(BuildContext context) {
    final GiftController giftController = GiftController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for Event'),
        actions: [
          SortingUtils.buildSortMenu(
            sortOption: _sortOption,
            ascending: _ascending,
            onSortOptionChanged: (SortOption newSortOption) {
              setState(() {
                _sortOption = newSortOption;
              });
            },
            onSortOrderChanged: (bool newAscending) {
              setState(() {
                _ascending = newAscending;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>( 
        stream: giftController.getGiftsForEvent(widget.eventId),
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
          final sortedGifts = SortingUtils.sortItems(
            items: gifts,
            sortOption: _sortOption,
            ascending: _ascending,
            getName: (gift) => gift['name'],
            getCategory: (gift) => gift['category'],
            getStatus: (gift) => gift['status'],
          );

          return ListView.builder(
            itemCount: sortedGifts.length,
            itemBuilder: (context, index) {
              final gift = Gift.fromFirestore(sortedGifts[index]['id'], sortedGifts[index]);
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
            arguments: {'eventId': widget.eventId},
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
