import 'package:flutter/foundation.dart';

class SupplierService extends ChangeNotifier {
  static final SupplierService _instance = SupplierService._internal();

  factory SupplierService() {
    return _instance;
  }

  SupplierService._internal();

  final List<Map<String, dynamic>> _suppliers = [];

  List<Map<String, dynamic>> get suppliers => List.unmodifiable(_suppliers);

  /// Get all suppliers
  Future<List<Map<String, dynamic>>> fetchSuppliers() async {
    try {
      // For now, return local suppliers
      return _suppliers;
    } catch (e) {
      print('Error fetching suppliers: $e');
      return [];
    }
  }

  /// Get supplier by ID
  Map<String, dynamic>? getSupplierById(String supplierId) {
    try {
      return _suppliers.firstWhere((s) => s['id'] == supplierId);
    } catch (e) {
      return null;
    }
  }

  /// Get suppliers by store ID
  List<Map<String, dynamic>> getSuppliersByStoreId(String storeId) {
    return _suppliers.where((s) => s['storeId'] == storeId).toList();
  }

  /// Add a new supplier
  Future<void> addSupplier({
    required String name,
    required String email,
    required String phone,
    required String storeName,
    required String address,
    required String city,
    List<String>? categories,
    double rating = 4.5,
  }) async {
    try {
      final supplierId = 'supplier_${DateTime.now().millisecondsSinceEpoch}';
      final storeId = 'store_${DateTime.now().millisecondsSinceEpoch}';

      final supplier = {
        'id': supplierId,
        'storeId': storeId,
        'name': name,
        'email': email,
        'phone': phone,
        'storeName': storeName,
        'address': address,
        'city': city,
        'categories': categories ?? [],
        'rating': rating,
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      _suppliers.add(supplier);
      notifyListeners();
      print('Supplier added: $name');
    } catch (e) {
      print('Error adding supplier: $e');
    }
  }

  /// Add sample suppliers
  Future<void> addSampleSuppliers() async {
    try {
      // Check if suppliers already exist
      if (_suppliers.isNotEmpty) {
        print('Suppliers already exist. Skipping sample data.');
        return;
      }

      final sampleSuppliers = [
        {
          'id': 'sample_seller_1',
          'storeId': 'sample_store_1',
          'name': 'Tech Hub Uganda',
          'email': 'contact@techhub.ug',
          'phone': '+256701234567',
          'storeName': 'Tech Hub - Electronics & Gadgets',
          'address': 'Plot 123, Kampala Road',
          'city': 'Kampala',
          'categories': ['Electronics'],
          'rating': 4.8,
          'totalOrders': 156,
          'totalRevenue': 25000000.0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'sample_seller_2',
          'storeId': 'sample_store_2',
          'name': 'Fashion Forward',
          'email': 'hello@fashionforward.ug',
          'phone': '+256702345678',
          'storeName': 'Fashion Forward - Trendy Wear',
          'address': 'Plot 45, Makerere Avenue',
          'city': 'Kampala',
          'categories': ['Fashion'],
          'rating': 4.6,
          'totalOrders': 234,
          'totalRevenue': 18500000.0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'sample_seller_3',
          'storeId': 'sample_store_3',
          'name': 'Home & Living Co',
          'email': 'sales@homeandliving.ug',
          'phone': '+256703456789',
          'storeName': 'Home & Living - Quality Products',
          'address': 'Plot 78, Entebbe Road',
          'city': 'Kampala',
          'categories': ['Home', 'Kitchen'],
          'rating': 4.7,
          'totalOrders': 189,
          'totalRevenue': 22000000.0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'sample_seller_4',
          'storeId': 'sample_store_4',
          'name': 'Sports & Fitness Hub',
          'email': 'info@sportsandfitness.ug',
          'phone': '+256704567890',
          'storeName': 'Sports & Fitness - Active Lifestyle',
          'address': 'Plot 56, Kololo Hill',
          'city': 'Kampala',
          'categories': ['Sports'],
          'rating': 4.5,
          'totalOrders': 98,
          'totalRevenue': 12500000.0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        {
          'id': 'sample_seller_5',
          'storeId': 'sample_store_5',
          'name': 'Book Smart Uganda',
          'email': 'support@booksmart.ug',
          'phone': '+256705678901',
          'storeName': 'Book Smart - Educational Materials',
          'address': 'Plot 12, Wandegeya',
          'city': 'Kampala',
          'categories': ['Books', 'Stationery'],
          'rating': 4.9,
          'totalOrders': 267,
          'totalRevenue': 19800000.0,
          'isActive': true,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
      ];

      _suppliers.addAll(sampleSuppliers);
      notifyListeners();
      print('Sample suppliers added successfully! Total: ${_suppliers.length}');
    } catch (e) {
      print('Error adding sample suppliers: $e');
    }
  }

  /// Update supplier rating
  Future<void> updateSupplierRating(String supplierId, double newRating) async {
    try {
      final index = _suppliers.indexWhere((s) => s['id'] == supplierId);
      if (index != -1) {
        _suppliers[index]['rating'] = newRating;
        _suppliers[index]['updatedAt'] = DateTime.now().toIso8601String();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating supplier rating: $e');
    }
  }

  /// Increment supplier order count
  Future<void> incrementOrderCount(String supplierId, double amount) async {
    try {
      final index = _suppliers.indexWhere((s) => s['id'] == supplierId);
      if (index != -1) {
        _suppliers[index]['totalOrders'] =
            (_suppliers[index]['totalOrders'] as int? ?? 0) + 1;
        _suppliers[index]['totalRevenue'] =
            (_suppliers[index]['totalRevenue'] as double? ?? 0.0) + amount;
        _suppliers[index]['updatedAt'] = DateTime.now().toIso8601String();
        notifyListeners();
      }
    } catch (e) {
      print('Error updating supplier orders: $e');
    }
  }
}
