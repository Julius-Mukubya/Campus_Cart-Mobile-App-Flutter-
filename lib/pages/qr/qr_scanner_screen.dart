import 'package:flutter/material.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/qr_service.dart';
import 'package:madpractical/services/order_service.dart';

class QRScannerScreen extends StatefulWidget {
  final String scanType; // 'pickup' or 'delivery'
  
  const QRScannerScreen({super.key, required this.scanType});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final QRService _qrService = QRService();
  final OrderService _orderService = OrderService();
  bool _isProcessing = false;

  Future<void> _handleQRCode(String qrCode) async {
    if (_isProcessing) return;
    
    setState(() => _isProcessing = true);
    
    try {
      // Extract order ID from QR code
      final parts = qrCode.split('-');
      if (parts.length < 2) {
        throw Exception('Invalid QR code format');
      }
      
      final orderId = parts[1];
      final validation = await _qrService.validateQRCode(qrCode, orderId);
      
      if (validation == null || validation['valid'] != true) {
        throw Exception('Invalid or expired QR code');
      }
      
      if (widget.scanType == 'pickup') {
        // Vendor confirming pickup
        await _orderService.confirmPickupByVendor(orderId, 'current_vendor_id', qrCode);
        await _qrService.recordQRConfirmation(
          orderId: orderId,
          qrCode: qrCode,
          type: 'pickup',
          confirmedBy: 'current_vendor_id',
          confirmedByRole: 'vendor',
          vendorId: 'current_vendor_id',
        );
      } else {
        // Customer confirming delivery
        await _orderService.confirmDeliveryByCustomer(orderId, 'current_customer_id', qrCode);
        await _qrService.recordQRConfirmation(
          orderId: orderId,
          qrCode: qrCode,
          type: 'delivery',
          confirmedBy: 'current_customer_id',
          confirmedByRole: 'customer',
          customerId: 'current_customer_id',
        );
      }
      
      if (mounted) {
        Navigator.pop(context, {'success': true, 'orderId': orderId});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AiBarcodeScanner(
      onDetect: (capture) {
        final barcode = capture.barcodes.firstOrNull;
        if (barcode?.rawValue != null) {
          _handleQRCode(barcode!.rawValue!);
        }
      },
      appBarBuilder: (context, controller) {
        return AppBar(
          backgroundColor: AppColors.black,
          foregroundColor: AppColors.white,
          title: Text('Scan ${widget.scanType == 'pickup' ? 'Pickup' : 'Delivery'} QR'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
      bottomSheetBuilder: (context, controller) {
        if (_isProcessing) {
          return Container(
            color: AppColors.black.withValues(alpha: 0.7),
            padding: const EdgeInsets.all(20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.white),
                SizedBox(width: 16),
                Text('Processing...', style: TextStyle(color: AppColors.white)),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
