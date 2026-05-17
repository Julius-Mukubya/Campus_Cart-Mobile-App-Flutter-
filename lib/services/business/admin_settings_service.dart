import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/app_logger.dart';

class AdminSettings {
  final int maxStoresPerSeller;
  final bool sellerApprovalRequired;
  final DateTime lastUpdatedAt;
  final String lastUpdatedBy;

  AdminSettings({
    this.maxStoresPerSeller = 1,
    this.sellerApprovalRequired = true,
    required this.lastUpdatedAt,
    required this.lastUpdatedBy,
  });

  factory AdminSettings.fromJson(Map<String, dynamic> json) {
    return AdminSettings(
      maxStoresPerSeller: json['maxStoresPerSeller'] ?? 1,
      sellerApprovalRequired: json['sellerApprovalRequired'] ?? true,
      lastUpdatedAt: (json['lastUpdatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdatedBy: json['lastUpdatedBy'] ?? 'system',
    );
  }

  Map<String, dynamic> toJson() => {
        'maxStoresPerSeller': maxStoresPerSeller,
        'sellerApprovalRequired': sellerApprovalRequired,
        'lastUpdatedAt': Timestamp.fromDate(lastUpdatedAt),
        'lastUpdatedBy': lastUpdatedBy,
      };
}

class AdminSettingsService {
  static final AdminSettingsService _instance = AdminSettingsService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  factory AdminSettingsService() {
    return _instance;
  }

  AdminSettingsService._internal();

  /// Get current admin settings
  Future<AdminSettings> getSettings() async {
    try {
      final doc = await _firestore.collection('admin_settings').doc('seller_config').get();

      if (!doc.exists) {
        // Create default settings if they don't exist
        final defaultSettings = AdminSettings(
          maxStoresPerSeller: 1,
          sellerApprovalRequired: true,
          lastUpdatedAt: DateTime.now(),
          lastUpdatedBy: 'system',
        );
        await _firestore
            .collection('admin_settings')
            .doc('seller_config')
            .set(defaultSettings.toJson());
        return defaultSettings;
      }

      return AdminSettings.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      AppLogger.error('Error fetching admin settings', error: e);
      // Return default settings on error
      return AdminSettings(
        maxStoresPerSeller: 1,
        sellerApprovalRequired: true,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: 'system',
      );
    }
  }

  /// Set maximum stores allowed per seller
  Future<bool> setMaxStoresPerSeller(int maxStores, String adminId) async {
    try {
      if (maxStores < 1) {
        throw Exception('Max stores must be at least 1');
      }

      await _firestore.collection('admin_settings').doc('seller_config').set({
        'maxStoresPerSeller': maxStores,
        'lastUpdatedAt': Timestamp.now(),
        'lastUpdatedBy': adminId,
        'sellerApprovalRequired': true, // Preserve existing value
      }, SetOptions(merge: true));

      // Log the change
      await _logSettingChange(
        'maxStoresPerSeller',
        maxStores.toString(),
        adminId,
      );

      return true;
    } catch (e) {
      AppLogger.error('Error setting max stores', error: e);
      return false;
    }
  }

  /// Set whether seller approval is required
  Future<bool> setSellerApprovalRequired(bool required, String adminId) async {
    try {
      await _firestore.collection('admin_settings').doc('seller_config').set({
        'sellerApprovalRequired': required,
        'lastUpdatedAt': Timestamp.now(),
        'lastUpdatedBy': adminId,
      }, SetOptions(merge: true));

      // Log the change
      await _logSettingChange(
        'sellerApprovalRequired',
        required.toString(),
        adminId,
      );

      return true;
    } catch (e) {
      AppLogger.error('Error setting seller approval required', error: e);
      return false;
    }
  }

  /// Get max stores allowed per seller
  Future<int> getMaxStoresPerSeller() async {
    try {
      final settings = await getSettings();
      return settings.maxStoresPerSeller;
    } catch (e) {
      AppLogger.error('Error getting max stores', error: e);
      return 1; // Default fallback
    }
  }

  /// Get seller approval requirement setting
  Future<bool> isSellerApprovalRequired() async {
    try {
      final settings = await getSettings();
      return settings.sellerApprovalRequired;
    } catch (e) {
      AppLogger.error('Error getting seller approval requirement', error: e);
      return true; // Default fallback - require approval for safety
    }
  }

  /// Reset settings to defaults
  Future<bool> resetToDefaults(String adminId) async {
    try {
      final defaultSettings = AdminSettings(
        maxStoresPerSeller: 1,
        sellerApprovalRequired: true,
        lastUpdatedAt: DateTime.now(),
        lastUpdatedBy: adminId,
      );

      await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .set(defaultSettings.toJson());

      // Log the reset
      await _logSettingChange(
        'all_settings',
        'reset_to_defaults',
        adminId,
      );

      return true;
    } catch (e) {
      AppLogger.error('Error resetting settings', error: e);
      return false;
    }
  }

  /// Get settings change log (admin audit trail)
  Future<List<Map<String, dynamic>>> getSettingsAuditLog({int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .collection('audit_log')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      AppLogger.error('Error fetching audit log', error: e);
      return [];
    }
  }

  /// Internal: Log setting changes for audit trail
  Future<void> _logSettingChange(String setting, String newValue, String adminId) async {
    try {
      await _firestore
          .collection('admin_settings')
          .doc('seller_config')
          .collection('audit_log')
          .add({
            'setting': setting,
            'newValue': newValue,
            'changedBy': adminId,
            'timestamp': Timestamp.now(),
          });
    } catch (e) {
      AppLogger.error('Error logging setting change', error: e);
    }
  }

  /// Stream settings for real-time updates
  Stream<AdminSettings> watchSettings() {
    return _firestore
        .collection('admin_settings')
        .doc('seller_config')
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            return AdminSettings(
              maxStoresPerSeller: 1,
              sellerApprovalRequired: true,
              lastUpdatedAt: DateTime.now(),
              lastUpdatedBy: 'system',
            );
          }
          return AdminSettings.fromJson(doc.data() as Map<String, dynamic>);
        });
  }
}
