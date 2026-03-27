import 'package:madpractical/services/product_service.dart';

class SampleDataHelper {
  static final ProductService _productService = ProductService();

  // Call this method to populate Firebase with sample data
  static Future<void> addSampleData() async {
    try {
      await _productService.addSampleProducts();
      print('Sample data added successfully!');
    } catch (e) {
      print('Error adding sample data: $e');
    }
  }
}