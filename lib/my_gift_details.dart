import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // For using File
import 'package:path_provider/path_provider.dart';
import '../controllers/gift_controller.dart';

class MyGiftDetailsPage extends StatefulWidget {
  final String giftId;

  const MyGiftDetailsPage({required this.giftId, Key? key}) : super(key: key);

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
  TextEditingController imageUrlController = TextEditingController();

  String? imageUrl; // Stores the image path
  File? selectedImage; // Stores the selected image file
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    final gift = await giftController.getGiftById(widget.giftId);
    if (gift != null) {
      setState(() {
        nameController.text = gift['name'];
        descriptionController.text = gift['description'];
        categoryController.text = gift['category'];
        priceController.text = gift['price'].toString();
        imageUrl = gift['imageUrl'];
        imageUrlController.text = imageUrl ?? ''; // Set the image URL in the text field
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

Future<void> _pickImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/${widget.giftId}_image.png';
      final imageFile = File(pickedFile.path);

      // Save image to app's local directory
      final savedImage = await imageFile.copy(filePath);

      // Log the file paths for debugging
      print('Picked file path: ${pickedFile.path}');
      print('Saved file path: ${savedImage.path}');

      if (await savedImage.exists()) {
        print('File saved successfully.');
        setState(() {
          selectedImage = savedImage;
          imageUrl = savedImage.path;
          imageUrlController.text = imageUrl!;
        });

        // Update Firestore with the local image path
        await giftController.updateGift(widget.giftId, {'imageUrl': imageUrl!});
      } else {
        print('File saving failed.');
      }
    } catch (e) {
      print('Error while saving image: $e');
    }
  } else {
    print('No image selected.');
  }
}

Future<void> _updateGift() async {
  if (_formKey.currentState!.validate()) {
    final updatedData = {
      'name': nameController.text,
      'description': descriptionController.text,
      'category': categoryController.text,
      'price': double.parse(priceController.text),
      'imageUrl': imageUrl,
    };

    await giftController.updateGift(widget.giftId, updatedData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gift updated successfully!')),
    );

    // Delay navigation back by 1 second
    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(context); // Navigate back
  }
}


  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Gift Details')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Gift Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Gift Name'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a name'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a description'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter a category'
                      : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Display the selected image
                selectedImage != null
                    ? Image.file(selectedImage!, height: 150, fit: BoxFit.cover)
                    : imageUrl != null
                        ? Image.file(File(imageUrl!), height: 150, fit: BoxFit.cover)
                        : Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),

                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: Text('Upload Image'),
                ),
                SizedBox(height: 16),

                // Image URL TextField
                TextFormField(
                  controller: imageUrlController,
                  decoration: InputDecoration(labelText: 'Image URL'),
                  enabled: false,
                ),
                SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _updateGift,
                  child: Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
