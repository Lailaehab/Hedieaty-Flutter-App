import 'package:flutter/material.dart';
import '/controllers/authentication_controller.dart';
import '/controllers/user_controller.dart';

class AddFriendPage extends StatefulWidget {
  @override
  _AddFriendPageState createState() => _AddFriendPageState();
}

class _AddFriendPageState extends State<AddFriendPage> {
  final AuthController authController = AuthController();
  final UserController userController = UserController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Friend'),
        backgroundColor: Color.fromARGB(255, 111, 6, 120),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Enter Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            IconButton(
            icon: Icon(Icons.person_add, size: 32, color: Color.fromARGB(255, 111, 6, 120)),
            onPressed: () {
              _addFriend();
            },
          ),
          ],
        ),
      ),
    );
  }

  void _addFriend() async {
    final String phoneNumber = phoneController.text.trim();
    if (phoneNumber.isNotEmpty) {
      final currentUser = authController.getCurrentUser();
      if (currentUser != null) {
        final result = await userController.addFriendByPhoneNumber(
          currentUser.uid,
          phoneNumber,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    }
    Navigator.pop(context);
  }
}
