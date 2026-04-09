import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'email': email,
        'name': name,
        'phone': phone ?? '',
        'role': role,
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': role == 'customer', // Customers are active immediately, sellers need approval
        'isEmailVerified': false,
        
        // Seller-specific fields
        'sellerStatus': role == 'seller' ? 'pending' : null, // pending, approved, rejected
        'approvedAt': null,
        'approvedBy': null,
        'rejectionReason': null,
        
        // Statistics
        'totalOrders': 0,
        'totalSpent': 0,
        'rating': 0,
        'completedDeliveries': 0,
        
        // Role-specific fields (null initially)
        'staffType': null,
        'storeId': null,
        'defaultAddressId': null,
        'defaultPaymentMethodId': null,
      });

      // If user is signing up as seller, create a seller approval request
      if (role == 'seller') {
        await _createSellerApprovalRequest(userCredential.user!.uid, name, email);
      }

      // Initialize user subcollections
      await _initializeUserSubcollections(userCredential.user!.uid, role);

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

      // Get user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // User exists in Firebase Auth but not in Firestore
        // Allow login and create a basic profile
        final basicUserData = {
          'userId': userCredential.user!.uid,
          'email': email,
          'name': userCredential.user!.displayName ?? email.split('@').first,
          'phone': '',
          'role': 'customer',
          'isActive': true,
          'staffType': null,
          'storeId': null,
        };
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          ...basicUserData,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        return {
          'success': true,
          'message': 'Login successful!',
          'user': userCredential.user,
          'userData': basicUserData,
        };
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // Check if user is active — treat null/missing as active
      if (userData['isActive'] == false) {
        await signOut();
        
        // Check if it's a seller with pending approval
        if (userData['role'] == 'seller' && userData['sellerStatus'] == 'pending') {
          return {
            'success': false,
            'message': 'Your seller application is still pending admin approval. Please wait for approval.',
          };
        } else if (userData['role'] == 'seller' && userData['sellerStatus'] == 'rejected') {
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

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
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

      await _firestore.collection('users').doc(userId).update(updates);

      // Update display name in Firebase Auth if name is provided
      if (name != null) {
        await _auth.currentUser?.updateDisplayName(name);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Address management methods
  Future<String?> addUserAddress({
    required String userId,
    required String label,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    String country = 'Uganda',
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    try {
      // If this is set as default, update other addresses to not be default
      if (isDefault) {
        await _updateDefaultAddress(userId, null);
      }

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .add({
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2 ?? '',
        'city': city,
        'state': state,
        'postalCode': postalCode,
        'country': country,
        'latitude': latitude,
        'longitude': longitude,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's defaultAddressId if this is the default address
      if (isDefault) {
        await _firestore.collection('users').doc(userId).update({
          'defaultAddressId': docRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _updateDefaultAddress(String userId, String? newDefaultId) async {
    try {
      // Get all addresses and update them
      QuerySnapshot addresses = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .get();

      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in addresses.docs) {
        batch.update(doc.reference, {
          'isDefault': doc.id == newDefaultId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Payment method management methods
  Future<String?> addUserPaymentMethod({
    required String userId,
    required String type,
    required String provider,
    required String accountNumber,
    required String accountName,
    bool isDefault = false,
  }) async {
    try {
      // If this is set as default, update other payment methods to not be default
      if (isDefault) {
        await _updateDefaultPaymentMethod(userId, null);
      }

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .add({
        'type': type,
        'provider': provider,
        'accountNumber': accountNumber,
        'accountName': accountName,
        'isDefault': isDefault,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update user's defaultPaymentMethodId if this is the default payment method
      if (isDefault) {
        await _firestore.collection('users').doc(userId).update({
          'defaultPaymentMethodId': docRef.id,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return docRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<bool> _updateDefaultPaymentMethod(String userId, String? newDefaultId) async {
    try {
      // Get all payment methods and update them
      QuerySnapshot paymentMethods = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .get();

      WriteBatch batch = _firestore.batch();

      for (QueryDocumentSnapshot doc in paymentMethods.docs) {
        batch.update(doc.reference, {
          'isDefault': doc.id == newDefaultId,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get user addresses
  Future<List<Map<String, dynamic>>> getUserAddresses(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('addresses')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['addressId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Get user payment methods
  Future<List<Map<String, dynamic>>> getUserPaymentMethods(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('paymentMethods')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['paymentMethodId'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // Helper method to create seller approval request
  Future<void> _createSellerApprovalRequest(String userId, String name, String email) async {
    try {
      await _firestore.collection('seller_approval_requests').add({
        'userId': userId,
        'name': name,
        'email': email,
        'status': 'pending', // pending, approved, rejected
        'requestedAt': FieldValue.serverTimestamp(),
        'processedAt': null,
        'processedBy': null,
        'adminNotes': '',
        'businessName': '',
        'businessDescription': '',
        'businessCategory': '',
        'businessPhone': '',
        'businessAddress': '',
        'documents': [], // Array of document URLs
      });
    } catch (e) {
      print('Error creating seller approval request: $e');
    }
  }

  // Helper method to initialize user subcollections
  Future<void> _initializeUserSubcollections(String userId, String role) async {
    try {
      // Initialize payment methods subcollection with default mobile money for customers
      if (role == 'customer') {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('paymentMethods')
            .add({
          'type': 'mobile_money',
          'provider': 'MTN',
          'accountNumber': '',
          'accountName': '',
          'isDefault': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Initialize empty wishlist and cart subcollections (these will be populated as needed)
      // We don't need to add documents here as they'll be created when items are added
      
    } catch (e) {
      // Log error but don't fail the signup process
      print('Error initializing user subcollections: $e');
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
