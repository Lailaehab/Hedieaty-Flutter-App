import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'controllers/authentication_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/gift_controller.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final AuthController _authController = AuthController();
  final UserController _userController = UserController();
  final GiftController _giftController = GiftController();

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
      appBar: AppBar(title: const Text('My Pledged Gifts')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userController.getPledgedGifts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No pledged gifts found.'));
          }

          final pledgedGifts = snapshot.data!;

          return ListView.builder(
            itemCount: pledgedGifts.length,
            itemBuilder: (context, index) {
              final gift = pledgedGifts[index];

              // Fetch the due date of the gift
              return FutureBuilder<DateTime?>(
                future: _giftController.getGiftDueDate(gift['id']),
                builder: (context, dueDateSnapshot) {
                  if (dueDateSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (dueDateSnapshot.hasError || !dueDateSnapshot.hasData) {
                    return SizedBox.shrink(); // No due date available
                  }

                  final dueDate = dueDateSnapshot.data!;
                  final now = DateTime.now();

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
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87), // Bold text
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
                            Center( // Center the button
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await _giftController.unpledgeGift(gift['id'], userId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gift unpledged successfully.')),
                                  );
                                },
                                icon: Icon(Icons.remove_circle_outline, color: Colors.white, size: 30),
                                label: Text('Unpledge Gift',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            )
                          else
                            Text(
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