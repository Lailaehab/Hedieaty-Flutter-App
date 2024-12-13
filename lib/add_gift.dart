import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../controllers/gift_controller.dart';
import 'controllers/authentication_controller.dart';
import 'package:uuid/uuid.dart';

class AddGiftPage extends StatelessWidget {
  final String eventId;

  const AddGiftPage({required this.eventId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GiftController giftController = GiftController();
    final AuthController _authController = AuthController();
    final user = _authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Events')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final userId = user.uid;

    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: Text('Add Gift')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description')),
            TextField(controller: categoryController, decoration: InputDecoration(labelText: 'Category')),
            TextField(controller: priceController, decoration: InputDecoration(labelText: 'Price')),
            ElevatedButton(
              onPressed: () {
                final newGift = Gift(
                  giftId: Uuid().v4(),
                  eventId: eventId,
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                  price: double.parse(priceController.text),
                  status: 'available',
                  ownerId: userId,
                );
                giftController.createGift(newGift);
                Navigator.pop(context);
              },
              child: Text('Add Gift'),
            ),
          ],
        ),
      ),
    );
  }
}
