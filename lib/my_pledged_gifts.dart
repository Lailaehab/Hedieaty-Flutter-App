import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'controllers/authentication_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/gift_controller.dart';

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();
  final GiftController _giftController = GiftController();
  late Future<List<Map<String, dynamic>>> _pledgedGiftsFuture;

  @override
  void initState() {
    super.initState();
    final user = _authController.getCurrentUser();
    if (user != null) {
      _pledgedGiftsFuture = _userController.getPledgedGifts(user.uid);
    }
  }

  void _refreshPledgedGifts() {
    final user = _authController.getCurrentUser();
    if (user != null) {
      setState(() {
        _pledgedGiftsFuture = _userController.getPledgedGifts(user.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Pledged Gifts')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(title: Row(
          children: [
            Icon(Icons.card_giftcard_outlined, color:  Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8), 
            Text('My Pledged Gifts', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold, color:  Color.fromARGB(255, 111, 6, 120))),],),),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pledgedGiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No pledged gifts found.'));
          }

          final pledgedGifts = snapshot.data!;

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];
              return FutureBuilder<DateTime?>(
                future: _giftController.getGiftDueDate(gift['id']),
                builder: (context, dueDateSnapshot) {
                  if (dueDateSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (dueDateSnapshot.hasError || !dueDateSnapshot.hasData) {
                    return const SizedBox.shrink(); // No due date available
                  }

                  final dueDate = dueDateSnapshot.data!;
                  final now = DateTime.now();

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
                            gift['giftName'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.person, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Friend: ${gift['Friend']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.category, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Category: ${gift['category']}',
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
                                'Price: \$${gift['price']}',
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
                                'Description: ${gift['description']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate.toLocal())}',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (gift['image'] != null)
                            Image.network(
                              gift['image'],
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          const Divider(height: 20, color: Colors.grey),
                          if (now.isBefore(dueDate))
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _giftController.unpledgeGift(gift['id'], userId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gift unpledged successfully.')),
                                  );
                                  _refreshPledgedGifts();
                                },
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 30),
                                label: const Text(
                                  'Unpledge Gift',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
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
                            )
                          else
                            const Text(
                              'Gift cannot be unpledged. Due date has passed.',
                              style: TextStyle(fontSize: 14, color: Colors.red),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
