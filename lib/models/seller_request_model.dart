class SellerRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String? userPhone;
  final String status; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? reviewedAt;
  final String? reviewedBy; // admin id

  const SellerRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    this.userPhone,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
  });

  /// Create SellerRequestModel from Firestore document
  factory SellerRequestModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return SellerRequestModel(
      id: docId,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      userPhone: data['userPhone'],
      status: data['status'] ?? 'pending',
      rejectionReason: data['rejectionReason'],
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      reviewedAt: (data['reviewedAt'] as dynamic)?.toDate(),
      reviewedBy: data['reviewedBy'],
    );
  }

  /// Convert SellerRequestModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
      'reviewedAt': reviewedAt,
      'reviewedBy': reviewedBy,
    };
  }

  /// Create a copy with modified fields
  SellerRequestModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? userPhone,
    String? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? reviewedAt,
    String? reviewedBy,
  }) {
    return SellerRequestModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }
}
