// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart';


//  Future<void> main() async {
//   final serviceAccountPath = 'E:\Downloads\Semester 9\Mobile Programming\MP Project\hedieaty-d79be-firebase-adminsdk-cg8cr-c0d6179fe9';
//   final String projectId = 'hedieaty-d79be';

//   final accountCredentials = ServiceAccountCredentials.fromJson(
//     json.decode(await File(serviceAccountPath).readAsString()),
//   );

//   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
//   final client = await clientViaServiceAccount(accountCredentials, scopes);
//   final accessToken = client.credentials.accessToken.data;

//   final String fcmUrl = 'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';

//   final Map<String, dynamic> payload = {
//   "message": {
//     "token": accessToken,
//     "notification": {
//       "title": "Gift Pledged!",
//       "body": "Your gift has been pledged by a friend."
//     },
//     "data": {
//       "giftId": "12345",
//       "status": "Pledged",
//       "message": "Someone pledged your gift!"
//     }
//   }
// };

//   print('#################### about to send the request ');
//   try {
//     final response = await http.post(
//       Uri.parse(fcmUrl),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $accessToken',
//       },
//       body: jsonEncode(payload),
//     );
//     print('#################### Sending');
//     if (response.statusCode == 200) {
//       print('Notification sent successfully: ${response.body}');
//     } else {
//       print('Error sending notification: ${response.body}');
//     }
//   } catch (e) {
//     print('Error while sending notification: $e');
//     rethrow;
//   }


//  }
