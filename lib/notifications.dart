import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) =>
                snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList()),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading notifications.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final timestamp =
                  (notification['timestamp'] as Timestamp).toDate().toLocal();

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'No Title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['message'] ?? 'No Message',
                        style: const TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${timestamp.day}/${timestamp.month}/${timestamp.year} ${timestamp.hour}:${timestamp.minute}',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color.fromARGB(255, 99, 99, 99),fontWeight: FontWeight.bold,
                          ),
                        ),
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
