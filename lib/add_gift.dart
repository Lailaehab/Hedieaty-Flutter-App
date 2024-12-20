import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/gift_controller.dart';
import '../controllers/authentication_controller.dart';
import '../reusable/image_utils.dart';

class AddGiftPage extends StatefulWidget {
  final String eventId;

  const AddGiftPage({required this.eventId, Key? key}) : super(key: key);

  @override
  _AddGiftPageState createState() => _AddGiftPageState();
}

class _AddGiftPageState extends State<AddGiftPage> {
  final GiftController giftController = GiftController();
  final AuthController _authController = AuthController();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedImagePath;
  String? compressedImageBase64;

  Future<void> requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Camera permission is required to select an image. Please enable it in settings.',
          ),
        ),
      );
    } else if (status.isGranted) {
      await _pickAndCompressImage();
    }
  }

  Future<void> _pickAndCompressImage() async {
    final compressedImage = await ImageUtils.pickAndCompressImage();
    if (compressedImage != null) {
      setState(() {
        compressedImageBase64 = compressedImage;
      });
    }
  }

  void _removeImage() {
    setState(() {
      selectedImagePath = null; 
      compressedImageBase64 = null; 
    });
  }

  @override
  Widget build(BuildContext context) {
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
        title: Row(
          children: [
            Icon(Icons.add, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text('Add Gift',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Color.fromARGB(255, 111, 6, 120))),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder()),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: compressedImageBase64 != null
                    ? Column(
                        children: [
                          Text(
                            'Image Selected and Compressed',
                            style: TextStyle(color: Colors.green),
                          ),
                          SizedBox(height: 10),
                          Image.memory(
                            base64Decode(compressedImageBase64!),
                            width: 200,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _removeImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 0, 79, 170),
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Remove Image',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: 200,
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(Icons.image, color: Colors.grey),
                      ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: requestPermissions,
                  icon: Icon(Icons.image, color: Colors.white),
                  label: Text(
                    'Select Image',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    textStyle: TextStyle(fontSize: 25),
                    backgroundColor: Color.fromARGB(255, 111, 6, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isEmpty ||
                        descriptionController.text.isEmpty ||
                        categoryController.text.isEmpty ||
                        priceController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields.')),
                      );
                      return;
                    }
                    final newGift = {
                      'eventId': widget.eventId,
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'category': categoryController.text,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'status': 'available',
                      'ownerId': userId,
                      'imageUrl': compressedImageBase64,
                    };
                    giftController.createGift(newGift);
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Add Gift',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    textStyle: TextStyle(fontSize: 25),
                    backgroundColor: Color.fromARGB(255, 111, 6, 120),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    super.dispose();
  }
}
