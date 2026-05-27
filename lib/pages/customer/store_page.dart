import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/services/product_service.dart';
import 'package:madpractical/services/auth_service.dart';

/// Store page showing a seller's products and info with a "Message" button.
class StorePage extends ConsumerStatefulWidget {
  final String sellerId;

  const StorePage({super.key, this.sellerId = ''});

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
      if (widget.sellerId.isNotEmpty) {
        // 1. Load seller info from user doc
        final sellerData = await _authService.getUserData(widget.sellerId);

        String name = 'Store';
        String email = '';
        String phone = '';
        String description = 'Campus store offering quality products.';
        String joinedStr = '';
        bool showContact = true;

        if (sellerData != null) {
          // Parse join date
          final joined = sellerData['createdAt'];
          if (joined is Timestamp) {
            final dt = joined.toDate();
            final months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];
            joinedStr = '${months[dt.month - 1]} ${dt.year}';
          } else if (joined is String && joined.isNotEmpty) {
            joinedStr = joined;
          }

          // Use user doc values as defaults
          name = sellerData['name'] ?? 'Store';
          email = sellerData['email'] ?? '';
          phone = sellerData['phone'] ?? '';
          description = sellerData['description'] ?? 'Campus store offering quality products.';

          // 2. Load store doc if it exists (overrides user doc fields with store-specific data)
          String? storeId = sellerData['storeId'] as String?;
          
          // If no storeId on user doc, try finding store by sellerId (fallback for existing sellers)
          if (storeId == null || storeId.isEmpty) {
            final storeSnapshot = await FirebaseFirestore.instance
                .collection('stores')
                .where('sellerId', isEqualTo: widget.sellerId)
                .limit(1)
                .get();
            if (storeSnapshot.docs.isNotEmpty) {
              storeId = storeSnapshot.docs.first.id;
            }
          }
          
          if (storeId != null && storeId.isNotEmpty) {
            final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
            if (storeDoc.exists) {
              final storeData = storeDoc.data()!;
              name = storeData['storeName'] as String? ?? name;
              description = storeData['storeDescription'] as String? ?? description;
              phone = storeData['storePhone'] as String? ?? phone;
              email = storeData['storeEmail'] as String? ?? email;
              showContact = storeData['showContact'] as bool? ?? true;
            }
          }
        }

        _storeInfo = {
          'name': name,
          'email': email,
          'phone': phone,
          'rating': 4.0,
          'totalProducts': 0,
          'joined': joinedStr,
          'description': description,
          'showContact': showContact,
        };

        // 3. Load seller's products
        final allProducts = await _productService.getAllProducts();
        final products = allProducts.where((p) {
          final pSellerId = p['sellerId'] as String? ?? p['userId'] as String? ?? '';
          return pSellerId == widget.sellerId;
        }).toList();
        _products = products;
        _storeInfo['totalProducts'] = products.length;
      } else {
        // No seller ID provided
        _storeInfo = {
          'name': 'Store',
          'email': '',
          'phone': '',
          'rating': 4.0,
          'totalProducts': 0,
          'joined': '',
          'description': 'Store information not available.',
          'showContact': true,
        };
      }
    } catch (e) {
      // Fallback to defaults on error
      _storeInfo = {
        'name': 'Store',
        'email': '',
        'phone': '',
        'rating': 4.0,
        'totalProducts': 0,
        'joined': '',
        'description': 'Unable to load store information.',
        'showContact': true,
      };
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
          if (widget.sellerId.isNotEmpty)
            _MessageButton(sellerId: widget.sellerId),
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
                            Flexible(
                              child: Text(
                                'Joined ${_storeInfo['joined']}',
                                style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── Contact Info ───────────────────────────────────────
              if (true == _storeInfo['showContact'] && ((_storeInfo['email']?.toString() ?? '').isNotEmpty || (_storeInfo['phone']?.toString() ?? '').isNotEmpty))
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
                      if ((_storeInfo['email']?.toString() ?? '').isNotEmpty)
                        _buildContactRow(Icons.email_outlined, _storeInfo['email'] ?? ''),
                      if ((_storeInfo['phone']?.toString() ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildContactRow(Icons.phone_outlined, _storeInfo['phone'] ?? ''),
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

  Widget _buildContactRow(IconData icon, dynamic text) {
    final displayText = text is String ? text : text?.toString() ?? '';
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
            overflow: TextOverflow.ellipsis,
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
                child: product['image'] != null && product['image'].toString().isNotEmpty
                    ? Image.network(
                        product['image'],
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
            if (product['discount'] != null &&
                product['discount'].toString().isNotEmpty &&
                product['discount'].toString().replaceAll(RegExp(r'[^0-9.]'), '').isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product['discount'].toString(),
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
      final numericString = price.replaceAll(RegExp(r'[^0-9.]'), '');
      return (double.tryParse(numericString) ?? 0).toStringAsFixed(0);
    }
    return '0';
  }
}

/// Message button widget that safely reads user provider
class _MessageButton extends ConsumerWidget {
  final String sellerId;

  const _MessageButton({required this.sellerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider);

    // Only show message button for customers viewing a different seller's store
    if (userState.role != 'customer' || sellerId.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _openChat(context, ref, userState),
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
    );
  }

  void _openChat(BuildContext context, WidgetRef ref, UserState userState) {
    if (userState.userId == null || userState.userId!.isEmpty) return;

    // Sort participant IDs for consistency
    final participants = [userState.userId!, sellerId]..sort();
    final sortedChatId = 'direct_${participants[0]}_${participants[1]}';

    // Navigate to chat screen
    context.push(
      '/chat/$sortedChatId',
      extra: {
        'name': 'Store Chat',
        'isOrderChat': false,
      },
    );
  }
}
