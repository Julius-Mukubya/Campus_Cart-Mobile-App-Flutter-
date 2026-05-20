import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madpractical/models/seller_request_model.dart';
import 'package:madpractical/services/seller_request_service.dart';

final sellerRequestServiceProvider = Provider((ref) {
  return SellerRequestService();
});

/// Get all pending seller requests (for admin)
final pendingSellerRequestsProvider =
    FutureProvider.autoDispose((ref) async {
  final service = ref.watch(sellerRequestServiceProvider);
  return service.getPendingRequests();
});

/// Get all seller requests
final allSellerRequestsProvider =
    FutureProvider.autoDispose((ref) async {
  final service = ref.watch(sellerRequestServiceProvider);
  return service.getAllRequests();
});

/// Get user's seller request status
final userSellerRequestProvider =
    FutureProvider.autoDispose.family<SellerRequestModel?, String>((ref, userId) async {
  final service = ref.watch(sellerRequestServiceProvider);
  return service.getUserRequest(userId);
});

/// Seller request stats (for admin dashboard)
final sellerRequestStatsProvider =
    FutureProvider.autoDispose((ref) async {
  final service = ref.watch(sellerRequestServiceProvider);
  return service.getStats();
});

/// Notifier for seller requests (state management)
class SellerRequestNotifier extends StateNotifier<List<SellerRequestModel>> {
  final SellerRequestService _service;

  SellerRequestNotifier(this._service) : super([]);

  Future<void> loadPendingRequests() async {
    state = await _service.getPendingRequests();
  }

  Future<Map<String, dynamic>> approveSeller(
      String requestId, String adminId) async {
    final result = await _service.approveSeller(requestId, adminId);
    if (result['success']) {
      // Remove from list
      state = state.where((r) => r.id != requestId).toList();
    }
    return result;
  }

  Future<Map<String, dynamic>> rejectSeller(
      String requestId, String adminId, String reason) async {
    final result = await _service.rejectSeller(requestId, adminId, reason);
    if (result['success']) {
      // Remove from list
      state = state.where((r) => r.id != requestId).toList();
    }
    return result;
  }

  Future<Map<String, dynamic>> submitRequest({
    required String userId,
    required String userName,
    required String userEmail,
    String? userPhone,
  }) async {
    return await _service.submitSellerRequest(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      userPhone: userPhone,
    );
  }
}

final sellerRequestNotifierProvider =
    StateNotifierProvider.autoDispose<SellerRequestNotifier, List<SellerRequestModel>>(
        (ref) {
  final service = ref.watch(sellerRequestServiceProvider);
  return SellerRequestNotifier(service);
});
