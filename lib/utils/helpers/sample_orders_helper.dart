import 'package:madpractical/services/managers/order_manager.dart';
import 'package:madpractical/utils/app_logger.dart';

class SampleOrdersHelper {
  /// Add sample orders with different statuses
  static Future<void> addSampleOrders() async {
    try {
      final orderManager = OrderManager();

      final sampleOrders = [
        // Pending Order
        {
          'id': 'ORD-2026-001',
          'date': '2026-05-15',
          'status': 'Pending',
          'approvalStatus': 'pending',
          'total': 195000.0,
          'items': 2,
          'products': [
            {
              'name': 'Wireless Headphones',
              'quantity': 1,
              'price': 85000.0,
              'image':
                  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
            },
            {
              'name': 'Smart Watch',
              'quantity': 1,
              'price': 120000.0,
              'image':
                  'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400',
            },
          ],
          'shippingAddress': 'Plot 100, Kampala Road, Kampala',
          'customerName': 'John Doe',
          'customerPhone': '+256700123456',
          'subtotal': 195000.0,
          'sellerId': 'sample_seller_1',
        },
        // Approved Order
        {
          'id': 'ORD-2026-002',
          'date': '2026-05-14',
          'status': 'Approved',
          'approvalStatus': 'approved',
          'approvalMessage':
              'Great! I can fulfill this order. Will contact you within 2 hours.',
          'approvedAt': '2026-05-14T14:30:00.000Z',
          'total': 45000.0,
          'items': 1,
          'products': [
            {
              'name': 'Designer T-Shirt',
              'quantity': 1,
              'price': 45000.0,
              'image':
                  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
            },
          ],
          'shippingAddress': 'Plot 50, Makerere Avenue, Kampala',
          'customerName': 'Jane Smith',
          'customerPhone': '+256701234567',
          'subtotal': 45000.0,
          'sellerId': 'sample_seller_2',
        },
        // Rejected Order
        {
          'id': 'ORD-2026-003',
          'date': '2026-05-13',
          'status': 'Rejected',
          'approvalStatus': 'rejected',
          'rejectionReason': 'Item currently out of stock. Expected restock in 1 week.',
          'rejectedAt': '2026-05-13T16:45:00.000Z',
          'total': 95000.0,
          'items': 1,
          'products': [
            {
              'name': 'Coffee Maker',
              'quantity': 1,
              'price': 95000.0,
              'image':
                  'https://images.unsplash.com/photo-1608354580875-30bd4168b351?w=400',
            },
          ],
          'shippingAddress': 'Plot 25, Entebbe Road, Kampala',
          'customerName': 'Bob Wilson',
          'customerPhone': '+256702345678',
          'subtotal': 95000.0,
          'sellerId': 'sample_seller_3',
        },
        // Approved with Processing
        {
          'id': 'ORD-2026-004',
          'date': '2026-05-12',
          'status': 'Processing',
          'approvalStatus': 'approved',
          'approvalMessage': 'Order confirmed! Preparing your items for shipment.',
          'approvedAt': '2026-05-12T10:15:00.000Z',
          'total': 150000.0,
          'items': 2,
          'products': [
            {
              'name': 'Running Shoes',
              'quantity': 1,
              'price': 75000.0,
              'image':
                  'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400',
            },
            {
              'name': 'Bluetooth Speaker',
              'quantity': 1,
              'price': 75000.0,
              'image':
                  'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
            },
          ],
          'shippingAddress': 'Plot 78, Kololo Hill, Kampala',
          'customerName': 'Alice Johnson',
          'customerPhone': '+256703456789',
          'subtotal': 150000.0,
          'sellerId': 'sample_seller_4',
        },
        // Delivered
        {
          'id': 'ORD-2026-005',
          'date': '2026-05-10',
          'status': 'Delivered',
          'approvalStatus': 'approved',
          'approvalMessage': 'Order approved and ready for delivery!',
          'approvedAt': '2026-05-10T09:00:00.000Z',
          'deliveredAt': '2026-05-12T17:30:00.000Z',
          'total': 267500.0,
          'items': 3,
          'products': [
            {
              'name': 'Wireless Headphones',
              'quantity': 1,
              'price': 85000.0,
              'image':
                  'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
            },
            {
              'name': 'Designer T-Shirt',
              'quantity': 2,
              'price': 45000.0,
              'image':
                  'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400',
            },
            {
              'name': 'Bluetooth Speaker',
              'quantity': 1,
              'price': 42000.0,
              'image':
                  'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400',
            },
          ],
          'shippingAddress': 'Plot 12, Wandegeya, Kampala',
          'customerName': 'Charlie Brown',
          'customerPhone': '+256704567890',
          'subtotal': 267500.0,
          'sellerId': 'sample_seller_5',
        },
      ];

      for (var order in sampleOrders) {
        await orderManager.addOrder(order);
      }

      AppLogger.info('Sample orders added successfully! Total: ${sampleOrders.length}');
    } catch (e) {
      AppLogger.error('Error adding sample orders: $e', error: e);
    }
  }
}
