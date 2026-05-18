import 'cart_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String status; // 'pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'
  final String paymentMethod; // 'card', 'mobile_money', 'cash_on_delivery'
  final bool paymentStatus; // true if paid
  final String deliveryAddress;
  final String? phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.paymentStatus = false,
    required this.deliveryAddress,
    this.phone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  /// Check if order can be cancelled
  bool get canBeCancelled => !['delivered', 'cancelled'].contains(status);

  /// Check if order is complete
  bool get isCompleted => status == 'delivered';

  /// Create OrderModel from Firestore document
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return OrderModel(
      id: docId,
      userId: data['userId'] ?? '',
      items: (data['items'] as List?)?.map((item) => CartItemModel.fromMap(item as Map<String, dynamic>)).toList() ?? [],
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (data['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'cash_on_delivery',
      paymentStatus: data['paymentStatus'] ?? false,
      deliveryAddress: data['deliveryAddress'] ?? '',
      phone: data['phone'],
      notes: data['notes'],
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      deliveredAt: (data['deliveredAt'] as dynamic)?.toDate(),
    );
  }

  /// Convert OrderModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'deliveryAddress': deliveryAddress,
      'phone': phone,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'deliveredAt': deliveredAt,
    };
  }

  /// Create a copy with modified fields
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? status,
    String? paymentMethod,
    bool? paymentStatus,
    String? deliveryAddress,
    String? phone,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  @override
  String toString() => 'OrderModel(id: $id, userId: $userId, total: $total, status: $status)';
}
