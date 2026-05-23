import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

/// Standalone script to seed sample categories into Firestore.
/// Run: flutter run -t scripts/seed_categories.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🌱 Seeding categories...');

  final firestore = FirebaseFirestore.instance;

  // Check if categories already exist
  final existing = await firestore.collection('categories').limit(1).get();
  if (existing.docs.isNotEmpty) {
    print('⚠️  Categories already exist. Skipping seed. Delete the collection first to re-seed.');
    return;
  }

  final sampleCategories = [
    {
      'name': 'Electronics',
      'description': 'Electronic devices and accessories',
      'icon': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&h=400&fit=crop',
      'order': 1,
      'displayOrder': 1,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Fashion',
      'description': 'Clothing, shoes, and accessories',
      'icon': 'Fashion',
      'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&h=400&fit=crop',
      'order': 2,
      'displayOrder': 2,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Books',
      'description': 'Textbooks, novels, and study materials',
      'icon': 'Books',
      'image': 'https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=400&h=400&fit=crop',
      'order': 3,
      'displayOrder': 3,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Food & Beverages',
      'description': 'Snacks, drinks, and meals',
      'icon': 'Food',
      'image': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=400&fit=crop',
      'order': 4,
      'displayOrder': 4,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Stationery',
      'description': 'Pens, notebooks, and office supplies',
      'icon': 'Stationery',
      'image': 'https://images.unsplash.com/photo-1452860606245-08a8d7e3a1a7?w=400&h=400&fit=crop',
      'order': 5,
      'displayOrder': 5,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Sports',
      'description': 'Sports equipment and activewear',
      'icon': 'Sports',
      'image': 'https://images.unsplash.com/photo-1461896836934-bd45ba8fcf9b?w=400&h=400&fit=crop',
      'order': 6,
      'displayOrder': 6,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Home & Garden',
      'description': 'Home decor and gardening supplies',
      'icon': 'Home',
      'image': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=400&h=400&fit=crop',
      'order': 7,
      'displayOrder': 7,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  for (final category in sampleCategories) {
    await firestore.collection('categories').add(category);
    print('  ✅ Added: ${category['name']}');
  }

  print('');
  print('🎉 Categories seeded successfully!');
  print('📝 Added ${sampleCategories.length} categories to Firestore.');
}