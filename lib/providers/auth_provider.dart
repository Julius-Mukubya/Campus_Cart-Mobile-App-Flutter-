import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../router.dart';
import '../utils/app_logger.dart';

/// Authentication state model
class AuthState {
  final bool isLoading;
  final String? error;
  final bool isLoggedIn;
  final String? userId;
  final String? email;
  final String? userRole;
  final Map<String, dynamic>? userData;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.isLoggedIn = false,
    this.userId,
    this.email,
    this.userRole,
    this.userData,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isLoggedIn,
    String? userId,
    String? email,
    String? userRole,
    Map<String, dynamic>? userData,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userRole: userRole ?? this.userRole,
      userData: userData ?? this.userData,
    );
  }
}

/// Auth notifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthState());

  /// Persist user data and update router auth state
  Future<void> _handleAuthSuccess({
    required String userId,
    required String email,
    required Map<String, dynamic> userData,
  }) async {
    final role = userData['role'] as String? ?? 'customer';

    // Persist session to SharedPreferences
    await PreferencesService.saveUser(
      userId: userId,
      name: userData['name'] ?? 'User',
      email: userData['email'] ?? email,
      phone: userData['phone'] ?? '',
      role: role,
      storeId: userData['storeId'],
      profileImage: userData['profileImage'] ?? '',
    );

    // Update state
    state = state.copyWith(
      isLoading: false,
      isLoggedIn: true,
      userId: userId,
      email: email,
      userRole: role,
      userData: userData,
    );

    // Update router auth state for redirect guard
    routerAuthNotifier.update(RouterUserState(
      isLoggedIn: true,
      role: role,
    ));
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.signIn(email: email, password: password);

      if (result['success'] == true) {
        final userData = result['userData'] as Map<String, dynamic>;
        await _handleAuthSuccess(
          userId: result['user'].uid,
          email: email,
          userData: userData,
        );
        AppLogger.info('Sign in successful: $email');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Sign in failed',
        );
      }
    } catch (e) {
      AppLogger.error('Sign in error', error: e);
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
    }
  }

  /// Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );

      if (result['success'] == true) {
        if (role == 'seller') {
          // Seller signs up but doesn't log in yet — needs approval
          state = state.copyWith(
            isLoading: false,
            error: 'Account created. Your seller application is pending approval.',
          );
        } else {
          // Customer — auto-login
          // Fetch the user data we just created (signUp doesn't return it)
          final userData = await _authService.getUserData(result['user'].uid);
          await _handleAuthSuccess(
            userId: result['user'].uid,
            email: email,
            userData: userData ?? {'role': 'customer', 'name': name, 'email': email, 'phone': phone ?? ''},
          );
        }
        AppLogger.info('Sign up successful: $email');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Sign up failed',
        );
      }
    } catch (e) {
      AppLogger.error('Sign up error', error: e);
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.signInWithGoogle();

      if (result['success'] == true) {
        final userData = result['userData'] as Map<String, dynamic>;
        await _handleAuthSuccess(
          userId: result['user'].uid,
          email: userData['email'] ?? '',
          userData: userData,
        );
        AppLogger.info('Google sign in successful');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Google sign in failed',
        );
      }
    } catch (e) {
      AppLogger.error('Google sign in error', error: e);
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.signOut();
      await PreferencesService.clearUser();
      state = const AuthState();
      routerAuthNotifier.update(const RouterUserState());
      AppLogger.info('Sign out successful');
    } catch (e) {
      AppLogger.error('Sign out error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to sign out: $e',
      );
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.resetPassword(email: email);

      if (result['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String,
        );
        AppLogger.info('Password reset email sent');
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result['message'] as String? ?? 'Failed to reset password',
        );
      }
    } catch (e) {
      AppLogger.error('Reset password error', error: e);
      state = state.copyWith(isLoading: false, error: 'An error occurred: $e');
    }
  }

  /// Check if user is authenticated
  Future<bool> checkAuthStatus() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _authService.getUserData(user.uid);
        state = state.copyWith(
          isLoggedIn: true,
          userId: user.uid,
          email: user.email,
          userRole: userData?['role'] ?? 'customer',
          userData: userData,
        );
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.error('Auth check error', error: e);
      return false;
    }
  }
}

/// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);