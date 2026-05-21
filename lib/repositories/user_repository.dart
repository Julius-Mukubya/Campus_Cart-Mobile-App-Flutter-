import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/utils/app_logger.dart';
import 'package:madpractical/utils/exceptions.dart';

/// Repository for user data operations.
/// Wraps Firestore calls and provides a clean API for user data access.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetch a user document by ID.
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        throw RepositoryException('User not found', operation: 'getUser');
      }
      final data = doc.data()!;
      data['userId'] = doc.id;
      return data;
    } on RepositoryException {
      rethrow;
    } catch (e) {
      AppLogger.error('UserRepository.getUser failed', error: e);
      throw RepositoryException(
        'Failed to fetch user',
        operation: 'getUser',
        originalError: e,
      );
    }
  }

  /// Create a new user document.
  Future<void> createUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(data);
    } catch (e) {
      AppLogger.error('UserRepository.createUser failed', error: e);
      throw RepositoryException(
        'Failed to create user',
        operation: 'createUser',
        originalError: e,
      );
    }
  }

  /// Update a user document.
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .update({
            ...data,
            'updatedAt': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      AppLogger.error('UserRepository.updateUser failed', error: e);
      throw RepositoryException(
        'Failed to update user',
        operation: 'updateUser',
        originalError: e,
      );
    }
  }

  /// Stream a user document for real-time updates.
  Stream<Map<String, dynamic>> watchUser(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw RepositoryException('User not found', operation: 'watchUser');
          }
          final data = doc.data()!;
          data['userId'] = doc.id;
          return data;
        });
  }
}