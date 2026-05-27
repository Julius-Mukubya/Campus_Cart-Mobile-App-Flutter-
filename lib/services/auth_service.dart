import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/app_logger.dart';
import '../utils/exceptions.dart';
import 'package:madpractical/repositories/user_repository.dart';

class AuthService {
  final UserRepository _userRepository;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService({
    UserRepository? userRepository,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _userRepository = userRepository ?? UserRepository(),
        _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google — call this from both sign-in and sign-up screens
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Force sign out first to always show the account picker (don't use cached account)
      await _googleSignIn.signOut();

      // Always show account picker (no silent sign-in)
      GoogleSignInAccount? googleAccount = await _googleSignIn.signIn();

      if (googleAccount == null) {
        return {
          'success': false,
          'message': 'Google sign-in was cancelled.',
        };
      }

      // Get the authentication token
      final GoogleSignInAuthentication authResult =
          await googleAccount.authentication;

      if (authResult.idToken == null) {
        return {
          'success': false,
          'message': 'Failed to get Google authentication token.',
        };
      }

      // Create Firebase credential with the Google idToken
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: authResult.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Check if this is a new user or returning user
      try {
        final userData = await _userRepository.getUser(userCredential.user!.uid);
        return {
          'success': true,
          'message': 'Signed in with Google!',
          'user': userCredential.user,
          'userData': userData,
        };
      } on RepositoryException {
        // New user — create Firestore document with default role 'customer'
      }

      final String name = googleAccount.displayName ??
          userCredential.user!.displayName ??
          googleAccount.email.split('@').first;
      final String photoUrl = googleAccount.photoUrl ?? '';

      final Map<String, dynamic> newUserData = {
        'userId': userCredential.user!.uid,
        'email': googleAccount.email,
        'name': name,
        'phone': '',
        'role': 'customer',
        'profileImage': photoUrl,
        'isActive': true,
        'isEmailVerified': userCredential.user!.emailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalOrders': 0,
        'totalSpent': 0,
        'rating': 0,
        'storeId': null,
      };

      await _userRepository.createUser(userCredential.user!.uid, newUserData);

      return {
        'success': true,
        'message': 'Account created and signed in with Google!',
        'user': userCredential.user,
        'userData': newUserData,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Google sign-in failed: ${e.toString()}',
      };
    }
  }

  // Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    String role = 'customer',
    String? phone,
  }) async {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name);

      // Create user document in Firestore via repository
      // All users start as active customers.
      // If the user selected 'seller', a seller request is created separately.
      // Admin will change role from 'customer' to 'seller' upon approval.
      await _userRepository.createUser(userCredential.user!.uid, {
        'userId': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'role': 'customer', // Always start as customer — seller granted on approval
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true, // All users are active immediately
        'isEmailVerified': false,
        
        // Seller request tracking (only set if they signed up as seller)
        'sellerStatus': role == 'seller' ? 'pending' : null,
        'approvedAt': null,
        'approvedBy': null,
        'rejectionReason': null,
        
        // Statistics
        'totalOrders': 0,
        'totalSpent': 0,
        'rating': 0,
        
        // Reference fields
        'storeId': null,
      });

      // If user is signing up as seller, create a seller approval request
      if (role == 'seller') {
        await _createSellerApprovalRequest(userCredential.user!.uid, name, email);
      }

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return {
        'success': true,
        'message': 'Account created successfully! Please verify your email.',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  // Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from repository
      Map<String, dynamic> userData;
      try {
        userData = await _userRepository.getUser(userCredential.user!.uid);
      } on RepositoryException {
        // User exists in Firebase Auth but not in Firestore
        // Allow login and create a basic profile
        userData = {
          'userId': userCredential.user!.uid,
          'email': email,
          'name': userCredential.user!.displayName ?? email.split('@').first,
          'phone': '',
          'role': 'customer',
          'isActive': true,
          'storeId': null,
        };
        await _userRepository.createUser(userCredential.user!.uid, {
          ...userData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return {
          'success': true,
          'message': 'Login successful!',
          'user': userCredential.user,
          'userData': userData,
        };
      }

      // Prevent login for deactivated accounts only
      if (userData['isActive'] == false) {
        await signOut();
        // Check for an old seller who was deactivated during migration
        if (userData['role'] == 'seller' && userData['sellerStatus'] == 'rejected') {
          return {
            'success': false,
            'message': 'Your seller application was rejected. Reason: ${userData['rejectionReason'] ?? 'No reason provided'}',
          };
        } else {
          return {
            'success': false,
            'message': 'Your account has been deactivated. Please contact support.',
          };
        }
      }

      return {
        'success': true,
        'message': 'Login successful!',
        'user': userCredential.user,
        'userData': userData,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Sign in failed: ${e.toString()}',
      };
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': _getAuthErrorMessage(e.code),
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred. Please try again.',
      };
    }
  }

  // Send email verification
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return {
          'success': true,
          'message': 'Verification email sent!',
        };
      }
      return {
        'success': false,
        'message': 'Email already verified or user not found.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send verification email.',
      };
    }
  }

  // Get user data from Firestore via repository
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      return await _userRepository.getUser(userId);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _userRepository.updateUser(userId, updates);

      // Update display name in Firebase Auth if name is provided
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper method to create seller approval request
  Future<void> _createSellerApprovalRequest(String userId, String name, String email) async {
    try {
      // Get user phone if available
      Map<String, dynamic>? userData;
      try {
        userData = await _userRepository.getUser(userId);
      } catch (_) {}
      final userPhone = userData?['phone'] as String?;

      await _firestore.collection('sellerRequests').add({
        'userId': userId,
        'userName': name,
        'userEmail': email,
        'userPhone': userPhone,
        'status': 'pending',
        'rejectionReason': null,
        'createdAt': FieldValue.serverTimestamp(),
        'reviewedAt': null,
        'reviewedBy': null,
      });
    } catch (e) {
      AppLogger.error('Error creating seller request', error: e);
    }
  }

  // Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please sign in instead.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}