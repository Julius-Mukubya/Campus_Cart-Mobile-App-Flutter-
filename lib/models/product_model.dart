class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String? image;
  final List<String>? images;
  final String categoryId;
  final String categoryName;
  final String sellerId;
  final String sellerName;
  final double rating;
  final int reviewCount;
  final int stock;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    this.image,
    this.images,
    required this.categoryId,
    required this.categoryName,
    required this.sellerId,
    required this.sellerName,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.stock = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get effective price (discount if available, otherwise regular price)
  double get effectivePrice => discountPrice ?? price;

  /// Calculate discount percentage
  double? get discountPercentage {
    if (discountPrice != null && discountPrice! > 0) {
      return ((price - discountPrice!) / price * 100);
    }
    return null;
  }

  /// Create ProductModel from Firestore document
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ProductModel(
      id: docId,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble(),
      image: data['image'],
      images: List<String>.from(data['images'] ?? []),
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      stock: data['stock'] ?? 0,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  /// Convert ProductModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'image': image,
      'images': images,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'rating': rating,
      'reviewCount': reviewCount,
      'stock': stock,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create a copy with modified fields
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? discountPrice,
    String? image,
    List<String>? images,
    String? categoryId,
    String? categoryName,
    String? sellerId,
    String? sellerName,
    double? rating,
    int? reviewCount,
    int? stock,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      image: image ?? this.image,
      images: images ?? this.images,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'ProductModel(id: $id, name: $name, price: $price, seller: $sellerName)';
}
