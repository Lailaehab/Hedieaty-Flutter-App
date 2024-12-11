// import 'package:flutter/material.dart';

// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class MyGiftDetailsPage extends StatefulWidget {
//   @override
//   _MyGiftDetailsPageState createState() => _MyGiftDetailsPageState();
// }

// class _MyGiftDetailsPageState extends State<MyGiftDetailsPage> {
//   XFile? _image;

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final image = await picker.pickImage(source: ImageSource.gallery);
//     setState(() {
//       _image = image;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Gift Details')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             if (_image != null)
//               Image.file(File(_image!.path), height: 150, width: 150)
//             else
//               Text('No Image Selected'),
//             ElevatedButton(
//               onPressed: _pickImage,
//               child: Text('Upload Gift Image'),
//             ),
//             // Other fields
//             TextField(decoration: InputDecoration(labelText: 'Name')),
//             TextField(decoration: InputDecoration(labelText: 'Description')),
//             TextField(decoration: InputDecoration(labelText: 'Category')),
//             TextField(decoration: InputDecoration(labelText: 'Price')),
//             ElevatedButton(
//               onPressed: () {
//                 // Save modifications logic
//               },
//               child: Text('Save Changes'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../controllers/gift_controller.dart';
class MyGiftDetailsPage extends StatelessWidget {
  final String giftId;

  const MyGiftDetailsPage({required this.giftId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GiftController giftController = GiftController();

    return Scaffold(
      appBar: AppBar(title: Text('Gift Details')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: giftController.getGiftById(giftId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.data == null) {
            return Center(child: Text('Gift not found.'));
          }

          final gift = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${gift['name']}', style: TextStyle(fontSize: 18)),
                SizedBox(height: 8),
                Text('Description: ${gift['description']}'),
                SizedBox(height: 8),
                Text('Category: ${gift['category']}'),
                SizedBox(height: 8),
                Text('Price: \$${gift['price']}'),
                SizedBox(height: 8),
                Text('Status: ${gift['status']}'),
              ],
            ),
          );
        },
      ),
    );
  }
}