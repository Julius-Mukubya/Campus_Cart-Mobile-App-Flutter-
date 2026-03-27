import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/product_service.dart';

class DebugFirebaseScreen extends StatefulWidget {
  const DebugFirebaseScreen({super.key});

  @override
  State<DebugFirebaseScreen> createState() => _DebugFirebaseScreenState();
}

class _DebugFirebaseScreenState extends State<DebugFirebaseScreen> {
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String _status = 'Ready to test Firebase connection';

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Testing Firebase connection...';
    });

    try {
      // Test connection
      await _productService.testFirebaseConnection();
      
      // Load products
      final products = await _productService.getAllProducts();
      final categories = await _productService.getCategories();
      
      setState(() {
        _products = products;
        _categories = categories;
        _status = 'Success! Loaded ${products.length} products and ${categories.length} categories';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase Connection Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Testing...'),
                                ],
                              )
                            : const Text('Test Firebase Connection'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results
            if (_products.isNotEmpty || _categories.isNotEmpty)
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const TabBar(
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.secondaryText,
                        indicatorColor: AppColors.primary,
                        tabs: [
                          Tab(text: 'Products'),
                          Tab(text: 'Categories'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Products Tab
                            ListView.builder(
                              itemCount: _products.length,
                              itemBuilder: (context, index) {
                                final product = _products[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: product['image'] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              product['image'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: AppColors.lightGrey,
                                                  child: const Icon(Icons.image),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            width: 50,
                                            height: 50,
                                            color: AppColors.lightGrey,
                                            child: const Icon(Icons.image),
                                          ),
                                    title: Text(product['name'] ?? 'No name'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Price: ${product['price'] ?? 'No price'}'),
                                        Text('Category: ${product['category'] ?? 'No category'}'),
                                        Text('Rating: ${product['rating'] ?? 'No rating'}'),
                                        Text(
                                          'Image URL: ${product['image'] ?? 'MISSING'}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: product['image'] != null
                                                ? AppColors.success
                                                : AppColors.error,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    isThreeLine: true,
                                  ),
                                );
                              },
                            ),
                            
                            // Categories Tab
                            ListView.builder(
                              itemCount: _categories.length,
                              itemBuilder: (context, index) {
                                final category = _categories[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                      child: Icon(
                                        Icons.category,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    title: Text(category['title'] ?? 'No title'),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Description: ${category['description'] ?? 'No description'}'),
                                        Text('Product Count: ${category['productCount'] ?? 0}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}