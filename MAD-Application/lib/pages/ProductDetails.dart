import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/wishlist_manager.dart';
import 'package:madpractical/services/cart_manager.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final WishlistManager _wishlistManager = WishlistManager();
  final CartManager _cartManager = CartManager();

  @override
  void initState() {
    super.initState();
    _wishlistManager.addListener(_onWishlistChanged);
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _wishlistManager.removeListener(_onWishlistChanged);
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onWishlistChanged() {
    setState(() {});
  }

  void _onCartChanged() {
    setState(() {});
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

  Widget _buildMainPriceSection() {
    final originalPrice = _extractPrice(widget.product['price'] ?? 'UGX 0');
    final discountedPrice = _getDiscountedPrice(widget.product);
    final hasDiscount = originalPrice != discountedPrice;

    if (hasDiscount) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product['price'] ?? 'UGX 0',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.secondaryText,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'UGX ${discountedPrice.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    } else {
      return Text(
        widget.product['price'] ?? 'UGX 0',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      );
    }
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

  final List<Map<String, dynamic>> allProducts = [
    {
      'name': 'Wireless Headphones',
      'price': 'UGX 85,000',
      'rating': 4.8,
      'discount': '-20%',
      'category': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
      'description': 'Premium wireless headphones with noise cancellation.',
    },
    {
      'name': 'Smart Watch',
      'price': 'UGX 120,000',
      'rating': 4.6,
      'discount': '-15%',
      'category': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400&h=400&fit=crop',
      'description': 'Advanced smartwatch with fitness tracking.',
    },
    {
      'name': 'Bluetooth Speaker',
      'price': 'UGX 42,000',
      'rating': 4.8,
      'discount': '-22%',
      'category': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
      'description': 'Portable Bluetooth speaker with rich bass.',
    },
    {
      'name': 'Designer T-Shirt',
      'price': 'UGX 45,000',
      'rating': 4.9,
      'discount': '-25%',
      'category': 'Fashion',
      'image': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400&h=400&fit=crop',
      'description': 'Premium cotton t-shirt with modern design.',
    },
    {
      'name': 'Coffee Maker',
      'price': 'UGX 95,000',
      'rating': 4.7,
      'discount': '-18%',
      'category': 'Home',
      'image': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=400&fit=crop',
      'description': 'Automatic coffee maker with programmable settings.',
    },
    {
      'name': 'Running Shoes',
      'price': 'UGX 75,000',
      'rating': 4.5,
      'discount': '-30%',
      'category': 'Sports',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
      'description': 'Lightweight running shoes with excellent cushioning.',
    },
    {
      'name': 'Organic Coffee Beans',
      'price': 'UGX 32,000',
      'rating': 4.7,
      'discount': '-15%',
      'category': 'Groceries',
      'image': 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&h=400&fit=crop',
      'description': 'Premium organic coffee beans with rich aroma and smooth taste.',
    },
    {
      'name': 'Fresh Fruit Basket',
      'price': 'UGX 45,000',
      'rating': 4.8,
      'discount': '-10%',
      'category': 'Groceries',
      'image': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=400&fit=crop',
      'description': 'Assorted fresh fruits including apples, oranges, and bananas.',
    },
    {
      'name': 'The Great Gatsby',
      'price': 'UGX 28,000',
      'rating': 4.9,
      'discount': '-20%',
      'category': 'Books',
      'image': 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=400&h=400&fit=crop',
      'description': 'Classic American novel by F. Scott Fitzgerald.',
    },
    {
      'name': 'Programming Guide',
      'price': 'UGX 55,000',
      'rating': 4.6,
      'discount': '-25%',
      'category': 'Books',
      'image': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
      'description': 'Comprehensive guide to modern programming languages and techniques.',
    },
  ];

  List<Map<String, dynamic>> get relatedProducts {
    // First, get products from the same category
    final sameCategoryProducts = allProducts
        .where((p) =>
            p['category'] == widget.product['category'] &&
            p['name'] != widget.product['name'])
        .toList();

    // If we have enough products from the same category, return them
    if (sameCategoryProducts.length >= 4) {
      return sameCategoryProducts.take(4).toList();
    }

    // Otherwise, add products from other categories to fill up to 4
    final otherProducts = allProducts
        .where((p) => p['name'] != widget.product['name'])
        .where((p) => !sameCategoryProducts.contains(p))
        .toList();

    return [...sameCategoryProducts, ...otherProducts].take(4).toList();
  }

  final List<Map<String, dynamic>> reviews = [
    {
      'user': 'User 1',
      'comment': 'Lorem ipsum dolor sit amet.',
      'time': 'A day ago',
    },
    {
      'user': 'User 1',
      'comment': 'Lorem ipsum dolor sit amet.',
      'time': 'A day ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.text,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.product['name'] ?? 'Product Name',
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightGrey),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.product['image'] ?? '',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 60,
                              color: AppColors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (widget.product['discount'] != null)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.accent,
                              AppColors.accent.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.product['discount'],
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        final isInWishlist = _wishlistManager.isInWishlist(widget.product['name']);
                        _wishlistManager.toggleWishlist(widget.product);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWishlist 
                                  ? '${widget.product['name']} removed from wishlist'
                                  : '${widget.product['name']} added to wishlist'
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
                          color: AppColors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _wishlistManager.isInWishlist(widget.product['name'])
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 20,
                          color: _wishlistManager.isInWishlist(widget.product['name'])
                              ? Colors.red
                              : AppColors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: _buildMainPriceSection(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.product['rating'] ?? 4.5} (99 Reviews)',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product['description'] ??
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labo',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add to Cart Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _cartManager.isInCart(widget.product['name'])
                            ? [
                                AppColors.accent,
                                AppColors.accent.withOpacity(0.85),
                              ]
                            : [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.85),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: (_cartManager.isInCart(widget.product['name'])
                                  ? AppColors.accent
                                  : AppColors.primary)
                              .withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (!_cartManager.isInCart(widget.product['name'])) {
                          _cartManager.addToCart(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${widget.product['name']} added to cart'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, '/cart');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(
                        _cartManager.isInCart(widget.product['name'])
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart_rounded,
                        color: AppColors.white,
                      ),
                      label: Text(
                        _cartManager.isInCart(widget.product['name'])
                            ? 'View Cart'
                            : 'Add to Cart',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Text(
                            '4.5/5',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '(99 reviews)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < 4
                                    ? Icons.star
                                    : Icons.star_half,
                                color: Colors.amber,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildRatingBar(5, 0.6),
                            const SizedBox(height: 4),
                            _buildRatingBar(4, 0.25),
                            const SizedBox(height: 4),
                            _buildRatingBar(3, 0.1),
                            const SizedBox(height: 4),
                            _buildRatingBar(2, 0.03),
                            const SizedBox(height: 4),
                            _buildRatingBar(1, 0.02),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User Reviews
                  ...reviews.map((review) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.lightGrey),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review['user'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: AppColors.text,
                                        ),
                                      ),
                                      Text(
                                        review['time'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    review['comment'],
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),

                  // Add Review Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Write a Review',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Rating Stars
                        Row(
                          children: [
                            const Text(
                              'Your Rating:',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: List.generate(
                                5,
                                (index) => GestureDetector(
                                  onTap: () {
                                    // Handle rating tap
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: Icon(
                                      Icons.star_border,
                                      color: Colors.amber,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Review Text Field
                        TextField(
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Share your experience with this product...',
                            hintStyle: TextStyle(
                              color: AppColors.grey,
                              fontSize: 14,
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle review submission
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Review submitted!'),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),

            // Relevant Products
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Relevant Products',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: const Text(
                          'View all',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: relatedProducts.length,
                      itemBuilder: (context, index) {
                        final product = relatedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          child: Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.lightGrey),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    child: Image.network(
                                      product['image'],
                                      height: 120,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          height: 120,
                                          decoration: BoxDecoration(
                                            color: AppColors.lightGrey,
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(16),
                                              topRight: Radius.circular(16),
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
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.accent,
                                            AppColors.accent.withOpacity(0.8),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
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
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        final isInWishlist = _wishlistManager.isInWishlist(product['name']);
                                        _wishlistManager.toggleWishlist(product);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isInWishlist
                                                  ? '${product['name']} removed from wishlist'
                                                  : '${product['name']} added to wishlist',
                                            ),
                                            backgroundColor: isInWishlist ? AppColors.error : AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(8),
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
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.text,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
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
                                            fontWeight: FontWeight.w600,
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
                                              size: 14,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildPriceSection(product),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rating bar helper widget
  Widget _buildRatingBar(int stars, double progress) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.text,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.lightGrey,
              color: Colors.amber,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }
}
