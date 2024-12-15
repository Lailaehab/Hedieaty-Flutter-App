import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'controllers/authentication_controller.dart';
import 'edit_profile.dart';
import 'models/event.dart';
import 'dart:io'; 

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthController _authController = AuthController();
  final EventController eventController = EventController();
  final GiftController giftController = GiftController();
  bool notificationsEnabled = true; 

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

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.person_2_outlined, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            const SizedBox(width: 8),
            const Text('My Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
         stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error fetching user data'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          notificationsEnabled = userData['notificationsEnabled'] ?? true;
          final profilePictureUrl = userData['profilePicture'] ?? ''; 

          return SingleChildScrollView(
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
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value; 
                    });
                    FirebaseFirestore.instance.collection('users').doc(userId).update({
                      'notificationsEnabled': value,
                    });
                  },
                  activeColor: Colors.green,
                ),
                Center(
                  child: CircleAvatar(
                    radius: 60,
                     backgroundImage: profilePictureUrl != null
                            ? FileImage(File(profilePictureUrl!))
                            : AssetImage("images/default_profile_picture.png") as ImageProvider,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  userData['name'] ?? 'User Name',
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
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    textStyle: const TextStyle(fontSize: 20),
                    backgroundColor: Color.fromARGB(255, 111, 6, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
                      StreamBuilder<List<Event>>(
                        stream: eventController.getEventsForUser(userId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError) {
                            return Center(child: Text('Error: ${snapshot.error}'));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                                margin: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Color.fromARGB(255, 111, 6, 120)),
                                ),
                                child: ExpansionTile(
                                  title: Text(event.name ?? 'Event Name', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  subtitle: Text(event.status ?? 'Unknown Status', style: const TextStyle(fontSize: 14)),
                                  children: [
                                    StreamBuilder<List<Map<String, dynamic>>>( 
                                      stream: giftController.getGiftsForEvent(event.eventId),
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
                                        return ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: gifts.length,
                                          itemBuilder: (context, index) {
                                            final gift = gifts[index];
                                            return ListTile(
                                              leading: const Icon(Icons.card_giftcard),
                                              title: Text(gift['name'] ?? 'Gift Name'),
                                              subtitle: Text('Status: ${gift['status'] ?? 'Unknown'}'),
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
          );
        },
      ),
    );
  }
}
