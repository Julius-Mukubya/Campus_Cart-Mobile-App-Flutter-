import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/exceptions.dart';
import '../utils/app_logger.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch all categories from Firestore
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .orderBy('displayOrder', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to fetch categories', error: e);
      throw RepositoryException('Failed to fetch categories: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error fetching categories', error: e);
      throw RepositoryException('Unexpected error: $e');
    }
  }

  /// Fetch a single category by ID
  Future<Map<String, dynamic>?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore.collection('categories').doc(categoryId).get();
      if (!doc.exists) return null;

      final data = doc.data() ?? {};
      data['id'] = doc.id;
      return data;
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to fetch category', error: e);
      throw RepositoryException('Failed to fetch category: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error fetching category', error: e);
      throw RepositoryException('Unexpected error: $e');
    }
  }

  /// Fetch categories by type (e.g., 'product', 'service')
  Future<List<Map<String, dynamic>>> getCategoriesByType(String type) async {
    try {
      final snapshot = await _firestore
          .collection('categories')
          .where('type', isEqualTo: type)
          .orderBy('displayOrder', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } on FirebaseException catch (e) {
      AppLogger.error('Failed to fetch categories by type', error: e);
      throw RepositoryException('Failed to fetch categories: ${e.message}');
    } catch (e) {
      AppLogger.error('Unexpected error fetching categories', error: e);
      throw RepositoryException('Unexpected error: $e');
    }
  }
}
