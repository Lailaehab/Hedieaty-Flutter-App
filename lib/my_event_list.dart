import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../controllers/authentication_controller.dart';
import 'reusable/sorting_utils.dart';

class MyEventListPage extends StatefulWidget {
  const MyEventListPage({Key? key}) : super(key: key);

  @override
  _MyEventListPageState createState() => _MyEventListPageState();
}

class _MyEventListPageState extends State<MyEventListPage> {
  final EventController _eventController = EventController();
  final AuthController _authController = AuthController();

  SortOption _sortOption = SortOption.name; // Default sort by name
  bool _ascending = true; // Default sorting order: ascending

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's ID
    final user = _authController.getCurrentUser();
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Events')),
        body: const Center(child: Text('User not logged in')),
      );
    }
    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size:35),
            onPressed: () {
              // Navigate to Create Event page
              Navigator.pushNamed(context, '/createEvent');
            },
          ),
          SortingUtils.buildSortMenu(
            sortOption: _sortOption,
            ascending: _ascending,
            onSortOptionChanged: (SortOption option) {
              setState(() {
                _sortOption = option;
              });
            },
            onSortOrderChanged: (bool order) {
              setState(() {
                _ascending = order;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: _eventController.getEventsForUser(userId),
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
          final sortedEvents = SortingUtils.sortItems(
            items: events,
            sortOption: _sortOption,
            ascending: _ascending,
            getName: (event) => event.name,
            getCategory: (event) => event.category,
            getStatus: (event) => _eventController.getEventStatus(event.date),
          );

          return ListView.builder(
            itemCount: sortedEvents.length,
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              final eventStatus = _eventController.getEventStatus(event.date);
              final eventTime = _eventController.formatEventTime(event.date);

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
                      // Event Name
                      Text(
                        event.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Event Category
                      Row(
                        children: [
                          Icon(Icons.category, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Category: ${event.category}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Event Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Date: ${event.date.toDate().toString().split(' ')[0]}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Event Time
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Time: $eventTime',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Event Location
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Location: ${event.location}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Event Status
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.grey[600], size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Status: $eventStatus',
                            style: TextStyle(
                              fontSize: 14,
                              color: eventStatus == 'Upcoming'
                                  ? Colors.green
                                  : eventStatus == 'Current'
                                      ? Colors.blue
                                      : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20, color: Colors.grey),
                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(
                              Icons.card_giftcard_rounded,
                              size: 30.0,
                              color: Colors.white,
                            ),
                            label: const Text(
                              'View Gifts',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              // Navigate to gift list
                              Navigator.pushNamed(
                                context,
                                '/myGifts',
                                arguments: {'eventId': event.eventId},
                              );
                            },
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  // Navigate to Edit Event page
                                  Navigator.pushNamed(
                                    context,
                                    '/editEvent',
                                    arguments: {'event': event},
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  // Confirm and delete event
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Event'),
                                      content: const Text('Are you sure you want to delete this event?'),
                                      actions: [
                                        TextButton(
                                          child: const Text('Cancel'),
                                          onPressed: () => Navigator.pop(context, false),
                                        ),
                                        TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () => Navigator.pop(context, true),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await _eventController.deleteEvent(event.eventId);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Event deleted successfully')),
                                    );
                                  }
                                },
                              ),
                            ],
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
    );
  }
}
