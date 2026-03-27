import 'package:flutter/material.dart';
import 'package:madpractical/widgets/app_bottom_navigation.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/pages/product_details.dart';
import 'package:madpractical/services/wishlist_manager.dart';
import 'package:madpractical/services/cart_manager.dart';
import 'package:madpractical/services/notification_manager.dart';
import 'package:madpractical/services/product_service.dart';
import 'package:madpractical/pages/notifications_list_screen.dart';
import 'package:madpractical/pages/ai_chat_support_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final WishlistManager _wishlistManager = WishlistManager();
  final CartManager _cartManager = CartManager();
  final NotificationManager _notificationManager = NotificationManager();
  final ProductService _productService = ProductService();
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  String _sortBy = 'Default';
  double _minPrice = 0;
  double _maxPrice = 200000;
  double _minRating = 0;
  
  // Data from Firebase
  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  
  final List<Map<String, String>> banners = [
    {
      'title': 'Special Offers',
      'subtitle': 'Up to 50% Off Selected Items',
      'image': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=300&fit=crop',
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Check Out Latest Products',
      'image': 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=800&h=300&fit=crop',
    },
    {
      'title': 'Flash Sale',
      'subtitle': 'Limited Time Deals',
      'image': 'https://images.unsplash.com/photo-1607082349566-187342175e2f?w=800&h=300&fit=crop',
    },
  ];
  
  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto-scroll banner every 3 seconds
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
    _wishlistManager.addListener(_onWishlistChanged);
    _cartManager.addListener(_onCartChanged);
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Test Firebase connection first
      await _productService.testFirebaseConnection();

      // Load products and categories from Firebase
      final products = await _productService.getAllProducts();
      final categoryList = await _productService.getCategories();

      print('Loaded ${products.length} products');
      print('Loaded ${categoryList.length} categories');

      setState(() {
        allProducts = products;
        categories = [
          {'icon': Icons.grid_view, 'title': 'All'},
          ...categoryList.map((cat) => {
            'icon': cat['icon'] is IconData ? cat['icon'] : _getIconFromString(cat['icon'].toString()),
            'title': cat['title'],
          }),
        ];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
        // Use fallback data
        _loadFallbackData();
      });
    }
  }

  void _loadFallbackData() {
    allProducts = [
      {
        'name': 'Wireless Headphones',
        'price': 'UGX 85,000',
        'rating': 4.8,
        'discount': '-20%',
        'category': 'Electronics',
        'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
        'description': 'Premium wireless headphones with noise cancellation and superior sound quality.',
      },
      {
        'name': 'Smart Watch',
        'price': 'UGX 120,000',
        'rating': 4.6,
        'discount': '-15%',
        'category': 'Electronics',
        'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
        'description': 'Advanced smartwatch with fitness tracking and health monitoring features.',
      },
      {
        'name': 'Designer T-Shirt',
        'price': 'UGX 45,000',
        'rating': 4.9,
        'discount': '-25%',
        'category': 'Fashion',
        'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
        'description': 'Premium cotton t-shirt with modern design and comfortable fit.',
      },
    ];

    categories = [
      {'icon': Icons.grid_view, 'title': 'All'},
      {'icon': Icons.devices, 'title': 'Electronics'},
      {'icon': Icons.checkroom, 'title': 'Fashion'},
      {'icon': Icons.home, 'title': 'Home'},
      {'icon': Icons.sports_soccer, 'title': 'Sports'},
      {'icon': Icons.local_grocery_store, 'title': 'Groceries'},
      {'icon': Icons.auto_stories, 'title': 'Books'},
    ];
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'devices': return Icons.devices;
      case 'checkroom': return Icons.checkroom;
      case 'home': return Icons.home;
      case 'sports_soccer': return Icons.sports_soccer;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'auto_stories': return Icons.auto_stories;
      case 'spa': return Icons.spa;
      case 'directions_car': return Icons.directions_car;
      case 'toys': return Icons.toys;
      case 'business_center': return Icons.business_center;
      case 'category': return Icons.category;
      default: return Icons.category;
    }
  }

  void _onWishlistChanged() {
    setState(() {});
  }

  void _onCartChanged() {
    setState(() {});
  }
  
  void _autoScrollBanner() {
    if (!mounted) return;
    final nextPage = (_currentBannerPage + 1) % banners.length;
    _bannerController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    Future.delayed(const Duration(seconds: 3), _autoScrollBanner);
  }
  
  @override
  void dispose() {
    _bannerController.dispose();
    _wishlistManager.removeListener(_onWishlistChanged);
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredProducts {
    var products = allProducts;
    
    // Filter by category
    if (selectedCategory != 'All') {
      products = products.where((product) => product['category'] == selectedCategory).toList();
    }
    
    // Filter by price range
    products = products.where((product) {
      final price = _getDiscountedPrice(product);
      return price >= _minPrice && price <= _maxPrice;
    }).toList();
    
    // Filter by rating
    products = products.where((product) {
      final rating = product['rating'] as double;
      return rating >= _minRating;
    }).toList();
    
    // Sort products
    switch (_sortBy) {
      case 'Price: Low to High':
        products.sort((a, b) => _getDiscountedPrice(a).compareTo(_getDiscountedPrice(b)));
        break;
      case 'Price: High to Low':
        products.sort((a, b) => _getDiscountedPrice(b).compareTo(_getDiscountedPrice(a)));
        break;
      case 'Rating: High to Low':
        products.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
        break;
      case 'Name: A to Z':
        products.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));
        break;
      case 'Default':
      default:
        break;
    }
    
    return products;
  }

  double _extractPrice(String priceString) {
    final numericString = priceString.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(numericString) ?? 0.0;
  }

  double _getDiscountedPrice(Map<String, dynamic> product) {
    final originalPrice = _extractPrice(product['price']);
    
    if (product['discount'] != null && product['discount'].toString().isNotEmpty) {
      final discountStr = product['discount'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      final discountPercent = double.tryParse(discountStr) ?? 0.0;
      
      if (discountPercent > 0) {
        final discountAmount = originalPrice * (discountPercent / 100);
        return originalPrice - discountAmount;
      }
    }
    
    return originalPrice;
  }

  Widget _buildPriceSection(Map<String, dynamic> product) {
    final originalPrice = _extractPrice(product['price']);
    final discountedPrice = _getDiscountedPrice(product);
    final hasDiscount = originalPrice != discountedPrice;

    if (hasDiscount) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              product['price'],
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.secondaryText,
                decoration: TextDecoration.lineThrough,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'UGX ${discountedPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10,
                color: AppColors.primary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      return Text(
        product['price'],
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: AppColors.primary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filter & Sort',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _sortBy = 'Default';
                          _minPrice = 0;
                          _maxPrice = 200000;
                          _minRating = 0;
                        });
                        setState(() {});
                      },
                      child: const Text(
                        'Reset',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Sort By Section
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'Default',
                          'Price: Low to High',
                          'Price: High to Low',
                          'Rating: High to Low',
                          'Name: A to Z',
                        ].map((sort) {
                          final isSelected = _sortBy == sort;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _sortBy = sort;
                              });
                              setState(() {});
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.lightGrey.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightGrey,
                                ),
                              ),
                              child: Text(
                                sort,
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.text,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Price Range Section
                      const Text(
                        'Price Range',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'UGX ${_minPrice.toInt()}',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'UGX ${_maxPrice.toInt()}',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 200000,
                        divisions: 20,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.lightGrey,
                        onChanged: (values) {
                          setModalState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                          setState(() {});
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Rating Section
                      const Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: List.generate(5, (index) {
                          final rating = index + 1;
                          final isSelected = _minRating >= rating;
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                _minRating = rating.toDouble();
                              });
                              setState(() {});
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: isSelected
                                    ? Colors.amber
                                    : AppColors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        }),
                      ),
                      if (_minRating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_minRating.toInt()} stars and above',
                            style: const TextStyle(
                              color: AppColors.secondaryText,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              
              // Apply Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Apply Filters (${filteredProducts.length} products)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      height: 260, // Increased from 240 to accommodate content
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Section
          Stack(
            children: [
              Container(
                height: 130,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.05),
                      AppColors.secondary.withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    product['image'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: AppColors.grey,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withValues(alpha: 0.1),
                              AppColors.secondary.withValues(alpha: 0.05),
                            ],
                          ),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Discount Badge
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    product['discount'],
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    final isInWishlist = _wishlistManager.isInWishlist(product['name']);
                    _wishlistManager.toggleWishlist(product);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isInWishlist 
                              ? '${product['name']} removed from wishlist'
                              : '${product['name']} added to wishlist'
                        ),
                        backgroundColor: isInWishlist ? AppColors.error : AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _wishlistManager.isInWishlist(product['name'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: _wishlistManager.isInWishlist(product['name'])
                          ? Colors.red
                          : AppColors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Product Details Section
          Expanded( // Use Expanded instead of fixed height
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                // Product Name
                SizedBox(
                  height: 34,
                  child: Text(
                    product['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.text.withValues(alpha: 0.9),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 4), // Reduced spacing
                
                // Rating and Cart Icon Row
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product['rating']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.text,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        _cartManager.addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product['name']} added to cart'),
                            backgroundColor: AppColors.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: _cartManager.isInCart(product['name'])
                              ? AppColors.accent
                              : AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _cartManager.isInCart(product['name'])
                              ? Icons.shopping_cart
                              : Icons.add_shopping_cart,
                          size: 16,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4), // Reduced spacing
                
                // Price with Discount
                _buildPriceSection(product),
              ],
            ),
          ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Welcome, ',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: 'User',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/customer/orders');
            },
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.text,
            ),
            tooltip: 'My Orders',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsListScreen(),
                ),
              );
            },
            icon: _notificationManager.unreadCount > 0
                ? Badge(
                    label: Text('${_notificationManager.unreadCount}'),
                    backgroundColor: AppColors.error,
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.text,
                    ),
                  )
                : const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.text,
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading products...',
                    style: TextStyle(
                      color: AppColors.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Using offline data',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
        children: [
          // Fixed Search Bar and Categories
          Container(
            color: AppColors.background,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.search, color: AppColors.grey),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search for Product',
                              hintStyle: TextStyle(color: AppColors.grey),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Popular Categories
            const Text(
              'Popular Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 12),
            
            SizedBox(
              height: 75,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategory == category['title'];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = category['title'];
                      });
                    },
                    child: Container(
                      width: 65,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary
                                    : AppColors.lightGrey,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              category['icon'],
                              color: isSelected 
                                  ? AppColors.primary
                                  : AppColors.text,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category['title'],
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected 
                                  ? AppColors.primary
                                  : AppColors.text,
                              fontWeight: isSelected 
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
              ],
            ),
          ),

          // Scrollable Content (Banner and Products)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  
                  // Banner Slideshow
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _bannerController,
                onPageChanged: (index) {
                  setState(() {
                    _currentBannerPage = index;
                  });
                },
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              gradient: AppColors.primaryGradient,
                            ),
                          ),
                          Image.network(
                            banner['image']!,
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                ),
                                child: const Center(
                                  child: Icon(Icons.shopping_bag, size: 50, color: AppColors.white),
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            top: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  banner['title']!,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner['subtitle']!,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Page indicators
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                banners.length,
                                (dotIndex) => Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: dotIndex == _currentBannerPage ? 24 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: dotIndex == _currentBannerPage
                                        ? AppColors.white
                                        : AppColors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Our Products
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedCategory == 'All' 
                      ? 'Our Products' 
                      : '$selectedCategory Products',
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Product Grid - Flexible Height
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: _buildProductCard(product),
                );
              },
            ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button for Customer Support Chat
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatSupportScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.support_agent,
          color: AppColors.white,
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        wishlistCount: _wishlistManager.itemCount,
        cartCount: _cartManager.itemCount,
      ),
    );
  }
}

