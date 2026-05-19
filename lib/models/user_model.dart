class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImage;
  final String role; // 'customer', 'seller', 'admin'
  final String? storeId; // for sellers
  final bool showContactInfo; // privacy toggle for customers
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImage,
    required this.role,
    this.storeId,
    this.showContactInfo = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return UserModel(
      id: docId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'],
      profileImage: data['profileImage'],
      role: data['role'] ?? 'customer',
      storeId: data['storeId'],
      showContactInfo: data['showContactInfo'] ?? true,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  /// Convert UserModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'storeId': storeId,
      'showContactInfo': showContactInfo,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    String? storeId,
    bool? showContactInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      storeId: storeId ?? this.storeId,
      showContactInfo: showContactInfo ?? this.showContactInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'UserModel(id: $id, name: $name, email: $email, role: $role)';
}