import 'package:madpractical/models/seller_request_model.dart';
import 'package:madpractical/repositories/seller_request_repository.dart';
import 'package:madpractical/utils/app_logger.dart';

class SellerRequestService {
  final SellerRequestRepository? _repository;

  SellerRequestService({SellerRequestRepository? repository})
      : _repository = repository ?? SellerRequestRepository();

  /// Submit a new seller request
  Future<Map<String, dynamic>> submitSellerRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    try {
      final success = await _repository!.submitSellerRequest(
        userId: userId,
        userName: userName,
        userEmail: userEmail,
        userPhone: userPhone,
      );

      if (success) {
        return {
          'success': true,
          'message': 'Seller request submitted successfully. Awaiting admin approval.',
        };
      } else {
        return {
          'success': false,
          'message':
              'You already have a pending or approved seller request. Please wait for admin review.',
        };
      }
    } catch (e) {
      AppLogger.error('Error submitting seller request', error: e);
      return {
        'success': false,
        'message': 'Failed to submit seller request: $e',
      };
    }
  }

  /// Get all pending seller requests
  Future<List<SellerRequestModel>> getPendingRequests() async {
    try {
      return await _repository!.getPendingRequests();
    } catch (e) {
      AppLogger.error('Error fetching pending requests', error: e);
      return [];
    }
  }

  /// Get all seller requests
  Future<List<SellerRequestModel>> getAllRequests() async {
    try {
      return await _repository!.getAllRequests();
    } catch (e) {
      AppLogger.error('Error fetching all requests', error: e);
      return [];
    }
  }

  /// Get user's seller request status
  Future<SellerRequestModel?> getUserRequest(String userId) async {
    try {
      return await _repository!.getUserRequest(userId);
    } catch (e) {
      AppLogger.error('Error fetching user request', error: e);
      return null;
    }
  }

  /// Approve a seller request
  Future<Map<String, dynamic>> approveSeller(
      String requestId, String adminId) async {
    try {
      final success = await _repository!.approveSeller(requestId, adminId);

      if (success) {
        return {
          'success': true,
          'message': 'Seller request approved successfully.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to approve seller request.',
        };
      }
    } catch (e) {
      AppLogger.error('Error approving seller request', error: e);
      return {
        'success': false,
        'message': 'Error approving seller request: $e',
      };
    }
  }

  /// Reject a seller request
  Future<Map<String, dynamic>> rejectSeller(
      String requestId, String adminId, String reason) async {
    try {
      final success =
          await _repository!.rejectSeller(requestId, adminId, reason);

      if (success) {
        return {
          'success': true,
          'message': 'Seller request rejected successfully.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to reject seller request.',
        };
      }
    } catch (e) {
      AppLogger.error('Error rejecting seller request', error: e);
      return {
        'success': false,
        'message': 'Error rejecting seller request: $e',
      };
    }
  }

  /// Get approval stats
  Future<Map<String, int>> getStats() async {
    try {
      return await _repository!.getStats();
    } catch (e) {
      AppLogger.error('Error fetching stats', error: e);
      return {'pending': 0, 'approved': 0, 'rejected': 0};
    }
  }
}
