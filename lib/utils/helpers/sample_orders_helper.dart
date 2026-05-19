import 'package:madpractical/utils/app_logger.dart';

class SampleOrdersHelper {
  /// Add sample orders with different statuses
  /// Note: In the current architecture, orders are placed via Firebase (Firestore).
  /// This helper is a placeholder — real order seeding should go through OrderService.
  static Future<void> addSampleOrders() async {
    try {
      // Sample orders are no longer seeded via local managers.
      // Orders are managed through Firebase via OrderService/OrderRepository.
      // This method is kept as a stub for compatibility.
      AppLogger.info('Sample orders seeding skipped (handled via Firebase).');
    } catch (e) {
      AppLogger.error('Error in sample orders helper: $e', error: e);
    }
  }
}
