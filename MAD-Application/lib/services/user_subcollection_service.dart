import 'package:cloud_firestore/cloud_firestore.dart';

class UserSubcollectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Wishlist management
  Future<bool> addToWishlist(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .set({
        'productId': productId,
        'addedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromWishlist(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> getUserWishlist(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isInWishlist(String userId, String productId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('wishlist')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Cart management
  Future<bool> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    required String image,
    required String category,
    required String storeId,
    required String sellerId,
    int quantity = 1,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .set({
        'productId': productId,
        'productName': productName,
        'price': price,
        'image': image,
        'category': category,
        'storeId': storeId,
        'sellerId': sellerId,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCartQuantity(String userId, String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        return await removeFromCart(userId, productId);
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .update({
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromCart(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .orderBy('addedAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['cartItemId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get cart summary
  Future<Map<String, dynamic>> getCartSummary(String userId) async {
    try {
      List<Map<String, dynamic>> cartItems = await getUserCart(userId);
      
      int itemCount = 0;
      double subtotal = 0.0;
      
      for (var item in cartItems) {
        int quantity = item['quantity'] ?? 1;
        double price = (item['price'] ?? 0.0).toDouble();
        
        itemCount += quantity;
        subtotal += price * quantity;
      }

      double deliveryFee = subtotal > 50000 ? 0.0 : 5000.0; // Free delivery over 50k UGX
      double total = subtotal + deliveryFee;

      return {
        'itemCount': itemCount,
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'items': cartItems,
      };
    } catch (e) {
      return {
        'itemCount': 0,
        'subtotal': 0.0,
        'deliveryFee': 0.0,
        'total': 0.0,
        'items': <Map<String, dynamic>>[],
      };
    }
  }
}