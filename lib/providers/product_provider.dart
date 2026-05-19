import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../utils/app_logger.dart';

/// Product state model
class ProductState {
  final List<Map<String, dynamic>> allProducts;
  final List<Map<String, dynamic>> filteredProducts;
  final List<Map<String, dynamic>> categories;
  final bool isLoading;
  final String? error;
  final String filterQuery;

  const ProductState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.isLoading = false,
    this.error,
    this.filterQuery = '',
  });

  ProductState copyWith({
    List<Map<String, dynamic>>? allProducts,
    List<Map<String, dynamic>>? filteredProducts,
    List<Map<String, dynamic>>? categories,
    bool? isLoading,
    String? error,
    String? filterQuery,
  }) {
    return ProductState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filterQuery: filterQuery ?? this.filterQuery,
    );
  }
}

/// Product notifier for managing product state
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  ProductNotifier() : super(const ProductState()) {
    _initialize();
  }

  /// Initialize products and categories
  Future<void> _initialize() async {
    await loadProducts();
    await loadCategories();
  }

  /// Load all products
  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _productService.getAllProducts();
      state = state.copyWith(
        isLoading: false,
        allProducts: products,
        filteredProducts: products,
      );
      AppLogger.info('Products loaded: ${products.length}');
    } catch (e) {
      AppLogger.error('Failed to load products', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load products: $e',
      );
    }
  }

  /// Load categories
  Future<void> loadCategories() async {
    try {
      final categories = await _categoryService.fetchCategories();
      state = state.copyWith(categories: categories);
      AppLogger.info('Categories loaded: ${categories.length}');
    } catch (e) {
      AppLogger.error('Failed to load categories', error: e);
    }
  }

  /// Filter products by category
  Future<void> filterByCategory(String categoryId) async {
    try {
      if (categoryId == 'All') {
        state = state.copyWith(
          filteredProducts: state.allProducts,
          filterQuery: 'All',
        );
        return;
      }

      final filtered = state.allProducts
          .where((product) => product['category'] == categoryId)
          .toList();

      state = state.copyWith(
        filteredProducts: filtered,
        filterQuery: categoryId,
      );
      AppLogger.info('Filtered by category: $categoryId (${filtered.length} products)');
    } catch (e) {
      AppLogger.error('Failed to filter by category', error: e);
    }
  }

  /// Search products
  Future<void> searchProducts(String query) async {
    try {
      if (query.isEmpty) {
        state = state.copyWith(
          filteredProducts: state.allProducts,
          filterQuery: '',
        );
        return;
      }

      final lowerQuery = query.toLowerCase();
      final results = state.allProducts.where((product) {
        final name = product['name']?.toString().toLowerCase() ?? '';
        final description = product['description']?.toString().toLowerCase() ?? '';
        final category = product['category']?.toString().toLowerCase() ?? '';

        return name.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            category.contains(lowerQuery);
      }).toList();

      state = state.copyWith(
        filteredProducts: results,
        filterQuery: query,
      );
      AppLogger.info('Search results: ${results.length} products for "$query"');
    } catch (e) {
      AppLogger.error('Failed to search products', error: e);
    }
  }

  /// Refresh products from Firebase
  Future<void> refreshProducts() async {
    await loadProducts();
    await loadCategories();
  }

  /// Sort products
  void sortProducts(String sortBy) {
    final sorted = [...state.filteredProducts];

    switch (sortBy) {
      case 'price_low':
        sorted.sort((a, b) {
          final priceA = _extractPrice(a['price'].toString());
          final priceB = _extractPrice(b['price'].toString());
          return priceA.compareTo(priceB);
        });
        break;
      case 'price_high':
        sorted.sort((a, b) {
          final priceA = _extractPrice(a['price'].toString());
          final priceB = _extractPrice(b['price'].toString());
          return priceB.compareTo(priceA);
        });
        break;
      case 'rating':
        sorted.sort((a, b) =>
            (b['rating'] as double? ?? 0).compareTo(a['rating'] as double? ?? 0));
        break;
      case 'name':
        sorted.sort((a, b) =>
            a['name'].toString().compareTo(b['name'].toString()));
        break;
      default:
        break;
    }

    state = state.copyWith(filteredProducts: sorted);
  }

  /// Helper to extract numeric price from string
  double _extractPrice(String priceString) {
    final numericString = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }
}

/// Product provider
final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>(
  (ref) => ProductNotifier(),
);
