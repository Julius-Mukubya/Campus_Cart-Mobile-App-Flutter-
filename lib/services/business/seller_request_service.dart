import 'package:flutter/foundation.dart';

class SellerRequestService extends ChangeNotifier {
  static final SellerRequestService _instance =
      SellerRequestService._internal();

  factory SellerRequestService() {
    return _instance;
  }

  SellerRequestService._internal();

  final List<Map<String, dynamic>> _sellerRequests = [];

  List<Map<String, dynamic>> get sellerRequests =>
      List.unmodifiable(_sellerRequests);

  int get pendingRequestCount =>
      _sellerRequests.where((r) => r['status'] == 'pending').length;

  /// Get all seller requests
  List<Map<String, dynamic>> getAllRequests() {
    return List.unmodifiable(_sellerRequests);
  }

  /// Get pending seller requests
  List<Map<String, dynamic>> getPendingRequests() {
    return _sellerRequests.where((r) => r['status'] == 'pending').toList();
  }

  /// Get approved seller requests
  List<Map<String, dynamic>> getApprovedRequests() {
    return _sellerRequests.where((r) => r['status'] == 'approved').toList();
  }

  /// Get rejected seller requests
  List<Map<String, dynamic>> getRejectedRequests() {
    return _sellerRequests.where((r) => r['status'] == 'rejected').toList();
  }

  /// Get request by ID
  Map<String, dynamic>? getRequestById(String requestId) {
    try {
      return _sellerRequests.firstWhere((r) => r['id'] == requestId);
    } catch (e) {
      return null;
    }
  }

  /// Submit a seller upgrade request
  Future<void> submitSellerRequest({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
    List<String>? categories,
  }) async {
    try {
      final requestId =
          'seller_req_${DateTime.now().millisecondsSinceEpoch}';

      // Check if user already has a pending request
      final existingRequest = _sellerRequests.firstWhere(
        (r) => r['userId'] == userId && r['status'] == 'pending',
        orElse: () => <String, dynamic>{},
      );

      if (existingRequest.isNotEmpty) {
        print('User already has a pending seller request');
        return;
      }

      final request = {
        'id': requestId,
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'userPhone': userPhone,
        'status': 'pending', // pending, approved, rejected
        'adminNotes': '',
        'createdAt': DateTime.now().toIso8601String(),
        'reviewedAt': null,
        'reviewedBy': null,
      };

      _sellerRequests.insert(0, request);
      notifyListeners();

      print('Seller request submitted: $requestId');
    } catch (e) {
      print('Error submitting seller request: $e');
    }
  }

  /// Approve seller request (Admin action)
  Future<void> approveSellerRequest({
    required String requestId,
    required String adminId,
    String adminNotes = '',
  }) async {
    try {
      final index =
          _sellerRequests.indexWhere((r) => r['id'] == requestId);

      if (index != -1) {
        _sellerRequests[index]['status'] = 'approved';
        _sellerRequests[index]['adminNotes'] = adminNotes;
        _sellerRequests[index]['reviewedAt'] =
            DateTime.now().toIso8601String();
        _sellerRequests[index]['reviewedBy'] = adminId;

        notifyListeners();
        print('Seller request approved: $requestId');
      }
    } catch (e) {
      print('Error approving seller request: $e');
    }
  }

  /// Reject seller request (Admin action)
  Future<void> rejectSellerRequest({
    required String requestId,
    required String adminId,
    required String rejectionReason,
  }) async {
    try {
      final index =
          _sellerRequests.indexWhere((r) => r['id'] == requestId);

      if (index != -1) {
        _sellerRequests[index]['status'] = 'rejected';
        _sellerRequests[index]['adminNotes'] = rejectionReason;
        _sellerRequests[index]['reviewedAt'] =
            DateTime.now().toIso8601String();
        _sellerRequests[index]['reviewedBy'] = adminId;

        notifyListeners();
        print('Seller request rejected: $requestId');
      }
    } catch (e) {
      print('Error rejecting seller request: $e');
    }
  }

  /// Get request status
  String getRequestStatus(String requestId) {
    final request = getRequestById(requestId);
    return request?['status'] ?? 'unknown';
  }

  /// Check if user has approved seller request
  bool hasApprovedSellerRequest(String userId) {
    return _sellerRequests.any((r) =>
        r['userId'] == userId && r['status'] == 'approved');
  }

  /// Check if user has pending seller request
  bool hasPendingSellerRequest(String userId) {
    return _sellerRequests.any((r) =>
        r['userId'] == userId && r['status'] == 'pending');
  }
}
