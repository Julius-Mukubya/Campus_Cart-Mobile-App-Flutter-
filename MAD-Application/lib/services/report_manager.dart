import 'package:flutter/foundation.dart';

class ReportManager extends ChangeNotifier {
  static final ReportManager _instance = ReportManager._internal();
  factory ReportManager() => _instance;
  ReportManager._internal();

  final List<Map<String, dynamic>> _reports = [];

  List<Map<String, dynamic>> get reports => List.unmodifiable(_reports);

  int get pendingReportsCount => _reports.where((r) => r['status'] == 'Pending').length;

  void submitReport({
    required String itemId,
    required String itemType, // 'Product', 'Review', 'Comment', 'Order'
    required String itemTitle,
    required String reason,
    required String reporterName,
    String? details,
  }) {
    final report = {
      'id': 'FLAG${(_reports.length + 1).toString().padLeft(3, '0')}',
      'itemId': itemId,
      'type': itemType,
      'title': itemTitle,
      'reason': reason,
      'reporter': reporterName,
      'details': details ?? '',
      'date': DateTime.now().toString().split(' ')[0],
      'status': 'Pending',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _reports.insert(0, report); // Add to beginning for newest first
    notifyListeners();
  }

  void updateReportStatus(String reportId, String newStatus) {
    final index = _reports.indexWhere((r) => r['id'] == reportId);
    if (index != -1) {
      _reports[index]['status'] = newStatus;
      notifyListeners();
    }
  }

  void deleteReport(String reportId) {
    _reports.removeWhere((r) => r['id'] == reportId);
    notifyListeners();
  }

  List<Map<String, dynamic>> getReportsByType(String type) {
    if (type == 'All') return reports;
    return _reports.where((r) => r['type'] == type).toList();
  }

  List<Map<String, dynamic>> getPendingReports() {
    return _reports.where((r) => r['status'] == 'Pending').toList();
  }
}
