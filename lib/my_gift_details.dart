import 'package:flutter/material.dart';
import 'dart:io';
import '../controllers/gift_controller.dart';
import '../reusable/image_utils.dart';

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

  String? imageUrl;
  File? selectedImage;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGiftDetails();
  }

  Future<void> _loadGiftDetails() async {
    try {
      final gift = await giftController.getGiftById(widget.giftId);
      if (gift != null) {
        setState(() {
          nameController.text = gift['name'];
          descriptionController.text = gift['description'];
          categoryController.text = gift['category'];
          priceController.text = gift['price'].toString();
          imageUrl = gift['imageUrl'];
          imageUrlController.text = imageUrl ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error loading gift details: $e");
    }
  }

  Future<void> _pickAndUploadImage(String giftId) async {
    if (await ImageUtils.requestGalleryPermission()) {
      final pickedImage = await ImageUtils.pickImageFromGallery();
      if (pickedImage != null) {
        final savedPath = await ImageUtils.saveGitfImageLocally(pickedImage, giftId);
        if (savedPath != null) {
          setState(() {
            selectedImage = pickedImage;
            imageUrl = savedPath;
            imageUrlController.text = imageUrl!;
          });

          await giftController.updateGift(widget.giftId, {'imageUrl': imageUrl!});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Image uploaded successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save the image locally.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No image selected.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery permission denied.')),
      );
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

      try {
        await giftController.updateGift(widget.giftId, updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gift updated successfully!')),
        );

        await Future.delayed(Duration(seconds: 1));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update gift.')),
        );
        print("Error updating gift: $e");
      }
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
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text('Edit Gift Details', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 111, 6, 120))),
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
                    side: BorderSide(color: Color.fromARGB(255, 111, 6, 120)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: descriptionController,
                          decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: categoryController,
                          decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                          validator: (value) => value == null || value.isEmpty ? 'Please enter a category' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: priceController,
                          decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
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
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                child:selectedImage != null
                    ? Image.file(selectedImage!, height: 150, fit: BoxFit.cover)
                    : imageUrl != null
                        ? Image.file(File(imageUrl!), height: 150, fit: BoxFit.cover)
                        : Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey),
                          ),),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickAndUploadImage(widget.giftId),
                    icon: Icon(Icons.upload, color: Colors.white),
                    label: Text('Upload Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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
                    onPressed: _updateGift,
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
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
      ),
    );
  }
}