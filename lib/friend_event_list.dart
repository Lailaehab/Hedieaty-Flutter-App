import 'package:flutter/material.dart';
import 'models/event.dart';
import '/controllers/event_controller.dart';
import '/reusable/sorting_utils.dart';

class FriendEventListPage extends StatefulWidget {
  final String friendId;
  final EventController _eventController = EventController();

  FriendEventListPage({required this.friendId});

  @override
  _FriendEventListPageState createState() => _FriendEventListPageState();
}

class _FriendEventListPageState extends State<FriendEventListPage> {
  SortOption _sortOption = SortOption.name; // Default sort by name
  bool _ascending = true; // Default sorting order: ascending

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friend's Events"),
        actions: [
          SortingUtils.buildSortMenu(
            sortOption: _sortOption,
            ascending: _ascending,
            onSortOptionChanged: (sortOption) {
              setState(() {
                _sortOption = sortOption;
              });
            },
            onSortOrderChanged: (ascending) {
              setState(() {
                _ascending = ascending;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Event>>(
        stream: widget._eventController.getEventsForUser(widget.friendId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No events found.'));
          }

          final events = snapshot.data!
              .where((event) => widget._eventController.getEventStatus(event.date,event) == 'Upcoming')
              .toList();

          if (events.isEmpty) {
            return Center(child: Text('No upcoming events.'));
          }

          final sortedEvents = SortingUtils.sortItems(
            items: events,
            sortOption: _sortOption,
            ascending: _ascending,
            getName: (event) => event.name,
            getCategory: (event) => event.category,
            getStatus: (event) => widget._eventController.getEventStatus(event.date,event),
          );

          return ListView.builder(
            itemCount: sortedEvents.length,
            itemBuilder: (context, index) {
              final event = sortedEvents[index];
              final eventStatus = widget._eventController.getEventStatus(event.date,event);
              final eventTime = widget._eventController.formatEventTime(event.date);

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
                        event.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
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
                      const Divider(height: 20, color: Colors.grey),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.card_giftcard_rounded, size: 30.0, color: Colors.white),
                            label: const Text(
                              'View Gifts',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/friendGifts',
                                arguments: {'eventId': event.eventId},
                              );
                            },
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
