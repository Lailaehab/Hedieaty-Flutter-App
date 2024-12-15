import 'package:cloud_firestore/cloud_firestore.dart';

class FriendSearchController {
  /// Filters friends by name.
  /// [query] is the search term entered by the user.
  Stream<List<QueryDocumentSnapshot>> searchFriendsByName(
      List<String> friendsIds, String query) {
    // If no query, return all friends
    if (query.isEmpty) {
      return FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsIds)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }

    // Search by name
    return FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsIds)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.where((doc) {
        final name = (doc.data() as Map<String, dynamic>)['name']?.toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }
}
