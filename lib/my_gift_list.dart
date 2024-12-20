import 'package:flutter/material.dart';
import '/controllers/gift_controller.dart';
import '/controllers/event_controller.dart';
import '/models/gift.dart';
import '/models/event.dart';
import 'reusable/sorting_utils.dart';
import 'dart:convert';

class MyGiftListPage extends StatefulWidget {
  final String eventId;

  const MyGiftListPage({required this.eventId, Key? key}) : super(key: key);

  @override
  _MyGiftListPageState createState() => _MyGiftListPageState();
}

class _MyGiftListPageState extends State<MyGiftListPage> {
  SortOption _sortOption = SortOption.name; // Default sort by name
  bool _ascending = true; // Default sorting order: ascending
  EventController eventController = EventController();
  final GiftController giftController = GiftController();
  Event? event; 
  bool isLoading = true; 
  late Future<List<Gift>> _gifts;

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    final fetchedEvent = await eventController.getEvent(widget.eventId);
    _gifts = giftController.getGifts(widget.eventId);
    setState(() {
      event = fetchedEvent;
      isLoading = false;
    });
  }

  void _refreshGiftList() {
    setState(() {
      _gifts = giftController.getGifts(widget.eventId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.card_giftcard_outlined,
                color: const Color.fromARGB(255, 111, 6, 120), size: 23),
            const SizedBox(width: 1),
            const Text('Gifts For Event',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : event == null
              ? const Center(child: Text('Event not found.'))
              : FutureBuilder<List<Gift>>(
                  future: _gifts,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('No gifts found for this event.'));
                    }

                    final gifts = snapshot.data!;
                    final sortedGifts = SortingUtils.sortItems(
                      items: gifts,
                      sortOption: _sortOption,
                      ascending: _ascending,
                      getName: (gift) => gift.name,
                      getCategory: (gift) => gift.category,
                      getStatus: (gift) => gift.status,
                    );

                    return ListView.builder(
                      itemCount: sortedGifts.length,
                      itemBuilder: (context, index) {
                        final gift = sortedGifts[index];

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                                color: Color.fromARGB(255, 111, 6, 120)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  gift.name,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.category,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Category: ${gift.category}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.monetization_on,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Price: \$${gift.price}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.description,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Description: ${gift.description}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.info,
                                        color: Colors.grey[600], size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Status: ${gift.status}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: gift.status == 'pledged'
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (gift.imageUrl != null)
                                  Image.memory(
    base64Decode(gift.imageUrl!),
                                    height: 180,
                                    width: 180,
                                    fit: BoxFit.cover,
                                  ),
                                const Divider(height: 20, color: Colors.grey),
                                if (event?.status != 'Past') // Hide buttons for past events
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (gift.status != 'pledged')
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/myGiftDetails',
                                              arguments: {'gift': gift},
                                            ).then((_) {
                                              _refreshGiftList();
                                            });
                                          },
                                        ),
                                      if (gift.status != 'pledged')
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () async {
                                            final confirm = await showDialog<
                                                bool>(
                                              context: context,
                                              builder: (context) =>
                                                  AlertDialog(
                                                title: const Text('Delete Gift'),
                                                content: const Text(
                                                    'Are you sure you want to delete this Gift?'),
                                                actions: [
                                                  TextButton(
                                                    child:
                                                        const Text('Cancel'),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, false),
                                                  ),
                                                  TextButton(
                                                    child:
                                                        const Text('Delete'),
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                            context, true),
                                                  ),
                                                ],
                                              ),
                                            );

                                            if (confirm == true) {
                                              await giftController
                                                  .deleteGift(gift.giftId);
                                              _refreshGiftList();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Gift deleted Successfully.')),
                                              );
                                            }
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
      floatingActionButton: event?.status != 'Past'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/addGift',
                  arguments: {'eventId': widget.eventId},
                ).then((_) {
                  _refreshGiftList();
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
