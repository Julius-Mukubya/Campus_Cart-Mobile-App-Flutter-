import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;
  String get currentUserName => _auth.currentUser?.displayName ?? 'Anonymous';

  // Fetch all reviews for a product
  Future<List<Map<String, dynamic>>> getReviews(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'reviewId': doc.id,
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Anonymous',
          'userImage': data['userImage'] ?? '',
          'rating': (data['rating'] ?? 0).toDouble(),
          'title': data['title'] ?? '',
          'comment': data['comment'] ?? '',
          'isVerifiedPurchase': data['isVerifiedPurchase'] ?? false,
          'helpfulCount': data['helpfulCount'] ?? 0,
          'createdAt': formatTime(data['createdAt']),
        };
      }).toList();
    } catch (e) {
      print('Error fetching reviews: $e');
      return [];
    }
  }

  // Check if current user already reviewed this product
  Future<bool> hasUserReviewed(String productId) async {
    if (currentUserId == null) return false;
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Submit a review and update product's aggregate rating
  Future<Map<String, dynamic>> submitReview({
    required String productId,
    required double rating,
    required String comment,
    String title = '',
  }) async {
    if (currentUserId == null) {
      return {'success': false, 'message': 'You must be logged in to review.'};
    }
    if (rating < 1) {
      return {'success': false, 'message': 'Please select a star rating.'};
    }
    if (comment.trim().isEmpty) {
      return {'success': false, 'message': 'Please write a comment.'};
    }

    try {
      // Check for duplicate review
      final existing = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .where('userId', isEqualTo: currentUserId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return {'success': false, 'message': 'You have already reviewed this product.'};
      }

      // Add the review document
      await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .add({
        'userId': currentUserId,
        'userName': currentUserName,
        'userImage': _auth.currentUser?.photoURL ?? '',
        'rating': rating,
        'title': title,
        'comment': comment.trim(),
        'isVerifiedPurchase': false,
        'helpfulCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Recalculate and update the product's aggregate rating
      await _updateProductRating(productId);

      return {'success': true, 'message': 'Review submitted successfully!'};
    } catch (e) {
      print('Error submitting review: $e');
      return {'success': false, 'message': 'Failed to submit review. Please try again.'};
    }
  }

  // Recalculate aggregate rating from all reviews
  Future<void> _updateProductRating(String productId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('reviews')
          .get();

      if (snapshot.docs.isEmpty) return;

      double total = 0;
      for (final doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }

      final avg = total / snapshot.docs.length;

      await _firestore.collection('products').doc(productId).update({
        'rating': double.parse(avg.toStringAsFixed(1)),
        'reviewCount': snapshot.docs.length,
        'totalReviews': snapshot.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating product rating: $e');
    }
  }

  // Get rating distribution (how many 1★, 2★, ... 5★)
  Map<int, int> getRatingDistribution(List<Map<String, dynamic>> reviews) {
    final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final stars = (r['rating'] as double).round().clamp(1, 5);
      dist[stars] = (dist[stars] ?? 0) + 1;
    }
    return dist;
  }

  // Format timestamp to readable string
  String formatTime(dynamic timestamp) {
    if (timestamp == null) return 'Just now';
    try {
      final dt = (timestamp as dynamic).toDate() as DateTime;
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
