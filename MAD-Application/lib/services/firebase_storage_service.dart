import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Upload profile image to Firebase Storage
  /// Returns the download URL of the uploaded image
  Future<String> uploadProfileImage(File image, String userId) async {
    try {
      // Create a reference to the storage location
      final String fileName = 'profile_$userId.jpg';
      final Reference storageRef = _storage.ref().child('profile_images/$fileName');

      // Upload the file
      final UploadTask uploadTask = storageRef.putFile(image);

      // Wait for upload to complete and get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Update user document in Firestore with new profile image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImage': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete profile image from Firebase Storage
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final Reference storageRef = _storage.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      // Silently fail if image doesn't exist or can't be deleted
      print('Failed to delete profile image: $e');
    }
  }

  /// Update profile image URL in Firestore
  Future<void> updateProfileImageUrl(String userId, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profileImage': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update profile image URL: $e');
    }
  }
}
