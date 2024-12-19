import 'package:flutter/material.dart';
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

  String? updatedImageUrl; // Stores the updated image URL for saving later

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
    updatedImageUrl = widget.gift.imageUrl ;
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
      // Create an updated Gift object
      final updatedGift = Gift(
        giftId: widget.gift.giftId,
        eventId: widget.gift.eventId,
        ownerId: widget.gift.ownerId,
        name: nameController.text,
        description: descriptionController.text,
        category: categoryController.text,
        price: double.parse(priceController.text),
        status: widget.gift.status,
        imageUrl: updatedImageUrl,
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.edit, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text('Edit Gift Details',
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
                    side: const BorderSide(color: Color.fromARGB(255, 111, 6, 120)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: 'Gift Name'),
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
                          decoration: const InputDecoration(labelText: 'Description'),
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
                          decoration: const InputDecoration(labelText: 'Category'),
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
                            if (double.tryParse(value) == null) {
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const SizedBox(height: 20),
                Center(
                child:ElevatedButton(
                  onPressed: _updateGift,
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 22, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
