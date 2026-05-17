import 'package:madpractical/services/business/product_service.dart';
import 'package:madpractical/services/business/category_service.dart';
import 'package:madpractical/services/business/supplier_service.dart';
import 'package:madpractical/utils/helpers/sample_orders_helper.dart';

class SampleDataHelper {
  static final ProductService _productService = ProductService();
  static final CategoryService _categoryService = CategoryService();
  static final SupplierService _supplierService = SupplierService();

  // Call this method to populate the app with sample data
  static Future<void> addSampleData() async {
    try {
      print('Starting to seed sample data...');

      // Seed categories first
      print('Seeding categories...');
      await _categoryService.addSampleCategories();

      // Seed suppliers
      print('Seeding suppliers...');
      await _supplierService.addSampleSuppliers();

      // Seed products
      print('Seeding products...');
      await _productService.addSampleProducts();

      // Seed sample orders
      print('Seeding sample orders...');
      await SampleOrdersHelper.addSampleOrders();

      print('✓ All sample data added successfully!');
    } catch (e) {
      print('✗ Error adding sample data: $e');
    }
  }
}
