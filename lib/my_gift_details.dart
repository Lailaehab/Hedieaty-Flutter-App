import 'package:flutter/material.dart';
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

  String? imageUrl; // Stores the selected asset path
  String? updatedImageUrl; // Stores the updated image URL for saving later
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
          imageUrl = gift['imageUrl'] ?? 'assets/default_profile.jpg';
          updatedImageUrl = imageUrl; // Initialize the updatedImageUrl
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

  Future<void> _pickImageFromAssets() async {
    String? selectedImage = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Gift Image"),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ImageUtils.availableImages.map((imagePath) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(imagePath);
                  },
                  child: Image.asset(
                    imagePath,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedImage != null) {
      setState(() {
        updatedImageUrl = selectedImage; // Store the selected image in updatedImageUrl
      });
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      updatedImageUrl = null; // Reset image locally for saving later
    });
  }

  Future<void> _updateGift() async {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': nameController.text,
        'description': descriptionController.text,
        'category': categoryController.text,
        'price': double.parse(priceController.text),
        'imageUrl': updatedImageUrl, 
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
                  child: updatedImageUrl != null
                      ? Image.asset(updatedImageUrl!, height: 150, fit: BoxFit.cover)
                      : Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey),
                        ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImageFromAssets,
                      icon: Icon(Icons.upload, color: Colors.white),
                      label: Text('Select Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        backgroundColor: Color.fromARGB(255, 111, 6, 120),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _removeImage,
                      icon: Icon(Icons.delete, color: Colors.white),
                      label: Text('Remove Image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        backgroundColor: const Color.fromARGB(255, 0, 79, 170),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _updateGift,
                    child: Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
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
