class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int displayOrder;
  final String? type; // 'products', 'vendors', etc.
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.displayOrder,
    this.type,
    this.description,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return CategoryModel(
      id: docId,
      name: data['name'] ?? '',
      icon: data['icon'],
      displayOrder: data['displayOrder'] ?? 0,
      type: data['type'],
      description: data['description'],
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  /// Create CategoryModel from map
  factory CategoryModel.fromMap(Map<String, dynamic> data) {
    return CategoryModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      icon: data['icon'],
      displayOrder: data['displayOrder'] ?? 0,
      type: data['type'],
      description: data['description'],
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate(),
    );
  }

  /// Convert CategoryModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'displayOrder': displayOrder,
      'type': type,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  /// Convert CategoryModel to map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'displayOrder': displayOrder,
      'type': type,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create a copy with modified fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? displayOrder,
    String? type,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      displayOrder: displayOrder ?? this.displayOrder,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name, displayOrder: $displayOrder)';
}
