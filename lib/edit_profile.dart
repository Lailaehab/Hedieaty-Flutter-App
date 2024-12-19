import 'package:flutter/material.dart';
import 'package:hedieaty/services/database.dart';
import '../reusable/image_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? _profilePicturePath;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final List<Map<String, dynamic>> userData =
          await _databaseHelper.getUsers();

      // Find user by ID
      final user = userData.firstWhere(
        (element) => element['id'] == widget.userId,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        setState(() {
          _nameController.text = user['name'] ?? '';
          _emailController.text = user['email'] ?? '';
          _phoneController.text = user['phone_number'] ?? '';
          _profilePicturePath =
              user['profile_picture'] ?? 'assets/default_profile.jpg';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found in the local database')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<void> _pickImageFromAssets() async {
    String? selectedImage = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Profile Picture"),
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
        _profilePicturePath = selectedImage;
      });
    }
  }

  Future<void> _removeProfilePicture() async {
    setState(() {
      _profilePicturePath = null;
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
            // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneController.text,
        'profilePicture': _profilePicturePath ,
      });
      // Update Local SQLite Database
      await _databaseHelper.updateUser(widget.userId, {
        'id': widget.userId,
        'name': _nameController.text,
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'profile_picture': _profilePicturePath,
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
            const Icon(Icons.edit,
                color: Color.fromARGB(255, 111, 6, 120), size: 30),
            const SizedBox(width: 8),
            const Text(
              'Edit Profile',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 111, 6, 120)),
            ),
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
                    onTap: _pickImageFromAssets,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundImage: _profilePicturePath != null &&
                              _profilePicturePath!.isNotEmpty
                          ? AssetImage(_profilePicturePath!) as ImageProvider
                          : const AssetImage('assets/default_profile.jpg'),
                      child: _profilePicturePath == null
                          ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  _profilePicturePath != null
                      ? ElevatedButton(
                          onPressed: _removeProfilePicture,
                          child: const Text(
                            'Remove Profile Picture',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 120, 120, 120),
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(
                                  color: Color.fromARGB(255, 62, 61, 61)),
                            ),
                          ),
                        )
                      : Container(),
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
                  TextField(
                    controller: _newPasswordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
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
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
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
                ],
              ),
            ),
    );
  }
}
