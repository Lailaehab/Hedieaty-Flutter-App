import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../reusable/image_utils.dart'; 

class EditProfilePage extends StatefulWidget {
  final String userId;

  const EditProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  File? _profileImage;
  String? _profilePictureUrl;
  bool _isLoading = false;
  bool _isPasswordVisible = false;  // Variable to toggle password visibility

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? '';
          _emailController.text = userDoc['email'] ?? '';
          _phoneController.text = userDoc['phoneNumber'] ?? '';
          _profilePictureUrl = userDoc['profilePicture']??'';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e'))
      );
    }
  }

  Future<void> _pickImage() async {
    bool hasPermission = await ImageUtils.requestGalleryPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gallery permission denied!'))
      );
      return;
    }

    File? selectedImage = await ImageUtils.pickImageFromGallery();
    if (selectedImage != null) {
      setState(() {
        _profileImage = selectedImage;
      });
    }
  }

  // Save the profile image locally
  Future<String?> _saveImageLocally(File image) async {
    return await ImageUtils.saveImageLocally(image, widget.userId);
  }

  // Update user profile in Firestore
  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? profileImagePath;

      // Upload profile image if an image is selected
      if (_profileImage != null) {
        profileImagePath = await _saveImageLocally(_profileImage!);
      }

      // Update user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        if (profileImagePath != null) 'profilePicture': profileImagePath,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.edit, color: Color.fromARGB(255, 111, 6, 120), size: 30),
            SizedBox(width: 8),
            Text('Edit Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 111, 6, 120))),
          ],
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImage != null
          ? FileImage(_profileImage!)
          : (_profilePictureUrl != null
          ? FileImage(File(_profilePictureUrl!))
          : const AssetImage('assets/default_profile.png') as ImageProvider),
  child: _profileImage == null && _profilePictureUrl == null
      ? const Icon(Icons.person, size: 60, color: Colors.grey)
      : null, 
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // New password field with visibility toggle
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Save Changes',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
    );
  }
}
