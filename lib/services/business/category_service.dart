import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CategoryService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories => _categories;

  // Fetch all categories from Firestore
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();

      _categories = snapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      notifyListeners();
      return _categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // Get a single category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final doc =
          await _firestore.collection('categories').doc(categoryId).get();

      if (doc.exists) {
        return {
          ...doc.data() as Map<String, dynamic>,
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching category: $e');
      return null;
    }
  }

  // Get a single category by name
  Future<Map<String, dynamic>?> getCategoryByName(String name) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return {
          ...doc.data(),
          'id': doc.id,
        };
      }
      return null;
    } catch (e) {
      print('Error fetching category by name: $e');
      return null;
    }
  }

  // Add a new category
  Future<String?> addCategory({
    required String name,
    required String description,
    required String icon,
    required int order,
  }) async {
    try {
      final docRef = await _firestore.collection('categories').add({
        'name': name,
        'description': description,
        'icon': icon,
        'order': order,
        'isActive': true,
        'productCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('Category added successfully: $name');
      await fetchCategories(); // Refresh the list
      return docRef.id;
    } catch (e) {
      print('Error adding category: $e');
      return null;
    }
  }

  // Update a category
  Future<void> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    String? icon,
    int? order,
    bool? isActive,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (icon != null) data['icon'] = icon;
      if (order != null) data['order'] = order;
      if (isActive != null) data['isActive'] = isActive;

      data['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore.collection('categories').doc(categoryId).update(data);

      print('Category updated successfully: $categoryId');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      print('Error updating category: $e');
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();

      print('Category deleted successfully: $categoryId');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      print('Error deleting category: $e');
    }
  }

  // Add sample categories to Firebase (for testing)
  Future<void> addSampleCategories() async {
    try {
      // Check if categories already exist
      final existing =
          await _firestore.collection('categories').limit(1).get();

      if (existing.docs.isNotEmpty) {
        print('Categories already exist. Skipping sample data.');
        return;
      }

      final sampleCategories = [
        {
          'name': 'Electronics',
          'description': 'Electronic devices and accessories',
          'icon': 'devices',
          'order': 1,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Fashion',
          'description': 'Clothing, shoes, and accessories',
          'icon': 'checkroom',
          'order': 2,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Books',
          'description': 'Textbooks and study materials',
          'icon': 'menu_book',
          'order': 3,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Food & Beverages',
          'description': 'Snacks, drinks, and meals',
          'icon': 'restaurant',
          'order': 4,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Stationery',
          'description': 'Pens, notebooks, and office supplies',
          'icon': 'edit',
          'order': 5,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Sports',
          'description': 'Sports equipment and activewear',
          'icon': 'sports_soccer',
          'order': 6,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Home & Garden',
          'description': 'Home decor and gardening supplies',
          'icon': 'home',
          'order': 7,
          'isActive': true,
          'productCount': 0,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var category in sampleCategories) {
        await _firestore.collection('categories').add(category);
      }

      print('Sample categories added successfully!');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      print('Error adding sample categories: $e');
    }
  }
}
