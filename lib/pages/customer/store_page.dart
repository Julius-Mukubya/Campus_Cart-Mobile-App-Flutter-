import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/services/product_service.dart';
import 'package:madpractical/services/auth_service.dart';

/// Store page showing a seller's products and info with a "Message" button.
class StorePage extends ConsumerStatefulWidget {
  final String? sellerId;

  const StorePage({super.key, this.sellerId});

  @override
  ConsumerState<StorePage> createState() => _StorePageState();
}

class _StorePageState extends ConsumerState<StorePage> {
  final ProductService _productService = ProductService();
  final AuthService _authService = AuthService();

  Map<String, dynamic> _storeInfo = {};
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    try {
      // Load seller info from Firestore
      if (widget.sellerId != null && widget.sellerId!.isNotEmpty) {
        final sellerData = await _authService.getUserData(widget.sellerId!);
        if (sellerData != null) {
          _storeInfo = {
            'name': sellerData['name'] ?? 'Store',
            'email': sellerData['email'] ?? '',
            'phone': sellerData['phone'] ?? '',
            'rating': 4.0, // Will be replaced with real rating in Phase F
            'totalProducts': 0,
            'joined': sellerData['createdAt']?.toString() ?? '',
            'description': sellerData['description'] ?? 'Campus store offering quality products.',
          };
        }

        // Load seller's products (filter all products by seller's store)
        final allProducts = await _productService.getAllProducts();
        final products = allProducts.where((p) {
          final pSellerId = p['sellerId'] as String? ?? p['userId'] as String? ?? '';
          return pSellerId == widget.sellerId;
        }).toList();
        _products = products;
        _storeInfo['totalProducts'] = products.length;
      }
    } catch (e) {
      // Fallback to sample data on error
      _storeInfo = {
        'name': 'Store',
        'email': '',
        'phone': '',
        'rating': 4.0,
        'totalProducts': 0,
        'joined': '',
        'description': 'Campus store.',
      };
    }
    if (mounted) setState(() => _isLoading = false);
  }

  void _openChat() {
    final userState = ref.read(userProvider);
    if (userState.userId == null || userState.userId!.isEmpty) return;
    if (widget.sellerId == null || widget.sellerId!.isEmpty) return;

    // Sort participant IDs for consistency
    final participants = [userState.userId!, widget.sellerId!]..sort();
    final sortedChatId = 'direct_${participants[0]}_${participants[1]}';

    // Navigate to chat screen
    context.push(
      '/chat/$sortedChatId',
      extra: {
        'name': _storeInfo['name'] ?? 'Store',
        'isOrderChat': false,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.getBackground(context),
        appBar: AppBar(backgroundColor: AppColors.getBackground(context), elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, size: 16),
          ),
        ),
        title: Text(
          _storeInfo['name'] ?? 'Store',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false,
        actions: [
          if (userState.role == 'customer' && widget.sellerId != null)
            GestureDetector(
              onTap: _openChat,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.message_outlined,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStoreData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Store Info Header ──────────────────────────────────
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.1),
                      AppColors.secondary.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.store,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _storeInfo['name'] ?? 'Store',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_storeInfo['rating']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    '${_storeInfo['totalProducts']} products',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _storeInfo['description'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                    if (_storeInfo['joined'] != null && _storeInfo['joined'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Joined ${_storeInfo['joined']}',
                              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Contact Info ───────────────────────────────────────
              if (_storeInfo['email'].toString().isNotEmpty || _storeInfo['phone'].toString().isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.getSurface(context),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contact Info',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_storeInfo['email'].toString().isNotEmpty)
                        _buildContactRow(Icons.email_outlined, _storeInfo['email']),
                      if (_storeInfo['phone'].toString().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildContactRow(Icons.phone_outlined, _storeInfo['phone']),
                      ],
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ── Products Section ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              if (_products.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No products available',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ),
                )
              else
                ..._products.map((product) => _buildProductItem(product, isDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.getSurface(context),
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: const Color(0xFF2A2A2A)) : null,
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                    ? Image.network(
                        product['imageUrl'],
                        width: 80, height: 80, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_outlined, color: AppColors.grey),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image_outlined, color: AppColors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? 'Product',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${product['rating'] ?? 0}',
                        style: const TextStyle(fontSize: 13, color: Colors.amber),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'UGX ${_formatPrice(product['price'])}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (product['discount'] != null && (product['discount'] as num).toDouble() > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '-${product['discount']}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price is double || price is int) return price.toStringAsFixed(0);
    if (price is String) {
      final numericString = price.replaceAll(RegExp(r'[^0-9]'), '');
      return (double.tryParse(numericString) ?? 0).toStringAsFixed(0);
    }
    return '0';
  }
}