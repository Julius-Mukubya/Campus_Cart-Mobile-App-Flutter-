import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_service.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();

  // Get seller's store information
  Future<Map<String, dynamic>?> getSellerStore(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('stores')
          .where('sellerId', isEqualTo: sellerId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        Map<String, dynamic> data = snapshot.docs.first.data() as Map<String, dynamic>;
        data['storeId'] = snapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Error fetching seller store: $e');
      return null;
    }
  }

  // Update store information (triggers approval request)
  Future<Map<String, dynamic>> updateStoreInfo({
    required String storeId,
    required String sellerId,
    required String storeName,
    required String storeDescription,
    required String storeCategory,
    required String storePhone,
    required String storeEmail,
    required String storeAddress,
    String storeImage = '',
  }) async {
    try {
      // Update the store document with new information
      await _firestore.collection('stores').doc(storeId).update({
        'storeName': storeName,
        'storeDescription': storeDescription,
        'storeCategory': storeCategory,
        'storePhone': storePhone,
        'storeEmail': storeEmail,
        'storeAddress': storeAddress,
        'storeImage': storeImage,
        'isVerified': false, // Reset verification status
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create approval request for the updated store
      final result = await _adminService.createStoreApprovalRequest(
        storeId: storeId,
        sellerId: sellerId,
        storeName: storeName,
        storeDescription: storeDescription,
        storeCategory: storeCategory,
        storePhone: storePhone,
        storeEmail: storeEmail,
        storeAddress: storeAddress,
        storeImage: storeImage,
      );

      return result;
    } catch (e) {
      print('Error updating store info: $e');
      return {
        'success': false,
        'message': 'Failed to update store information. Please try again.',
      };
    }
  }

  // Get seller's products
  Future<List<Map<String, dynamic>>> getSellerProducts(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['productId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching seller products: $e');
      return [];
    }
  }

  // Add new product
  Future<Map<String, dynamic>> addProduct({
    required String sellerId,
    required String storeId,
    required String productName,
    required String productDescription,
    required String category,
    required double price,
    required int stockQuantity,
    String productImage = '',
    double discount = 0,
    List<String> tags = const [],
  }) async {
    try {
      DocumentReference productRef = await _firestore.collection('products').add({
        'sellerId': sellerId,
        'storeId': storeId,
        'productName': productName,
        'productDescription': productDescription,
        'category': category,
        'price': price,
        'originalPrice': price,
        'discount': discount,
        'stockQuantity': stockQuantity,
        'productImage': productImage,
        'tags': tags,
        'isActive': true,
        'isApproved': true, // Products are auto-approved for now
        'rating': 0,
        'totalReviews': 0,
        'totalSales': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update store's total products count
      await _firestore.collection('stores').doc(storeId).update({
        'totalProducts': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product added successfully!',
        'productId': productRef.id,
      };
    } catch (e) {
      print('Error adding product: $e');
      return {
        'success': false,
        'message': 'Failed to add product. Please try again.',
      };
    }
  }

  // Update product
  Future<Map<String, dynamic>> updateProduct({
    required String productId,
    required String productName,
    required String productDescription,
    required String category,
    required double price,
    required int stockQuantity,
    String productImage = '',
    double discount = 0,
    List<String> tags = const [],
  }) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'productName': productName,
        'productDescription': productDescription,
        'category': category,
        'price': price,
        'originalPrice': price,
        'discount': discount,
        'stockQuantity': stockQuantity,
        'productImage': productImage,
        'tags': tags,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product updated successfully!',
      };
    } catch (e) {
      print('Error updating product: $e');
      return {
        'success': false,
        'message': 'Failed to update product. Please try again.',
      };
    }
  }

  // Delete product
  Future<Map<String, dynamic>> deleteProduct({
    required String productId,
    required String storeId,
  }) async {
    try {
      await _firestore.collection('products').doc(productId).delete();

      // Update store's total products count
      await _firestore.collection('stores').doc(storeId).update({
        'totalProducts': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'Product deleted successfully!',
      };
    } catch (e) {
      print('Error deleting product: $e');
      return {
        'success': false,
        'message': 'Failed to delete product. Please try again.',
      };
    }
  }

  // Get seller's orders
  Future<List<Map<String, dynamic>>> getSellerOrders(String sellerId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['orderId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error fetching seller orders: $e');
      return [];
    }
  }

  // Get seller dashboard statistics
  Future<Map<String, dynamic>> getSellerStats(String sellerId) async {
    try {
      // Get store info
      Map<String, dynamic>? store = await getSellerStore(sellerId);
      
      if (store == null) {
        return {
          'totalSales': 0,
          'totalOrders': 0,
          'totalProducts': 0,
          'storeRating': 0,
          'isStoreVerified': false,
        };
      }

      return {
        'totalSales': store['totalSales'] ?? 0,
        'totalOrders': store['totalOrders'] ?? 0,
        'totalProducts': store['totalProducts'] ?? 0,
        'storeRating': store['rating'] ?? 0,
        'isStoreVerified': store['isVerified'] ?? false,
      };
    } catch (e) {
      print('Error fetching seller stats: $e');
      return {
        'totalSales': 0,
        'totalOrders': 0,
        'totalProducts': 0,
        'storeRating': 0,
        'isStoreVerified': false,
      };
    }
  }

  // Get available product categories
  List<String> getProductCategories() {
    return [
      'Electronics',
      'Fashion',
      'Books',
      'Sports',
      'Food & Beverages',
      'Health & Beauty',
      'Home & Garden',
      'Automotive',
      'Toys & Games',
      'Music & Movies',
      'Office Supplies',
      'Other',
    ];
  }

  // Get store categories
  List<String> getStoreCategories() {
    return [
      'Electronics Store',
      'Fashion Boutique',
      'Bookstore',
      'Sports Equipment',
      'Food & Beverages',
      'Beauty & Cosmetics',
      'Home & Garden',
      'Automotive Parts',
      'Toy Store',
      'Entertainment',
      'Office Supplies',
      'General Store',
    ];
  }
}