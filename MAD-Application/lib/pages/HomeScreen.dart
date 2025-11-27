import 'package:flutter/material.dart';
import 'package:madpractical/widgets/app_bottom_navigation.dart';
import 'package:madpractical/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  Set<String> wishlistItems = {}; // Track wishlist by product name
  
  final List<Map<String, dynamic>> categories = [
    {'icon': Icons.grid_view, 'title': 'All'},
    {'icon': Icons.devices, 'title': 'Electronics'},
    {'icon': Icons.checkroom, 'title': 'Fashion'},
    {'icon': Icons.home, 'title': 'Home'},
    {'icon': Icons.sports_soccer, 'title': 'Sports'},
  ];

  final List<Map<String, dynamic>> allProducts = [
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
    {
      'name': 'Coffee Maker',
      'price': 'UGX 95,000',
      'rating': 4.7,
      'discount': '-18%',
      'category': 'Home',
      'image': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=400&h=400&fit=crop',
      'description': 'Automatic coffee maker with programmable settings and thermal carafe.',
    },
    {
      'name': 'Running Shoes',
      'price': 'UGX 75,000',
      'rating': 4.5,
      'discount': '-30%',
      'category': 'Sports',
      'image': 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
      'description': 'Lightweight running shoes with excellent cushioning and breathable material.',
    },
    {
      'name': 'Bluetooth Speaker',
      'price': 'UGX 42,000',
      'rating': 4.8,
      'discount': '-22%',
      'category': 'Electronics',
      'image': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
      'description': 'Portable Bluetooth speaker with rich bass and long battery life.',
    },
    {
      'name': 'Table Lamp',
      'price': 'UGX 35,000',
      'rating': 4.6,
      'discount': '-12%',
      'category': 'Home',
      'image': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
      'description': 'Modern LED table lamp with adjustable brightness and USB charging port.',
    },
    {
      'name': 'Yoga Mat',
      'price': 'UGX 25,000',
      'rating': 4.4,
      'discount': '-28%',
      'category': 'Sports',
      'image': 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400&h=400&fit=crop',
      'description': 'Non-slip yoga mat with extra cushioning for comfortable workouts.',
    },
  ];

  List<Map<String, dynamic>> get filteredProducts {
    if (selectedCategory == 'All') {
      return allProducts;
    }
    return allProducts.where((product) => product['category'] == selectedCategory).toList();
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
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
                      AppColors.primary.withOpacity(0.05),
                      AppColors.secondary.withOpacity(0.02),
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
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.05),
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
                              AppColors.primary.withOpacity(0.1),
                              AppColors.secondary.withOpacity(0.05),
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
                        AppColors.accent.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
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
                    setState(() {
                      if (wishlistItems.contains(product['name'])) {
                        wishlistItems.remove(product['name']);
                      } else {
                        wishlistItems.add(product['name']);
                      }
                    });
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
                      wishlistItems.contains(product['name'])
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 16,
                      color: wishlistItems.contains(product['name'])
                          ? Colors.red
                          : AppColors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Product Details Section
          SizedBox(
            height: 110,
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
                      color: AppColors.text.withOpacity(0.9),
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                const SizedBox(height: 6),
                
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
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.add_shopping_cart,
                        size: 16,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                // Price
                Text(
                  product['price'],
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.text),
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
            const SizedBox(height: 16),
            
            SizedBox(
              height: 90,
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
                      width: 70,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? AppColors.primary.withOpacity(0.1)
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
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
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
            const SizedBox(height: 20),

            // Banner Image
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
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
                      'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=300&fit=crop',
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
                            AppColors.primary.withOpacity(0.8),
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
                          const Text(
                            'Special Offers',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Up to 50% Off Selected Items',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Shop Now',
                              style: TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = 'All';
                    });
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
                        builder: (_) => ProductDetailsScreen(product: product),
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

      // Bottom Navigation Bar
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: 0,
        wishlistCount: wishlistItems.length,
      ),
    );
  }
}

// ---------------- Product Details Page ----------------

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product['name'],
          style: const TextStyle(color: AppColors.black),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['image'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 80, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Product name and price
            Text(
              product['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product['price'],
              style: const TextStyle(
                fontSize: 18,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Rating
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 18),
                Text('${product['rating']}'),
              ],
            ),
            const SizedBox(height: 16),

            // Description
            Text(
              product['description'],
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const Spacer(),

            // Add to cart button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to the cart screen (uses the named route registered in mainpage.dart)
                  Navigator.pushNamed(context, '/cart');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
