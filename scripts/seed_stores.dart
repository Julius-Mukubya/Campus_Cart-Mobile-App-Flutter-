import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../lib/firebase_options.dart';

/// Standalone script to seed a seller store with sample products.
/// Looks up user by email, creates a store, assigns seller role, and seeds products.
/// Run: flutter run -t scripts/seed_stores.dart --dart-define=password=YOUR_PASSWORD
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('🌱 Seeding store and products...\n');

  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  // ── 0. Sign in to authenticate Firestore operations ────────────────────
  final userEmail = 'julius082115@gmail.com';
  final password = const String.fromEnvironment('password');

  if (password.isEmpty) {
    print('❌ No password provided.');
    print('');
    print('Usage: flutter run -t scripts/seed_stores.dart --dart-define=password=YOUR_PASSWORD');
    print('');
    print('Replace YOUR_PASSWORD with the password for $userEmail');
    return;
  }

  try {
    await auth.signInWithEmailAndPassword(
      email: userEmail,
      password: password,
    );
    print('✅ Signed in successfully as $userEmail');
  } on FirebaseAuthException catch (e) {
    print('❌ Authentication failed: ${e.message}');
    print('   Make sure the user exists in Firebase Auth and the password is correct.');
    return;
  }

  print('🔍 Looking up user: $userEmail');

  final userQuery = await firestore
      .collection('users')
      .where('email', isEqualTo: userEmail)
      .limit(1)
      .get();

  if (userQuery.docs.isEmpty) {
    print('❌ User with email "$userEmail" not found in Firestore.');
    print('   Make sure the user has signed up at least once.');
    return;
  }

  final userDoc = userQuery.docs.first;
  final userId = userDoc.id;
  final userName = userDoc.data()['name'] as String? ?? 'Julius';
  print('✅ Found user: $userName ($userId)');

  // ── 2. Fetch existing categories ───────────────────────────────────────
  final categoriesSnapshot = await firestore.collection('categories').get();
  if (categoriesSnapshot.docs.isEmpty) {
    print('❌ No categories found. Run scripts/seed_categories.dart first.');
    return;
  }

  final categories = categoriesSnapshot.docs.map((doc) {
    final data = doc.data();
    data['id'] = doc.id;
    return data;
  }).toList();

  print('✅ Found ${categories.length} categories');

  // ── 3. Check if user already has a store ───────────────────────────────
  final existingStoreId = userDoc.data()['storeId'] as String?;
  final storeName = '$userName\'s Campus Store';
  String storeId;

  if (existingStoreId != null && existingStoreId.isNotEmpty) {
    storeId = existingStoreId;
    print('📦 User already has store: $storeId');
  } else {
    // Create a new store
    final storeData = {
      'sellerId': userId,
      'storeName': '$userName\'s Campus Store',
      'description': 'Quality products for campus life. Electronics, fashion, books, and more — all at student-friendly prices.',
      'logo': '',
      'banner': '',
      'email': userEmail,
      'phone': userDoc.data()['phone'] as String? ?? '+256 700 000 000',
      'address': {
        'addressLine1': 'Makerere University',
        'addressLine2': 'Kampala',
        'city': 'Kampala',
        'state': 'Central',
        'postalCode': '',
      },
      'status': 'approved',
      'rating': 4.5,
      'totalReviews': 0,
      'totalProducts': 0,
      'totalSales': 0,
      'totalRevenue': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final storeRef = await firestore.collection('stores').add(storeData);
    storeId = storeRef.id;
    print('🏪 Created new store: $storeName ($storeId)');
  }

  // ── 4. Update user role to seller if not already ───────────────────────
  final currentRole = userDoc.data()['role'] as String? ?? 'customer';
  if (currentRole != 'seller') {
    await firestore.collection('users').doc(userId).update({
      'role': 'seller',
      'storeId': storeId,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    print('✅ Updated user role: customer → seller');
  } else {
    print('✅ User already has seller role');
  }

  // Also ensure storeId is set on user doc
  await firestore.collection('users').doc(userId).update({
    'storeId': storeId,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // ── 5. Seed sample products ────────────────────────────────────────────
  final categoryMap = <String, Map<String, dynamic>>{};
  for (final cat in categories) {
    categoryMap[cat['name'] as String] = cat;
  }

  final sampleProducts = [
    // ── Electronics ──
    {
      'name': 'Wireless Bluetooth Headphones',
      'description': 'Premium wireless headphones with active noise cancellation, 30-hour battery life, and superior sound quality. Perfect for studying and music.',
      'price': 85000,
      'discount': 15,
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
      'images': [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400&h=400&fit=crop',
      ],
      'category': 'Electronics',
      'stock': 25,
      'rating': 4.8,
      'isFeatured': true,
    },
    {
      'name': 'USB-C Fast Charger 65W',
      'description': 'GaN USB-C fast charger compatible with laptops, tablets, and phones. Compact design with 3 ports.',
      'price': 45000,
      'discount': 10,
      'image': 'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1583863788434-e58a36330cf0?w=400&h=400&fit=crop'],
      'category': 'Electronics',
      'stock': 50,
      'rating': 4.6,
      'isFeatured': true,
    },
    {
      'name': 'Portable Bluetooth Speaker',
      'description': 'Waterproof portable speaker with deep bass, 12-hour playtime, and built-in microphone for calls.',
      'price': 35000,
      'discount': 0,
      'image': 'https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1608043152269-423dbba4e7e1?w=400&h=400&fit=crop'],
      'category': 'Electronics',
      'stock': 30,
      'rating': 4.5,
      'isFeatured': false,
    },

    // ── Fashion ──
    {
      'name': 'Campus Hoodie - Classic Black',
      'description': 'Comfortable cotton-blend hoodie with campus-inspired design. Perfect for casual wear and chilly lecture halls.',
      'price': 55000,
      'discount': 20,
      'image': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=400&h=400&fit=crop'],
      'category': 'Fashion',
      'stock': 40,
      'rating': 4.7,
      'isFeatured': true,
    },
    {
      'name': 'Casual Backpack - Grey',
      'description': 'Durable laptop backpack with padded compartments, USB charging port, and water-resistant material.',
      'price': 65000,
      'discount': 0,
      'image': 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=400&h=400&fit=crop'],
      'category': 'Fashion',
      'stock': 20,
      'rating': 4.8,
      'isFeatured': true,
    },

    // ── Books ──
    {
      'name': 'Introduction to Computer Science',
      'description': 'Comprehensive textbook covering fundamentals of computer science, algorithms, data structures, and programming principles.',
      'price': 75000,
      'discount': 5,
      'image': 'https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1532012197267-da84d127e765?w=400&h=400&fit=crop'],
      'category': 'Books',
      'stock': 15,
      'rating': 4.5,
      'isFeatured': false,
    },
    {
      'name': 'Business Management Notes Bundle',
      'description': 'Curated bundle of lecture notes, case studies, and practice exams for business management students.',
      'price': 25000,
      'discount': 0,
      'image': 'https://images.unsplash.com/photo-1452860606245-08a5d8e7a3a1?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1452860606245-08a5d8e7a3a1?w=400&h=400&fit=crop'],
      'category': 'Books',
      'stock': 100,
      'rating': 4.3,
      'isFeatured': false,
    },

    // ── Stationery ──
    {
      'name': 'Premium Notebook Set (5 Pack)',
      'description': 'Set of 5 A5 ruled notebooks with durable covers, 200 pages each. Ideal for lecture notes and study journals.',
      'price': 18000,
      'discount': 10,
      'image': 'https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1531346878377-a5be20888e57?w=400&h=400&fit=crop'],
      'category': 'Stationery',
      'stock': 60,
      'rating': 4.6,
      'isFeatured': true,
    },
    {
      'name': 'Graphing Calculator - Scientific',
      'description': 'Advanced scientific calculator with color display, graphing capabilities, and programmable functions.',
      'price': 95000,
      'discount': 0,
      'image': 'https://images.unsplash.com/photo-1587145820266-a5951ee6f620?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1587145820266-a5951ee6f620?w=400&h=400&fit=crop'],
      'category': 'Stationery',
      'stock': 10,
      'rating': 4.9,
      'isFeatured': false,
    },

    // ── Food & Beverages ──
    {
      'name': 'Mixed Nut Snack Pack (1kg)',
      'description': 'Assorted healthy nuts and dried fruits mix. Perfect for studying snacks between classes.',
      'price': 15000,
      'discount': 0,
      'image': 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400&h=400&fit=crop'],
      'category': 'Food & Beverages',
      'stock': 80,
      'rating': 4.4,
      'isFeatured': false,
    },

    // ── Sports ──
    {
      'name': 'Resistance Bands Set - 5 Levels',
      'description': 'Set of 5 resistance bands with different tension levels. Great for home workouts and staying fit on campus.',
      'price': 22000,
      'discount': 15,
      'image': 'https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop',
      'images': ['https://images.unsplash.com/photo-1598289431512-b97b0917affc?w=400&h=400&fit=crop'],
      'category': 'Sports',
      'stock': 35,
      'rating': 4.5,
      'isFeatured': false,
    },
  ];

  print('\n📦 Seeding ${sampleProducts.length} products...');
  int seededCount = 0;

  for (final product in sampleProducts) {
    final categoryName = product['category'] as String;
    final category = categoryMap[categoryName];

    if (category == null) {
      print('  ⚠️  Category "$categoryName" not found, skipping product "${product['name']}"');
      continue;
    }

    final categoryId = category['id'] as String;

    final productData = {
      'name': product['name'],
      'description': product['description'],
      'price': (product['price'] as num).toDouble(),
      'discountPrice': product['discount'] != null && (product['discount'] as int) > 0
          ? ((product['price'] as int) * (1 - (product['discount'] as int) / 100)).toDouble()
          : null,
      'image': product['image'],
      'images': product['images'],
      'categoryId': categoryId,
      'categoryName': categoryName,
      'sellerId': userId,
      'sellerName': userName,
      'storeId': storeId,
      'storeName': storeName,
      'rating': (product['rating'] as num).toDouble(),
      'reviewCount': 0,
      'stock': product['stock'] as int,
      'isFeatured': product['isFeatured'] as bool,
      'isActive': true,
      'tags': [categoryName.toLowerCase()],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await firestore.collection('products').add(productData);
    seededCount++;
    print('  ✅ Added: ${product['name']}');
  }

  // ── 6. Update store product count ──────────────────────────────────────
  await firestore.collection('stores').doc(storeId).update({
    'totalProducts': seededCount,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // ── 7. Update category product counts ──────────────────────────────────
  final categoryCounts = <String, int>{};
  for (final product in sampleProducts) {
    final catName = product['category'] as String;
    categoryCounts[catName] = (categoryCounts[catName] ?? 0) + 1;
  }

  for (final entry in categoryCounts.entries) {
    final cat = categoryMap[entry.key];
    if (cat != null) {
      final catId = cat['id'] as String;
      await firestore.collection('categories').doc(catId).update({
        'productCount': FieldValue.increment(entry.value),
      });
    }
  }

  print('\n' + '=' * 50);
  print('🎉 STORE SEEDING COMPLETE!');
  print('=' * 50);
  print('🏪 Store: $storeName');
  print('📎 Store ID: $storeId');
  print('👤 Seller: $userName ($userId)');
  print('📦 Products seeded: $seededCount');
  print('');
  print('👉 Login as $userEmail to see the store in action.');
  print('👉 Browse categories to find products from your store.');
  print('');
}