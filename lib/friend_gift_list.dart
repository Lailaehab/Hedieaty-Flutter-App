import 'package:flutter/material.dart';
import '/controllers/gift_controller.dart';
import '/models/gift.dart';
import '/reusable/sorting_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendGiftListPage extends StatefulWidget {
  final String eventId;

  const FriendGiftListPage({required this.eventId, Key? key}) : super(key: key);

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  SortOption _sortOption = SortOption.name; // Default sort by name
  bool _ascending = true; // Default sorting order: ascending

  @override
  Widget build(BuildContext context) {
    final GiftController giftController = GiftController();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.card_giftcard_outlined, color:  Color.fromARGB(255, 111, 6, 120), size: 23),
            SizedBox(width: 1), 
            Text('Gifts For Event', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color:  Color.fromARGB(255, 111, 6, 120))),],),
        actions: [
          SortingUtils.buildSortMenu(
            sortOption: _sortOption,
            ascending: _ascending,
            onSortOptionChanged: (sortOption) {
              setState(() {
                _sortOption = sortOption;
              });
            },
            onSortOrderChanged: (ascending) {
              setState(() {
                _ascending = ascending;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: giftController.getGiftsForEvent(widget.eventId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No gifts found for this event.'));
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
              final gift = Gift.fromFirestore(
                sortedGifts[index]['id'],
                sortedGifts[index],
              );
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color:  Color.fromARGB(255, 111, 6, 120))
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
                            style: TextStyle(
                              fontSize: 14,
                              color: gift.status == 'pledged' ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (gift.imageUrl != null)
                        Image.asset(
                          gift.imageUrl!,
                          height: 180,width: 180,
                          fit: BoxFit.cover,
                        ),
                      const Divider(height: 20, color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (gift.status != 'pledged')
                            ElevatedButton.icon(
                              onPressed: () async {
                                final userId = FirebaseAuth.instance.currentUser!.uid;
                                await giftController.pledgeGift(gift.giftId, userId);
                                // No need to call setState() since StreamBuilder handles updates
                              },
                              icon: const Icon(Icons.add, color: Colors.white, size: 30),
                              label: const Text(
                                'Pledge Gift',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
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
    );
  }
}
