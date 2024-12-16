import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/controllers/authentication_controller.dart';
import '/controllers/user_controller.dart';
import '/controllers/event_controller.dart';
import 'create_event.dart';
import 'my_event_list.dart';
import 'my_pledged_gifts.dart';
import 'profile_page.dart';
import '/reusable/nav_bar.dart';
import '/models/user.dart';
import '/models/event.dart';
import 'reusable/search.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

class HomePageContent extends StatefulWidget {
  @override
  _HomePageContentState createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final AuthController authController = AuthController();
  final UserController userController = UserController();
  final FriendSearchController friendSearchController = FriendSearchController();

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Events')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final currentUserId = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 249, 249, 249),
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color:  Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8), 
            Text('Hedieaty', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color:  Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, size: 32, color: Color.fromARGB(255, 111, 6, 120)),
            onPressed: () {
              _showAddFriendDialog(context);
            },
          ),
          IconButton(
            onPressed: () async {
              await authController.logOut();
              Navigator.of(context).pushReplacementNamed('/signup');
            },
            icon: const Icon(Icons.logout, size: 32, color: Color.fromARGB(255, 111, 6, 120)),
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
              icon: Icon(Icons.add, color: Color.fromARGB(255, 111, 6, 120), size: 30),
              label: Text(
                'Create Your Own Event',
                style: TextStyle(
                  color: const Color.fromARGB(255, 111, 6, 120),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 252, 215, 255),
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Color.fromARGB(255, 111, 6, 120)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search Friends',
                prefixIcon: Icon(Icons.search, color:  Color.fromARGB(255, 111, 6, 120)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No Data Available'));
                }

                var user = User.fromFirestore(
                    currentUserId, snapshot.data!.data() as Map<String, dynamic>);
                var friends = user.friends;

                if (friends.isEmpty) {
                  return Center(child: Text('You have no friends.'));
                }
                return StreamBuilder<List<QueryDocumentSnapshot>>(
                  stream: friendSearchController.searchFriendsByName(friends, searchQuery),
                  builder: (context, friendsSnapshot) {
                    if (friendsSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (friendsSnapshot.hasError) {
                      return Center(child: Text('Error: ${friendsSnapshot.error}'));
                    }

                    if (friendsSnapshot.data == null || friendsSnapshot.data!.isEmpty) {
                      return Center(child: Text('No Friends Found'));
                    }

                    var friendDocs = friendsSnapshot.data!;

                    return ListView.builder(
                      itemCount: friendDocs.length,
                      itemBuilder: (context, index) {
                        var friendData = friendDocs[index].data() as Map<String, dynamic>;
                        var friendName = friendData['name'];
                        var friendProfilePicture = friendData['profilePicture'] ?? 'assets/default_profile.jpg';
                        var friendId = friendDocs[index].id;

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Color.fromARGB(255, 111, 6, 120))
                          ),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              friendName,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            subtitle: StreamBuilder<List<Event>>(
                              stream: EventController().getEventsForUser(friendId),
                              builder: (context, eventSnapshot) {
                                if (eventSnapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                if (eventSnapshot.hasError) {
                                  return Center(child: Text('Error: ${eventSnapshot.error}'));
                                }

                                var upcomingEvents = eventSnapshot.data?.where((event) => event.status == 'Upcoming').toList();
                                return Text(
                                  upcomingEvents?.isEmpty ?? true
                                      ? "No Upcoming Events"
                                      : "Upcoming Events: ${upcomingEvents!.length}",
                                  style: TextStyle(color: Colors.green,fontSize: 15),
                                );
                              },
                            ),
                            leading: CircleAvatar(
                              radius: 35,
                              backgroundImage: friendProfilePicture!= null
                            ? AssetImage(friendProfilePicture!) as ImageProvider
                            : AssetImage("assets/default_profile.jpg") as ImageProvider,
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/friendEvents',
                                arguments: {'friendId': friendId},
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFriendDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Friend'),
          content: TextField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Enter Phone Number',
            ),
            keyboardType: TextInputType.phone,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
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
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
