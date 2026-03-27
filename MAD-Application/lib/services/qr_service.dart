import 'package:cloud_firestore/cloud_firestore.dart';

class QRService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Record QR confirmation
  Future<void> recordQRConfirmation({
    required String orderId,
    required String qrCode,
    required String type, // 'pickup' or 'delivery'
    required String confirmedBy,
    required String confirmedByRole,
    String? vendorId,
    String? pickupStaffId,
    String? customerId,
    String? deliveryStaffId,
  }) async {
    await _firestore.collection('qrConfirmations').add({
      'orderId': orderId,
      'qrCode': qrCode,
      'type': type,
      'vendorId': vendorId,
      'pickupStaffId': pickupStaffId,
      'customerId': customerId,
      'deliveryStaffId': deliveryStaffId,
      'confirmedBy': confirmedBy,
      'confirmedByRole': confirmedByRole,
      'confirmedAt': FieldValue.serverTimestamp(),
      'isValid': true,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Validate QR code for order
  Future<Map<String, dynamic>?> validateQRCode(String qrCode, String orderId) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    
    if (!orderDoc.exists) return null;
    
    final orderData = orderDoc.data()!;
    
    // Check if QR matches pickup or delivery
    if (orderData['pickupQrCode'] == qrCode) {
      return {
        'valid': true,
        'type': 'pickup',
        'orderId': orderId,
        'orderData': orderData,
      };
    } else if (orderData['deliveryQrCode'] == qrCode) {
      return {
        'valid': true,
        'type': 'delivery',
        'orderId': orderId,
        'orderData': orderData,
      };
    }
    
    return {'valid': false};
  }
}
