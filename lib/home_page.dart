import 'package:flutter/material.dart';
import 'create_event.dart';
import '/controllers/authentication_controller.dart';
import 'my_event_list.dart';
import 'my_pledged_gifts.dart';
import 'profile_page.dart';
import '/reusable/nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthController authController = AuthController();
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePageContent(),
    MyEventListPage(),
    MyPledgedGiftsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: MainNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class HomePageContent extends StatelessWidget {
  final AuthController authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hedieaty',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              _showAddFriendDialog(context);
            },
          ),
          IconButton(
            onPressed: () async {
              await authController.logOut();
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEvent()),
                );
              },
              icon: Icon(Icons.add),
              label: Text(
                'Create Your Own Event',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                // Search logic here
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Replace with actual friends count
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/profile_placeholder.png'),
                    ),
                    title: Text('Friend $index'),
                    subtitle: Text('Upcoming Events: ${index + 1}'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pushNamed(context, '/friendEvents');
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Enter Phone Number',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // Logic to add friend
                },
                icon: Icon(Icons.contact_page),
                label: Text('Pick from Contacts'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}