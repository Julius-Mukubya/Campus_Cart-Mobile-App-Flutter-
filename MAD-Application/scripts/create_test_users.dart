import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

/// Script to create test users with different roles
/// Run with: dart run scripts/create_test_users.dart
Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  print('Creating test users...\n');

  // Test users to create
  final testUsers = [
    {
      'email': 'customer@campuscart.com',
      'password': 'customer123',
      'name': 'Sarah Customer',
      'role': 'customer',
      'phone': '+256 700 111 111',
    },
    {
      'email': 'seller@campuscart.com',
      'password': 'seller123',
      'name': 'John Seller',
      'role': 'seller',
      'phone': '+256 700 222 222',
    },
    {
      'email': 'pickup@campuscart.com',
      'password': 'pickup123',
      'name': 'Tom Pickup',
      'role': 'staff',
      'staffType': 'pickup_delivery',
      'phone': '+256 700 333 333',
    },
    {
      'email': 'delivery@campuscart.com',
      'password': 'delivery123',
      'name': 'Mike Delivery',
      'role': 'staff',
      'staffType': 'final_delivery',
      'phone': '+256 700 444 444',
    },
    {
      'email': 'support@campuscart.com',
      'password': 'support123',
      'name': 'Jane Support',
      'role': 'staff',
      'staffType': 'support',
      'phone': '+256 700 555 555',
    },
    {
      'email': 'coordinator@campuscart.com',
      'password': 'coordinator123',
      'name': 'Alex Coordinator',
      'role': 'staff',
      'staffType': 'coordinator',
      'phone': '+256 700 666 666',
    },
    {
      'email': 'admin@campuscart.com',
      'password': 'admin123',
      'name': 'Admin User',
      'role': 'admin',
      'phone': '+256 700 777 777',
    },
  ];

  for (var userData in testUsers) {
    try {
      // Create user in Firebase Auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: userData['email'] as String,
        password: userData['password'] as String,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(userData['name'] as String);

      // Create user document in Firestore
      await firestore.collection('users').doc(userCredential.user!.uid).set({
        'userId': userCredential.user!.uid,
        'email': userData['email'],
        'name': userData['name'],
        'phone': userData['phone'],
        'role': userData['role'],
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'isEmailVerified': false,
        
        // Statistics
        'totalOrders': 0,
        'totalSpent': 0,
        'rating': 0,
        'completedDeliveries': 0,
        
        // Role-specific fields
        'staffType': userData['staffType'], // null for non-staff
        'storeId': null,
        'defaultAddressId': null,
        'defaultPaymentMethodId': null,
      });

      print('✓ Created: ${userData['email']} (${userData['role']})');
    } catch (e) {
      if (e.toString().contains('email-already-in-use')) {
        print('⚠ Skipped: ${userData['email']} (already exists)');
      } else {
        print('✗ Failed: ${userData['email']} - $e');
      }
    }
  }

  print('\n✓ Test users creation complete!');
  print('\nYou can now log in with:');
  print('- customer@campuscart.com / customer123');
  print('- seller@campuscart.com / seller123');
  print('- pickup@campuscart.com / pickup123 (Pickup Delivery)');
  print('- delivery@campuscart.com / delivery123 (Final Delivery)');
  print('- support@campuscart.com / support123');
  print('- coordinator@campuscart.com / coordinator123 (Order Manager)');
  print('- admin@campuscart.com / admin123');
}
