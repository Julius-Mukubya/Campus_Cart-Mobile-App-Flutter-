import 'package:flutter_riverpod/flutter_riverpod.dart';

/// User state model - represents user data
class UserState {
  final String? userId;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final bool isPremium;
  final String role; // 'customer', 'seller', 'admin'
  final String? storeId;
  final bool showContactInfo;

  const UserState({
    this.userId,
    this.name = 'John Doe',
    this.email = 'johndoe@example.com',
    this.phone = '+256 700 123 456',
    this.profileImage =
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop',
    this.isPremium = true,
    this.role = 'customer',
    this.storeId,
    this.showContactInfo = true,
  });

  UserState copyWith({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    bool? isPremium,
    String? role,
    String? storeId,
    bool? showContactInfo,
  }) {
    return UserState(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isPremium: isPremium ?? this.isPremium,
      role: role ?? this.role,
      storeId: (role != null && role != 'seller') ? null : storeId ?? this.storeId,
      showContactInfo: showContactInfo ?? this.showContactInfo,
    );
  }
}

/// UserNotifier - handles user state updates
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  void updateProfile({
    String? userId,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    String? storeId,
    bool? showContactInfo,
  }) {
    state = state.copyWith(
      userId: userId,
      name: name,
      email: email,
      phone: phone,
      profileImage: profileImage,
      role: role,
      storeId: storeId,
      showContactInfo: showContactInfo,
    );
  }

  void logout() {
    state = UserState(
      userId: null,
      name: 'Guest User',
      email: 'guest@example.com',
      phone: '+256 700 000 000',
      role: 'customer',
      storeId: null,
    );
  }
}

/// User provider - provides access to user state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});