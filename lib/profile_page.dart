import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/controllers/authentication_controller.dart';
import 'edit_profile.dart';
import 'models/event.dart';
import 'services/database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = AuthController();
  final EventController eventController = EventController();
  final GiftController giftController = GiftController();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  bool notificationsEnabled = true;
  Map<String, dynamic>? userData;
  String profilePictureUrl = '';

  Future<void> fetchUserData(String userId) async {
    userData = await _dbHelper.getUserById(userId);
    if (userData != null) {
      notificationsEnabled = (userData!['notificationsEnabled'] ?? 1) == 1;
      profilePictureUrl = userData!['profile_picture'] ?? '';
    }
  }

  Future<List<Event>> fetchUserEvents(String userId) async {
    return await _dbHelper.getEventsByUserId(userId);
  }

  Future<List<Map<String, dynamic>>> fetchGiftsForEvent(String eventId) async {
    return (await _dbHelper.getGiftsByEventId(eventId))
        .map((gift) => gift.toMap())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Profile')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final userId = user.uid;

    return FutureBuilder<void>(
      future: fetchUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || userData == null) {
          return const Center(child: Text('Error fetching user data'));
        }

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Icon(Icons.person_2_outlined,
                    color: Color.fromARGB(255, 111, 6, 120), size: 30),
                const SizedBox(width: 8),
                const Text('My Profile',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 111, 6, 120))),
              ],
            ),
            backgroundColor: Colors.white,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                SwitchListTile(
                  title: const Text(
                    'Enable Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  value: notificationsEnabled,
                  onChanged: (bool value) async {
                    setState(() {
                      notificationsEnabled = value;
                    });
                    // Clone userData to a mutable map and update the value
                    final updatedUserData = Map<String, dynamic>.from(userData!);
                    updatedUserData['notificationsEnabled'] = value ? 1 : 0;
                    await _dbHelper.updateUser(userId, updatedUserData);
                    userData = updatedUserData;
                  },
                  activeColor: Colors.green,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: profilePictureUrl.isNotEmpty
                        ? AssetImage(profilePictureUrl) as ImageProvider
                        : AssetImage("assets/default_profile.jpg") as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userData!['name'] ?? 'User Name',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(userId: userId),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Color.fromARGB(255, 111, 6, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Color.fromARGB(255, 69, 0, 77), width: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Events and Gifts',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder<List<Event>>(
                        future: fetchUserEvents(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError ||
                              !snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(child: Text('No events found.'));
                          }

                          final events = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: Color.fromARGB(255, 111, 6, 120)),
                                ),
                                child: ExpansionTile(
                                  title: Text(event.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                  subtitle: Text(event.status,
                                      style: const TextStyle(fontSize: 14)),
                                  children: [
                                    FutureBuilder<
                                        List<Map<String, dynamic>>>(
                                      future: fetchGiftsForEvent(event.eventId),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  CircularProgressIndicator());
                                        }
                                        if (snapshot.hasError ||
                                            !snapshot.hasData ||
                                            snapshot.data!.isEmpty) {
                                          return Center(
                                              child: Text(
                                                  'No gifts found for this event.'));
                                        }

                                        final gifts = snapshot.data!;
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: gifts.length,
                                          itemBuilder: (context, index) {
                                            final gift = gifts[index];
                                            return ListTile(
                                              leading: const Icon(
                                                  Icons.card_giftcard),
                                              title: Text(
                                                  gift['name'] ?? 'Gift Name'),
                                              subtitle: Text(
                                                  'Status: ${gift['status'] ?? 'Unknown'}'),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
