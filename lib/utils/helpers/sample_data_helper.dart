import 'package:madpractical/services/business/product_service.dart';
import 'package:madpractical/services/business/category_service.dart';
import 'package:madpractical/services/business/supplier_service.dart';
import 'package:madpractical/utils/helpers/sample_orders_helper.dart';
import 'package:madpractical/utils/app_logger.dart';

class SampleDataHelper {
  static final ProductService _productService = ProductService();
  static final CategoryService _categoryService = CategoryService();
  static final SupplierService _supplierService = SupplierService();

  // Call this method to populate the app with sample data
  static Future<void> addSampleData() async {
    try {
      AppLogger.info('Starting to seed sample data...');

      // Seed categories first
      AppLogger.info('Seeding categories...');
      await _categoryService.addSampleCategories();

      // Seed suppliers
      AppLogger.info('Seeding suppliers...');
      await _supplierService.addSampleSuppliers();

      // Seed products
      AppLogger.info('Seeding products...');
      await _productService.addSampleProducts();

      // Seed sample orders
      AppLogger.info('Seeding sample orders...');
      await SampleOrdersHelper.addSampleOrders();

      AppLogger.info('✓ All sample data added successfully!');
    } catch (e) {
      AppLogger.error('✗ Error adding sample data: $e', error: e);
    }
  }
}
