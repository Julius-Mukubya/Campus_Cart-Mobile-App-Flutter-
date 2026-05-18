class CartItemModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;
  final String? categoryId;
  final String? sellerId;
  final double? discount;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
    this.categoryId,
    this.sellerId,
    this.discount,
  });

  /// Calculate line total
  double get lineTotal => price * quantity;

  /// Calculate discount amount
  double get discountAmount => discount != null ? (price * quantity * discount! / 100) : 0.0;

  /// Calculate final price after discount
  double get finalPrice => lineTotal - discountAmount;

  /// Create CartItemModel from map
  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      productId: data['productId'] ?? '',
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: data['quantity'] ?? 1,
      image: data['image'],
      categoryId: data['categoryId'],
      sellerId: data['sellerId'],
      discount: (data['discount'] as num?)?.toDouble(),
    );
  }

  /// Convert CartItemModel to map
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'image': image,
      'categoryId': categoryId,
      'sellerId': sellerId,
      'discount': discount,
    };
  }

  /// Create a copy with modified fields
  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? image,
    String? categoryId,
    String? sellerId,
    double? discount,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      image: image ?? this.image,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      discount: discount ?? this.discount,
    );
  }

  @override
  String toString() => 'CartItemModel(productId: $productId, name: $name, quantity: $quantity, price: $price)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;
}
