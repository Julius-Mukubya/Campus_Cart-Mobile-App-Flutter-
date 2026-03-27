import 'package:cloud_firestore/cloud_firestore.dart';

class BatchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create pickup batch
  Future<String> createPickupBatch(List<String> orderIds, String region) async {
    final batchNumber = 'BATCH-${DateTime.now().millisecondsSinceEpoch}';
    
    final docRef = await _firestore.collection('orderBatches').add({
      'batchNumber': batchNumber,
      'type': 'pickup',
      'status': 'pending',
      'createdDate': FieldValue.serverTimestamp(),
      'scheduledDate': FieldValue.serverTimestamp(),
      'orderIds': orderIds,
      'totalOrders': orderIds.length,
      'completedOrders': 0,
      'region': region,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }

  // Create delivery batch for next day
  Future<String> createDeliveryBatch(List<String> orderIds, DateTime scheduledDate, String region) async {
    final batchNumber = 'BATCH-${DateTime.now().millisecondsSinceEpoch}';
    
    final docRef = await _firestore.collection('orderBatches').add({
      'batchNumber': batchNumber,
      'type': 'delivery',
      'status': 'pending',
      'createdDate': FieldValue.serverTimestamp(),
      'scheduledDate': Timestamp.fromDate(scheduledDate),
      'orderIds': orderIds,
      'totalOrders': orderIds.length,
      'completedOrders': 0,
      'region': region,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }

  // Assign batch to staff
  Future<void> assignBatch(String batchId, String staffId, String staffName, String assignedBy) async {
    await _firestore.collection('orderBatches').doc(batchId).update({
      'pickupStaffId': staffId,
      'pickupStaffName': staffName,
      'assignedAt': FieldValue.serverTimestamp(),
      'assignedBy': assignedBy,
      'status': 'assigned',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Get batches by type and status
  Stream<List<Map<String, dynamic>>> getBatches(String type, String status) {
    return _firestore
        .collection('orderBatches')
        .where('type', isEqualTo: type)
        .where('status', isEqualTo: status)
        .orderBy('scheduledDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          ...doc.data(),
          'batchId': doc.id,
        }).toList());
  }
}
