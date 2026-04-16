import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_service.dart';

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminService _adminService = AdminService();

  // Get seller's store information
  Future<Map<String, dynamic>?> getSellerStore(String sellerId) async {
    try {
      // First try querying by sellerId field
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

      // Fallback: check if user document has a storeId and fetch directly
      final userDoc = await _firestore.collection('users').doc(sellerId).get();
      if (userDoc.exists) {
        final storeId = (userDoc.data() as Map<String, dynamic>)['storeId'];
        if (storeId != null && storeId.toString().isNotEmpty) {
          final storeDoc = await _firestore.collection('stores').doc(storeId).get();
          if (storeDoc.exists) {
            Map<String, dynamic> data = storeDoc.data() as Map<String, dynamic>;
            data['storeId'] = storeDoc.id;
            return data;
          }
        }
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

  // Get seller earnings summary and payout history
  Future<Map<String, dynamic>> getSellerEarnings(String sellerId) async {
    try {
      // Get all delivered orders for this seller
      final ordersSnap = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: sellerId)
          .get();

      double totalEarnings = 0;
      double availableBalance = 0;
      final List<Map<String, dynamic>> recentOrders = [];

      for (final doc in ordersSnap.docs) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase();
        final amount = (data['totalAmount'] ?? data['total'] ?? 0).toDouble();
        totalEarnings += amount;
        if (status == 'delivered') availableBalance += amount;
        recentOrders.add({...data, 'orderId': doc.id});
      }

      // Get payout history from payouts subcollection or top-level collection
      final payoutsSnap = await _firestore
          .collection('payouts')
          .where('sellerId', isEqualTo: sellerId)
          .orderBy('createdAt', descending: true)
          .get();

      double totalPayouts = 0;
      final List<Map<String, dynamic>> payouts = payoutsSnap.docs.map((doc) {
        final data = doc.data();
        totalPayouts += (data['amount'] ?? 0).toDouble();
        return {...data, 'payoutId': doc.id};
      }).toList();

      return {
        'totalEarnings': totalEarnings,
        'totalPayouts': totalPayouts,
        'availableBalance': availableBalance - totalPayouts,
        'payouts': payouts,
        'orderCount': ordersSnap.docs.length,
      };
    } catch (e) {
      print('Error fetching seller earnings: $e');
      return {
        'totalEarnings': 0.0,
        'totalPayouts': 0.0,
        'availableBalance': 0.0,
        'payouts': <Map<String, dynamic>>[],
        'orderCount': 0,
      };
    }
  }

  // Submit a payout request
  Future<Map<String, dynamic>> requestPayout({
    required String sellerId,
    required double amount,
    required String method,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      await _firestore.collection('payouts').add({
        'sellerId': sellerId,
        'amount': amount,
        'method': method,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return {'success': true, 'message': 'Payout request submitted!'};
    } catch (e) {
      print('Error requesting payout: $e');
      return {'success': false, 'message': 'Failed to submit payout request.'};
    }
  }
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