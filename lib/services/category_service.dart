import 'package:flutter/foundation.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/repositories/category_repository.dart';

class CategoryService extends ChangeNotifier {
  final CategoryRepository _repository;

  List<Map<String, dynamic>> _categories = [];

  List<Map<String, dynamic>> get categories => _categories;

  CategoryService({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  // Fetch all categories from Firestore
  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
      return _categories;
    } catch (e) {
      AppLogger.error('Error fetching categories: $e', error: e);
      return [];
    }
  }

  // Get a single category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      return await _repository.getCategoryById(categoryId);
    } catch (e) {
      AppLogger.error('Error fetching category: $e', error: e);
      return null;
    }
  }

  // Get a single category by name
  Future<Map<String, dynamic>?> getCategoryByName(String name) async {
    try {
      final categories = await _repository.getCategories();
      for (final cat in categories) {
        if ((cat['name'] ?? '').toString().toLowerCase() == name.toLowerCase()) {
          return cat;
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching category by name: $e', error: e);
      return null;
    }
  }

  // Add a new category
  Future<String?> addCategory({
    required String name,
    required String description,
    required String icon,
    required int order,
    String? image,
  }) async {
    try {
      final docId = await _repository.addCategory({
        'name': name,
        'description': description,
        'icon': icon,
        'image': image ?? '',
        'order': order,
        'displayOrder': order,
        'isActive': true,
        'productCount': 0,
      });

      AppLogger.info('Category added successfully: $name');
      await fetchCategories(); // Refresh the list
      return docId;
    } catch (e) {
      AppLogger.error('Error adding category: $e', error: e);
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
    String? image,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (icon != null) updates['icon'] = icon;
      if (image != null) updates['image'] = image;
      if (order != null) {
        updates['order'] = order;
        updates['displayOrder'] = order;
      }
      if (isActive != null) updates['isActive'] = isActive;

      await _repository.updateCategory(categoryId, updates);

      AppLogger.info('Category updated successfully: $categoryId');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      AppLogger.error('Error updating category: $e', error: e);
    }
  }

  // Delete a category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _repository.deleteCategory(categoryId);

      AppLogger.info('Category deleted successfully: $categoryId');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      AppLogger.error('Error deleting category: $e', error: e);
    }
  }

  // Add sample categories to Firebase (for testing)
  Future<void> addSampleCategories() async {
    try {
      // Check if categories already exist
      final existing = await _repository.getCategories();
      if (existing.isNotEmpty) {
        AppLogger.info('Categories already exist. Skipping sample data.');
        return;
      }

      final sampleCategories = [
        {
          'name': 'Electronics',
          'description': 'Electronic devices and accessories',
          'icon': 'devices',
          'order': 1,
          'displayOrder': 1,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Fashion',
          'description': 'Clothing, shoes, and accessories',
          'icon': 'checkroom',
          'order': 2,
          'displayOrder': 2,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Books',
          'description': 'Textbooks and study materials',
          'icon': 'menu_book',
          'order': 3,
          'displayOrder': 3,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Food & Beverages',
          'description': 'Snacks, drinks, and meals',
          'icon': 'restaurant',
          'order': 4,
          'displayOrder': 4,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Stationery',
          'description': 'Pens, notebooks, and office supplies',
          'icon': 'edit',
          'order': 5,
          'displayOrder': 5,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Sports',
          'description': 'Sports equipment and activewear',
          'icon': 'sports_soccer',
          'order': 6,
          'displayOrder': 6,
          'isActive': true,
          'productCount': 0,
        },
        {
          'name': 'Home & Garden',
          'description': 'Home decor and gardening supplies',
          'icon': 'home',
          'order': 7,
          'displayOrder': 7,
          'isActive': true,
          'productCount': 0,
        },
      ];

      for (var category in sampleCategories) {
        await _repository.addCategory(category);
      }

      AppLogger.info('Sample categories added successfully!');
      await fetchCategories(); // Refresh the list
    } catch (e) {
      AppLogger.error('Error adding sample categories: $e', error: e);
    }
  }
}