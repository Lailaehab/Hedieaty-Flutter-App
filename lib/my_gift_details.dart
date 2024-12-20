import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/gift.dart';
import '../controllers/gift_controller.dart';
import '../reusable/image_utils.dart';

class MyGiftDetailsPage extends StatefulWidget {
  final Gift gift;

  const MyGiftDetailsPage({required this.gift, Key? key}) : super(key: key);

  @override
  _MyGiftDetailsPageState createState() => _MyGiftDetailsPageState();
}

class _MyGiftDetailsPageState extends State<MyGiftDetailsPage> {
  final GiftController giftController = GiftController();
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  String? compressedImageBase64;

  @override
  void initState() {
    super.initState();
    _initializeGiftDetails();
  }

  void _initializeGiftDetails() {
    nameController.text = widget.gift.name;
    descriptionController.text = widget.gift.description;
    categoryController.text = widget.gift.category;
    priceController.text = widget.gift.price.toString();
    compressedImageBase64 = widget.gift.imageUrl;
  }

  Future<void> requestPermissions() async {
    final status = await Permission.camera.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
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
      compressedImageBase64 = null;
    });
  }

  Future<void> _updateGift() async {
    if (_formKey.currentState!.validate()) {
      final updatedGift = Gift(
        giftId: widget.gift.giftId,
        eventId: widget.gift.eventId,
        ownerId: widget.gift.ownerId,
        name: nameController.text,
        description: descriptionController.text,
        category: categoryController.text,
        price: double.parse(priceController.text),
        status: widget.gift.status,
        imageUrl: compressedImageBase64,
      );

      try {
        await giftController.updateGift(updatedGift);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gift updated successfully!')),
        );
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update gift.')),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.edit, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text(
              'Edit Gift Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 111, 6, 120),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 111, 6, 120),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration:
                              const InputDecoration(labelText: 'Gift Name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a gift name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration:
                              const InputDecoration(labelText: 'Description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: categoryController,
                          decoration:
                              const InputDecoration(labelText: 'Category'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: priceController,
                          decoration: const InputDecoration(labelText: 'Price'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a price';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: compressedImageBase64 != null
                      ? Column(
                          children: [
                            const Text(
                              'Image Selected',
                              style: TextStyle(color: Colors.green),
                            ),
                            const SizedBox(height: 10),
                            Image.memory(
                              base64Decode(compressedImageBase64!),
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _removeImage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 0, 79, 170),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
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
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: requestPermissions,
                    icon: const Icon(Icons.image, color: Colors.white),
                    label: const Text(
                      'Select Image',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 25),
                      backgroundColor: const Color.fromARGB(255, 111, 6, 120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateGift,
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      textStyle: const TextStyle(fontSize: 25),
                      backgroundColor: const Color.fromARGB(255, 111, 6, 120),
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
      ),
    );
  }
}
