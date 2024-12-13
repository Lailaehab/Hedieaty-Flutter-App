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
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gift.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.category, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Category: ${gift.category}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.monetization_on, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Price: \$${gift.price}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Description: ${gift.description}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Status: ${gift.status}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (gift.imageUrl != null)
                        Image.network(
                          gift.imageUrl!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      const Divider(height: 20, color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (gift.status != 'pledged')
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/myGiftDetails',
                                  arguments: {'giftId': gift.giftId},
                                );
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              giftController.deleteGift(gift.giftId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Gift deleted.')),
                              );
                            },
                          ),
                        ],
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
