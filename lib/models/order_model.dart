import 'cart_item_model.dart';

/// Simplified OrderModel matching the actual order lifecycle.
/// Statuses: pending → accepted/rejected/cancelled → completed
/// No delivery, no payment, no address — just ordering + chat + reviews.
class OrderModel {
  final String id;
  final String userId;
  final String customerName;
  final String? customerPhone;
  final String sellerId;
  final String? sellerName;
  final List<CartItemModel> items;
  final double total;
  final String status; // 'pending', 'accepted', 'rejected', 'cancelled', 'completed'
  final bool showContactToSeller;
  final bool sellerConfirmed;
  final bool customerConfirmed;
  final String? rejectionReason;
  final bool followUp;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    this.customerPhone,
    required this.sellerId,
    this.sellerName,
    required this.items,
    required this.total,
    required this.status,
    this.showContactToSeller = true,
    this.sellerConfirmed = false,
    this.customerConfirmed = false,
    this.rejectionReason,
    this.followUp = false,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  /// Check if order can be cancelled (only pending)
  bool get canBeCancelled => status == 'pending';

  /// Check if order is complete
  bool get isCompleted => status == 'completed';

  /// Create OrderModel from Firestore document
  factory OrderModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return OrderModel(
      id: docId,
      userId: data['customerId'] ?? data['userId'] ?? '',
      customerName: data['customerName'] ?? 'Customer',
      customerPhone: data['customerPhone'] as String?,
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] as String?,
      items: (data['items'] as List?)
              ?.map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'pending',
      showContactToSeller: data['showContactToSeller'] ?? true,
      sellerConfirmed: data['sellerConfirmed'] ?? false,
      customerConfirmed: data['customerConfirmed'] ?? false,
      rejectionReason: data['rejectionReason'] as String?,
      followUp: data['followUp'] ?? false,
      notes: data['notes'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
      completedAt: (data['completedAt'] as dynamic)?.toDate(),
    );
  }

  /// Convert OrderModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'customerId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'showContactToSeller': showContactToSeller,
      'sellerConfirmed': sellerConfirmed,
      'customerConfirmed': customerConfirmed,
      'rejectionReason': rejectionReason,
      'followUp': followUp,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
      'completedAt': completedAt,
    };
  }

  /// Create a copy with modified fields
  OrderModel copyWith({
    String? id,
    String? userId,
    String? customerName,
    String? customerPhone,
    String? sellerId,
    String? sellerName,
    List<CartItemModel>? items,
    double? total,
    String? status,
    bool? showContactToSeller,
    bool? sellerConfirmed,
    bool? customerConfirmed,
    String? rejectionReason,
    bool? followUp,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      showContactToSeller: showContactToSeller ?? this.showContactToSeller,
      sellerConfirmed: sellerConfirmed ?? this.sellerConfirmed,
      customerConfirmed: customerConfirmed ?? this.customerConfirmed,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      followUp: followUp ?? this.followUp,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() =>
      'OrderModel(id: $id, customer: $customerName, total: $total, status: $status)';
}