import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ImageUtils {

  static const List<String> availableImages = [
     'assets/new_year_gift.jpg',
     'assets/pexels-george-dolgikh-551816-1666070.jpg',
     'assets/phone.jpg',
     'assets/profile_picture1.jpg',
     'assets/profile_picture2.jpg',
     'assets/profile_picture3.jpg',
     'assets/profile_picture4.jpg',
     'assets/default_profile.jpg',
     'assets/perfume.jpg',
     'assets/laptop.jpg',
     'assets/gift2.jpg',
  ];

    // Method to pick, compress, and encode an image
  static Future<String?> pickAndCompressImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      print(
          "Original image size: ${await File(pickedFile.path).lengthSync()} bytes");

      // Compress and resize image
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        minWidth: 800, // Set desired width
        minHeight: 600, // Set desired height
        quality: 50, // Compression quality (0 - 100)
      );

      if (compressedBytes != null) {
        print("Compressed image size: ${compressedBytes.length} bytes");

        // Convert compressed image to Base64
        final compressedImageBase64 = base64Encode(compressedBytes);
        print(
            "Base64 Image: ${compressedImageBase64.substring(0, 100)}..."); // Debug print

        return compressedImageBase64; // Return Base64 encoded string
      }
    }
    return null; // Return null if no image is picked or compression fails
  }

  
}
