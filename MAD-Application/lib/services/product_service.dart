import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Test Firebase connection and log data structure
  Future<void> testFirebaseConnection() async {
    try {
      print('Testing Firebase connection...');
      
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        print('Firebase connection successful!');
        print('=== FIREBASE DOCUMENT FIELDS ===');
        data.forEach((key, value) {
          print('  "$key": $value');
        });
        // Specifically highlight image-related fields
        print('--- IMAGE FIELDS ---');
        for (final key in data.keys) {
          if (key.toLowerCase().contains('image') ||
              key.toLowerCase().contains('photo') ||
              key.toLowerCase().contains('picture') ||
              key.toLowerCase().contains('img') ||
              key.toLowerCase().contains('url')) {
            print('  FOUND IMAGE FIELD -> "$key": ${data[key]}');
          }
        }
        print('================================');
      } else {
        print('Firebase connected but no products found');
      }
    } catch (e) {
      print('Firebase connection error: $e');
    }
  }

  // Extract image URL from a Firestore document — handles all possible field names
  String _extractImageUrl(Map<String, dynamic> data) {
    // Try every common field name for images
    final candidates = [
      data['productImage'],
      data['image'],
      data['imageUrl'],
      data['image_url'],
      data['photo'],
      data['photoUrl'],
      data['thumbnail'],
      data['img'],
      data['picture'],
      data['pictures'] is List && (data['pictures'] as List).isNotEmpty
          ? (data['pictures'] as List).first
          : null,
      data['images'] is List && (data['images'] as List).isNotEmpty
          ? (data['images'] as List).first
          : null,
    ];

    for (final candidate in candidates) {
      if (candidate != null && candidate.toString().trim().isNotEmpty) {
        return candidate.toString().trim();
      }
    }

    return 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=400&fit=crop';
  }

  // Get all products
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .get();

      print('Found ${snapshot.docs.length} products in Firebase');

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['productName'] ?? data['name'] ?? 'Unknown Product',
          'price': 'UGX ${(data['price'] ?? 0).toString()}',
          'rating': (data['rating'] ?? 4.0).toDouble(),
          'discount': data['discount'] != null && data['discount'] > 0
              ? '-${data['discount'].toString()}%'
              : '',
          'category': data['category'] ?? 'Other',
          'image': _extractImageUrl(data),
          'description': data['productDescription'] ?? data['description'] ?? 'No description available',
          'productId': doc.id,
          'sellerId': data['sellerId'] ?? '',
          'storeId': data['storeId'] ?? '',
          'stockQuantity': data['stockQuantity'] ?? 0,
          'originalPrice': data['originalPrice'] ?? data['price'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return _getFallbackProducts();
    }
  }

  // Get products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['productName'] ?? data['name'] ?? 'Unknown Product',
          'price': 'UGX ${(data['price'] ?? 0).toString()}',
          'rating': (data['rating'] ?? 4.0).toDouble(),
          'discount': data['discount'] != null && data['discount'] > 0
              ? '-${data['discount'].toString()}%'
              : '',
          'category': data['category'] ?? 'Other',
          'image': _extractImageUrl(data),
          'description': data['productDescription'] ?? data['description'] ?? 'No description available',
          'productId': doc.id,
          'sellerId': data['sellerId'] ?? '',
          'storeId': data['storeId'] ?? '',
          'stockQuantity': data['stockQuantity'] ?? 0,
          'originalPrice': data['originalPrice'] ?? data['price'] ?? 0,
        };
      }).toList();
    } catch (e) {
      print('Error fetching products by category: $e');
      return _getFallbackProducts().where((p) => p['category'] == category).toList();
    }
  }

  // Search products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      // Firestore doesn't support full-text search, so we'll get all products and filter
      final allProducts = await getAllProducts();
      
      if (query.isEmpty) return allProducts;
      
      return allProducts.where((product) {
        final name = product['name'].toString().toLowerCase();
        final category = product['category'].toString().toLowerCase();
        final description = product['description'].toString().toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || 
               category.contains(searchQuery) || 
               description.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  // Get available categories with product counts
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      // Get all products to calculate category counts
      final products = await getAllProducts();
      
      // Define category structure with icons and descriptions
      final categoryDefinitions = {
        'Electronics': {
          'icon': 'devices',
          'description': 'Phones, Laptops & More',
          'color': '0xFF4285F4',
          'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&h=400&fit=crop',
        },
        'Fashion': {
          'icon': 'checkroom',
          'description': 'Clothes, Shoes & Style',
          'color': '0xFFE91E63',
          'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&h=400&fit=crop',
        },
        'Home': {
          'icon': 'home',
          'description': 'Furniture & Decor',
          'color': '0xFF4CAF50',
          'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop',
        },
        'Sports': {
          'icon': 'sports_soccer',
          'description': 'Fitness & Outdoor',
          'color': '0xFFFF9800',
          'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        },
        'Groceries': {
          'icon': 'local_grocery_store',
          'description': 'Food & Beverages',
          'color': '0xFF8BC34A',
          'image': 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&h=400&fit=crop',
        },
        'Books': {
          'icon': 'auto_stories',
          'description': 'Education & Literature',
          'color': '0xFF9C27B0',
          'image': 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&h=400&fit=crop',
        },
        'Health & Beauty': {
          'icon': 'spa',
          'description': 'Beauty & Wellness',
          'color': '0xFFFF5722',
          'image': 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop',
        },
        'Automotive': {
          'icon': 'directions_car',
          'description': 'Car Parts & Accessories',
          'color': '0xFF607D8B',
          'image': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?w=400&h=400&fit=crop',
        },
        'Toys & Games': {
          'icon': 'toys',
          'description': 'Fun & Entertainment',
          'color': '0xFFFF9800',
          'image': 'https://images.unsplash.com/photo-1558060370-d644479cb6f7?w=400&h=400&fit=crop',
        },
        'Office Supplies': {
          'icon': 'business_center',
          'description': 'Work & Study',
          'color': '0xFF795548',
          'image': 'https://images.unsplash.com/photo-1497032628192-86f99bcd76bc?w=400&h=400&fit=crop',
        },
        'Other': {
          'icon': 'category',
          'description': 'Miscellaneous Items',
          'color': '0xFF9E9E9E',
          'image': 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=400&fit=crop',
        },
      };

      // Count products per category
      Map<String, int> categoryCounts = {};
      for (var product in products) {
        final category = product['category'] as String;
        categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
      }

      // Build category list with counts
      List<Map<String, dynamic>> categories = [];
      
      for (var entry in categoryDefinitions.entries) {
        final categoryName = entry.key;
        final categoryInfo = entry.value;
        final productCount = categoryCounts[categoryName] ?? 0;
        
        // Only include categories that have products or are essential
        if (productCount > 0 || ['Electronics', 'Fashion', 'Home', 'Sports', 'Groceries', 'Books'].contains(categoryName)) {
          categories.add({
            'title': categoryName,
            'description': categoryInfo['description'],
            'icon': _getIconData(categoryInfo['icon'] as String),
            'color': Color(int.parse(categoryInfo['color'] as String)),
            'image': categoryInfo['image'],
            'productCount': productCount,
          });
        }
      }

      // Sort by product count (descending)
      categories.sort((a, b) => (b['productCount'] as int).compareTo(a['productCount'] as int));

      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return _getFallbackCategories();
    }
  }

  // Helper method to convert icon string to IconData
  dynamic _getIconData(String iconName) {
    switch (iconName) {
      case 'devices': return 'devices';
      case 'checkroom': return 'checkroom';
      case 'home': return 'home';
      case 'sports_soccer': return 'sports_soccer';
      case 'local_grocery_store': return 'local_grocery_store';
      case 'auto_stories': return 'auto_stories';
      case 'spa': return 'spa';
      case 'directions_car': return 'directions_car';
      case 'toys': return 'toys';
      case 'business_center': return 'business_center';
      case 'category': return 'category';
      default: return 'category';
    }
  }

  // Get featured/banner products
  Future<List<Map<String, dynamic>>> getFeaturedProducts({int limit = 5}) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['productName'] ?? data['name'] ?? 'Featured Product',
          'price': 'UGX ${(data['price'] ?? 0).toString()}',
          'image': data['productImage'] ?? data['image'] ?? 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=400&h=400&fit=crop',
          'productId': doc.id,
        };
      }).toList();
    } catch (e) {
      print('Error fetching featured products: $e');
      return [];
    }
  }

  // Fallback data when Firebase is not available
  List<Map<String, dynamic>> _getFallbackProducts() {
    return [
      {
        'name': 'Wireless Headphones',
        'price': 'UGX 85,000',
        'rating': 4.8,
        'discount': '-20%',
        'category': 'Electronics',
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
        'description': 'Premium wireless headphones with noise cancellation and superior sound quality.',
      },
      {
        'name': 'Smart Watch',
        'price': 'UGX 120,000',
        'rating': 4.6,
        'discount': '-15%',
        'category': 'Electronics',
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
        'description': 'Advanced smartwatch with fitness tracking and health monitoring features.',
      },
      {
        'name': 'Designer T-Shirt',
        'price': 'UGX 45,000',
        'rating': 4.9,
        'discount': '-25%',
        'category': 'Fashion',
        'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        'description': 'Premium cotton t-shirt with modern design and comfortable fit.',
      },
      {
        'name': 'Coffee Maker',
        'price': 'UGX 95,000',
        'rating': 4.7,
        'discount': '-18%',
        'category': 'Home',
        'image': 'https://images.unsplash.com/photo-1608354580875-30bd4168b351?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'description': 'Automatic coffee maker with programmable settings and thermal carafe.',
      },
      {
        'name': 'Running Shoes',
        'price': 'UGX 75,000',
        'rating': 4.5,
        'discount': '-30%',
        'category': 'Sports',
        'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
        'description': 'Lightweight running shoes with excellent cushioning and breathable material.',
      },
      {
        'name': 'Bluetooth Speaker',
        'price': 'UGX 42,000',
        'rating': 4.8,
        'discount': '-22%',
        'category': 'Electronics',
        'image': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
        'description': 'Portable Bluetooth speaker with rich bass and long battery life.',
      },
    ];
  }

  List<Map<String, dynamic>> _getFallbackCategories() {
    return [
      {
        'title': 'Electronics',
        'description': 'Phones, Laptops & More',
        'icon': 'devices',
        'color': const Color(0xFF4285F4),
        'image': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400&h=400&fit=crop',
        'productCount': 3,
      },
      {
        'title': 'Fashion',
        'description': 'Clothes, Shoes & Style',
        'icon': 'checkroom',
        'color': const Color(0xFFE91E63),
        'image': 'https://images.unsplash.com/photo-1445205170230-053b83016050?w=400&h=400&fit=crop',
        'productCount': 1,
      },
      {
        'title': 'Home',
        'description': 'Furniture & Decor',
        'icon': 'home',
        'color': const Color(0xFF4CAF50),
        'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400&h=400&fit=crop',
        'productCount': 1,
      },
      {
        'title': 'Sports',
        'description': 'Fitness & Outdoor',
        'icon': 'sports_soccer',
        'color': const Color(0xFFFF9800),
        'image': 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=400&fit=crop',
        'productCount': 1,
      },
    ];
  }

  // Add sample products to Firebase (for testing)
  Future<void> addSampleProducts() async {
    try {
      final sampleProducts = [
        {
          'productName': 'Wireless Headphones',
          'productDescription': 'Premium wireless headphones with noise cancellation and superior sound quality.',
          'category': 'Electronics',
          'price': 85000.0,
          'originalPrice': 106250.0,
          'discount': 20.0,
          'stockQuantity': 50,
          'productImage': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
          'sellerId': 'sample_seller_1',
          'storeId': 'sample_store_1',
          'isActive': true,
          'isApproved': true,
          'rating': 4.8,
          'totalReviews': 124,
          'totalSales': 89,
          'tags': ['wireless', 'audio', 'headphones', 'bluetooth'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'productName': 'Smart Watch',
          'productDescription': 'Advanced smartwatch with fitness tracking and health monitoring features.',
          'category': 'Electronics',
          'price': 120000.0,
          'originalPrice': 141176.0,
          'discount': 15.0,
          'stockQuantity': 30,
          'productImage': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
          'sellerId': 'sample_seller_1',
          'storeId': 'sample_store_1',
          'isActive': true,
          'isApproved': true,
          'rating': 4.6,
          'totalReviews': 87,
          'totalSales': 45,
          'tags': ['smartwatch', 'fitness', 'health', 'wearable'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'productName': 'Designer T-Shirt',
          'productDescription': 'Premium cotton t-shirt with modern design and comfortable fit.',
          'category': 'Fashion',
          'price': 45000.0,
          'originalPrice': 60000.0,
          'discount': 25.0,
          'stockQuantity': 100,
          'productImage': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
          'sellerId': 'sample_seller_2',
          'storeId': 'sample_store_2',
          'isActive': true,
          'isApproved': true,
          'rating': 4.9,
          'totalReviews': 156,
          'totalSales': 234,
          'tags': ['fashion', 'tshirt', 'cotton', 'casual'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'productName': 'Coffee Maker',
          'productDescription': 'Automatic coffee maker with programmable settings and thermal carafe.',
          'category': 'Home',
          'price': 95000.0,
          'originalPrice': 115854.0,
          'discount': 18.0,
          'stockQuantity': 25,
          'productImage': 'https://images.unsplash.com/photo-1608354580875-30bd4168b351?q=80&w=687&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'sellerId': 'sample_seller_3',
          'storeId': 'sample_store_3',
          'isActive': true,
          'isApproved': true,
          'rating': 4.7,
          'totalReviews': 93,
          'totalSales': 67,
          'tags': ['coffee', 'kitchen', 'appliance', 'automatic'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'productName': 'Running Shoes',
          'productDescription': 'Lightweight running shoes with excellent cushioning and breathable material.',
          'category': 'Sports',
          'price': 75000.0,
          'originalPrice': 107143.0,
          'discount': 30.0,
          'stockQuantity': 75,
          'productImage': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
          'sellerId': 'sample_seller_4',
          'storeId': 'sample_store_4',
          'isActive': true,
          'isApproved': true,
          'rating': 4.5,
          'totalReviews': 201,
          'totalSales': 178,
          'tags': ['running', 'shoes', 'sports', 'fitness'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'productName': 'Bluetooth Speaker',
          'productDescription': 'Portable Bluetooth speaker with rich bass and long battery life.',
          'category': 'Electronics',
          'price': 42000.0,
          'originalPrice': 53846.0,
          'discount': 22.0,
          'stockQuantity': 60,
          'productImage': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
          'sellerId': 'sample_seller_1',
          'storeId': 'sample_store_1',
          'isActive': true,
          'isApproved': true,
          'rating': 4.8,
          'totalReviews': 167,
          'totalSales': 145,
          'tags': ['bluetooth', 'speaker', 'audio', 'portable'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var product in sampleProducts) {
        await _firestore.collection('products').add(product);
      }

      print('Sample products added successfully!');
    } catch (e) {
      print('Error adding sample products: $e');
    }
  }
}