import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all vendor-approved orders that haven't been assigned for pickup yet
  Stream<List<Map<String, dynamic>>> getUnassignedApprovedOrders() {
    return _firestore
        .collection('orders')
        .where('vendorApprovalStatus', isEqualTo: 'approved')
        .where('status', isEqualTo: 'vendor_approved')
        .orderBy('vendorApprovedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          ...doc.data(),
          'orderId': doc.id,
        }).toList());
  }

  // Get orders pending vendor approval for a specific vendor (using storeId)
  Stream<List<Map<String, dynamic>>> getVendorPendingOrdersByStore(String storeId) {
    return _firestore
        .collection('orders')
        .where('items', arrayContains: {'storeId': storeId})
        .where('vendorApprovalStatus', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          ...doc.data(),
          'orderId': doc.id,
        }).toList());
  }

  // Get orders at HQ (picked up, awaiting packaging)
  Stream<List<Map<String, dynamic>>> getOrdersAtHQ() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['picked_up', 'at_hq'])
        .orderBy('arrivedAtHqAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          ...doc.data(),
          'orderId': doc.id,
        }).toList());
  }

  // Get packaged orders ready for delivery assignment
  Stream<List<Map<String, dynamic>>> getPackagedOrders() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'packaged')
        .orderBy('packagedAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => {
          ...doc.data(),
          'orderId': doc.id,
        }).toList());
  }

  // Vendor approves order
  Future<void> approveOrder(String orderId, String vendorId) async {
    await _firestore.collection('orders').doc(orderId).update({
      'vendorApprovalStatus': 'approved',
      'vendorApprovedAt': FieldValue.serverTimestamp(),
      'vendorApprovedBy': vendorId,
      'status': 'vendor_approved',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'vendor_approved',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Order approved by vendor',
        'updatedBy': vendorId,
      }]),
    });
  }

  // Vendor rejects order
  Future<void> rejectOrder(String orderId, String vendorId, String reason) async {
    await _firestore.collection('orders').doc(orderId).update({
      'vendorApprovalStatus': 'rejected',
      'vendorRejectionReason': reason,
      'status': 'vendor_rejected',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'vendor_rejected',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Order rejected: $reason',
        'updatedBy': vendorId,
      }]),
    });
  }

  // Assign pickup to delivery staff
  Future<void> assignPickup(String orderId, String staffId, String staffName) async {
    final pickupQrCode = 'PICKUP-${orderId.substring(0, 8)}-${DateTime.now().millisecondsSinceEpoch}';
    
    await _firestore.collection('orders').doc(orderId).update({
      'pickupStaffId': staffId,
      'pickupStaffName': staffName,
      'assignedForPickupAt': FieldValue.serverTimestamp(),
      'pickupQrCode': pickupQrCode,
      'status': 'assigned_for_pickup',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'assigned_for_pickup',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Assigned to $staffName for pickup',
        'updatedBy': staffId,
      }]),
    });
  }

  // Confirm pickup by vendor (QR scan)
  Future<void> confirmPickupByVendor(String orderId, String vendorId, String qrCode) async {
    await _firestore.collection('orders').doc(orderId).update({
      'pickupConfirmedByVendor': true,
      'pickupConfirmedAt': FieldValue.serverTimestamp(),
      'status': 'picked_up',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'picked_up',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Pickup confirmed by vendor via QR',
        'updatedBy': vendorId,
        'qrCodeUsed': true,
      }]),
    });
  }

  // Mark order as arrived at HQ
  Future<void> markArrivedAtHQ(String orderId, String hqLocation) async {
    await _firestore.collection('orders').doc(orderId).update({
      'arrivedAtHqAt': FieldValue.serverTimestamp(),
      'hqLocation': hqLocation,
      'status': 'at_hq',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'at_hq',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Arrived at HQ: $hqLocation',
      }]),
    });
  }

  // Mark order as packaged
  Future<void> markPackaged(String orderId, String packagedBy) async {
    await _firestore.collection('orders').doc(orderId).update({
      'packagedAt': FieldValue.serverTimestamp(),
      'packagedBy': packagedBy,
      'status': 'packaged',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'packaged',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Order packaged and ready for delivery',
        'updatedBy': packagedBy,
      }]),
    });
  }

  // Assign final delivery
  Future<void> assignFinalDelivery(String orderId, String staffId, String staffName, DateTime scheduledDate) async {
    final deliveryQrCode = 'DELIVERY-${orderId.substring(0, 8)}-${DateTime.now().millisecondsSinceEpoch}';
    
    await _firestore.collection('orders').doc(orderId).update({
      'finalDeliveryStaffId': staffId,
      'finalDeliveryStaffName': staffName,
      'assignedForDeliveryAt': FieldValue.serverTimestamp(),
      'scheduledDeliveryDate': Timestamp.fromDate(scheduledDate),
      'deliveryQrCode': deliveryQrCode,
      'status': 'assigned_for_delivery',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'assigned_for_delivery',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Assigned to $staffName for final delivery',
        'updatedBy': staffId,
      }]),
    });
  }

  // Confirm delivery by customer (QR scan)
  Future<void> confirmDeliveryByCustomer(String orderId, String customerId, String qrCode) async {
    await _firestore.collection('orders').doc(orderId).update({
      'deliveryConfirmedByCustomer': true,
      'actualDeliveryDate': FieldValue.serverTimestamp(),
      'status': 'delivered',
      'statusHistory': FieldValue.arrayUnion([{
        'status': 'delivered',
        'timestamp': FieldValue.serverTimestamp(),
        'note': 'Delivery confirmed by customer via QR',
        'updatedBy': customerId,
        'qrCodeUsed': true,
      }]),
    });
  }
}
