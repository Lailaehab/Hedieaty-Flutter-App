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

class MyGiftDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gift Details')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(decoration: InputDecoration(labelText: 'Name')),
            TextField(decoration: InputDecoration(labelText: 'Description')),
            TextField(decoration: InputDecoration(labelText: 'Category')),
            TextField(decoration: InputDecoration(labelText: 'Price')),
            ElevatedButton(
              onPressed: () {
                // Save modifications logic
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}