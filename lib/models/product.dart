import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final String image;
  final double price;
  
  // Seller information
  final String sellerId;
  final String storeId;
  
  // Inventory
  final int quantity;
  
  // Categorization
  final String category;
  
  // Performance
  final double rating;
  final int reviewCount;
  
  // Status
  final bool isActive;
  
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.sellerId,
    required this.storeId,
    required this.quantity,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json, String docId) {
    return Product(
      id: docId,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      sellerId: json['sellerId'] ?? '',
      storeId: json['storeId'] ?? '',
      quantity: json['quantity'] ?? 0,
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'image': image,
        'price': price,
        'sellerId': sellerId,
        'storeId': storeId,
        'quantity': quantity,
        'category': category,
        'rating': rating,
        'reviewCount': reviewCount,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };
}
