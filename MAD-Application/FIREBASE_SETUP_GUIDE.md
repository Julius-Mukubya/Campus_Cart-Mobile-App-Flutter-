# Firebase Setup Guide for Campus Cart

This guide provides step-by-step instructions to set up Firebase for your Campus Cart application.

---

## Part 1: Firebase Project Setup

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `campus-cart` (or your preferred name)
4. Enable/disable Google Analytics (recommended: enable)
5. Select or create a Google Analytics account
6. Click "Create project"
7. Wait for project creation to complete

### Step 2: Register Your Flutter App

1. In Firebase Console, click the Flutter icon (or "Add app")
2. Select your platform (Android/iOS/Web)
3. Follow the platform-specific setup:

#### For Android:
- Enter Android package name (e.g., `com.campuscart.app`)
- Enter app nickname (optional): `Campus Cart`
- Enter SHA-1 certificate (optional, but recommended for authentication)
- Download `google-services.json`
- Place it in `android/app/` directory

#### For iOS:
- Enter iOS bundle ID (e.g., `com.campuscart.app`)
- Enter app nickname (optional): `Campus Cart`
- Download `GoogleService-Info.plist`
- Place it in `ios/Runner/` directory

#### For Web:
- Enter app nickname: `Campus Cart`
- Copy the Firebase configuration object

### Step 3: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Step 4: Configure Firebase for Flutter

```bash
# Navigate to your project directory
cd path/to/your/campus-cart-project

# Configure Firebase
flutterfire configure

# Select your Firebase project
# Select platforms (Android, iOS, Web)
# This will generate lib/firebase_options.dart
```

---

## Part 2: Install Firebase Dependencies

### Step 1: Update pubspec.yaml

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core (required)
  firebase_core: ^2.24.2
  
  # Firebase Authentication
  firebase_auth: ^4.15.3
  
  # Cloud Firestore
  cloud_firestore: ^4.13.6
  
  # Firebase Storage (for images)
  firebase_storage: ^11.5.6
  
  # Firebase Cloud Messaging (for notifications)
  firebase_messaging: ^14.7.9
  
  # Firebase Analytics (optional)
  firebase_analytics: ^10.7.4
  
  # Firebase Performance (optional)
  firebase_performance: ^0.9.3+6
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

---

## Part 3: Initialize Firebase in Your App

### Step 1: Update main.dart

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Cart',
      // ... rest of your app configuration
    );
  }
}
```

---

## Part 4: Enable Firebase Services

### Step 1: Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable sign-in methods:
   - **Email/Password**: Click "Enable" → Save
   - **Google** (optional): Click "Enable" → Configure → Save
   - **Phone** (optional): Click "Enable" → Configure → Save

### Step 2: Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Select location (choose closest to your users, e.g., `us-central` or `europe-west`)
4. Start in **Test mode** (for development)
   - Note: Change to production mode before launching
5. Click "Enable"

### Step 3: Enable Firebase Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Start in **Test mode** (for development)
4. Select location (same as Firestore)
5. Click "Done"

### Step 4: Enable Cloud Messaging (Optional)

1. In Firebase Console, go to "Cloud Messaging"
2. Click "Get started"
3. Follow platform-specific setup for push notifications

---

## Part 5: Create Firestore Collections

### Option A: Manual Creation (Recommended for Learning)

1. Go to Firebase Console → Firestore Database
2. Click "Start collection"
3. Create each collection manually:

#### Create Users Collection:
```
Collection ID: users
Document ID: [Auto-ID]
Fields:
  - email (string): "test@example.com"
  - name (string): "Test User"
  - role (string): "customer"
  - createdAt (timestamp): [Current timestamp]
  - isActive (boolean): true
```

#### Create Categories Collection:
```
Collection ID: categories
Document ID: [Auto-ID]
Fields:
  - name (string): "Electronics"
  - description (string): "Electronic devices and accessories"
  - icon (string): "devices"
  - isActive (boolean): true
  - order (number): 1
  - productCount (number): 0
  - createdAt (timestamp): [Current timestamp]
```

Repeat for other collections as needed.

### Option B: Automated Creation (Using Script)

Create a file `scripts/initialize_firestore.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final firestore = FirebaseFirestore.instance;

  print('Initializing Firestore collections...');

  // Create Categories
  await createCategories(firestore);
  
  // Create System Settings
  await createSystemSettings(firestore);
  
  // Create FAQ Articles
  await createFAQArticles(firestore);

  print('Firestore initialization complete!');
}

Future<void> createCategories(FirebaseFirestore firestore) async {
  final categories = [
    {
      'name': 'Electronics',
      'description': 'Electronic devices and accessories',
      'icon': 'devices',
      'order': 1,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Fashion',
      'description': 'Clothing, shoes, and accessories',
      'icon': 'checkroom',
      'order': 2,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Books',
      'description': 'Textbooks and study materials',
      'icon': 'menu_book',
      'order': 3,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Food & Beverages',
      'description': 'Snacks, drinks, and meals',
      'icon': 'restaurant',
      'order': 4,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'name': 'Stationery',
      'description': 'Pens, notebooks, and office supplies',
      'icon': 'edit',
      'order': 5,
      'isActive': true,
      'productCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  for (var category in categories) {
    await firestore.collection('categories').add(category);
    print('Created category: ${category['name']}');
  }
}

Future<void> createSystemSettings(FirebaseFirestore firestore) async {
  // Shipping Configuration
  await firestore.collection('systemSettings').doc('shipping_config').set({
    'type': 'shipping',
    'config': {
      'freeShippingThreshold': 50000,
      'standardShippingFee': 5000,
      'expressShippingFee': 10000,
      'standardDeliveryDays': '2-5',
      'expressDeliveryDays': '1-2',
    },
    'isActive': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  // Tax Configuration
  await firestore.collection('systemSettings').doc('tax_config').set({
    'type': 'tax',
    'config': {
      'taxRate': 0.18, // 18% VAT
      'taxName': 'VAT',
    },
    'isActive': true,
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('Created system settings');
}

Future<void> createFAQArticles(FirebaseFirestore firestore) async {
  final articles = [
    {
      'title': 'How to track my order',
      'content': 'To track your order:\n\n1. Go to your Profile\n2. Tap on "My Orders"\n3. Select the order you want to track\n4. View real-time tracking information',
      'category': 'Orders',
      'icon': 'local_shipping',
      'color': '#6366F1',
      'views': 0,
      'helpfulCount': 0,
      'order': 1,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
    {
      'title': 'Return and refund policy',
      'content': 'Our return policy:\n\n• You can return items within 30 days of delivery\n• Items must be unused and in original packaging\n• Refunds are processed within 5-7 business days',
      'category': 'Returns',
      'icon': 'keyboard_return',
      'color': '#F59E0B',
      'views': 0,
      'helpfulCount': 0,
      'order': 2,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    },
  ];

  for (var article in articles) {
    await firestore.collection('faqArticles').add(article);
    print('Created FAQ article: ${article['title']}');
  }
}
```

Run the script:
```bash
dart run scripts/initialize_firestore.dart
```

---

## Part 6: Set Up Security Rules

### Step 1: Update Firestore Security Rules

1. Go to Firebase Console → Firestore Database → Rules
2. Replace the default rules with the security rules from `FIREBASE_SCHEMA.md`
3. Click "Publish"

### Step 2: Update Storage Security Rules

1. Go to Firebase Console → Storage → Rules
2. Replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User profile images
    match /users/{userId}/profile/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Product images
    match /products/{productId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Store images
    match /stores/{storeId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Support ticket attachments
    match /support/{ticketId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

3. Click "Publish"

---

## Part 7: Create Composite Indexes

### Step 1: Create Indexes Manually

1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Create indexes as specified in `FIREBASE_SCHEMA.md`

Example for Products:
```
Collection: products
Fields:
  - category (Ascending)
  - createdAt (Descending)
Query scope: Collection
```

### Step 2: Auto-Create Indexes (Recommended)

Indexes will be automatically suggested when you run queries that need them. Firebase will show an error with a link to create the required index.

---

## Part 8: Set Up Cloud Functions (Optional)

### Step 1: Initialize Cloud Functions

```bash
# In your project directory
firebase init functions

# Select JavaScript or TypeScript
# Install dependencies
```

### Step 2: Create Basic Functions

Edit `functions/index.js`:

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// Send notification when order is created
exports.onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const userId = order.customerId;
    
    // Create notification
    await admin.firestore().collection('notifications').add({
      userId: userId,
      type: 'order',
      title: 'Order Confirmed',
      message: `Your order #${order.orderNumber} has been confirmed!`,
      icon: 'check_circle',
      color: '#10B981',
      data: {
        orderId: context.params.orderId,
      },
      isRead: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    console.log('Notification created for order:', context.params.orderId);
  });

// Update product rating when review is created
exports.onReviewCreated = functions.firestore
  .document('products/{productId}/reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const productId = context.params.productId;
    
    // Get all reviews for this product
    const reviewsSnapshot = await admin.firestore()
      .collection('products')
      .doc(productId)
      .collection('reviews')
      .get();
    
    // Calculate average rating
    let totalRating = 0;
    reviewsSnapshot.forEach(doc => {
      totalRating += doc.data().rating;
    });
    const averageRating = totalRating / reviewsSnapshot.size;
    
    // Update product
    await admin.firestore().collection('products').doc(productId).update({
      rating: averageRating,
      totalReviews: reviewsSnapshot.size,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    console.log('Updated product rating:', productId);
  });
```

### Step 3: Deploy Functions

```bash
firebase deploy --only functions
```

---

## Part 9: Test Your Setup

### Step 1: Create Test Data

Create a test script `scripts/create_test_data.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../lib/firebase_options.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  // Create test user
  UserCredential userCredential = await auth.createUserWithEmailAndPassword(
    email: 'test@campuscart.com',
    password: 'Test123!',
  );

  // Create user document
  await firestore.collection('users').doc(userCredential.user!.uid).set({
    'userId': userCredential.user!.uid,
    'email': 'test@campuscart.com',
    'name': 'Test User',
    'role': 'customer',
    'isActive': true,
    'isEmailVerified': false,
    'totalOrders': 0,
    'totalSpent': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('Test user created: ${userCredential.user!.uid}');
  
  // Create test product
  await firestore.collection('products').add({
    'name': 'Test Product',
    'description': 'This is a test product',
    'category': 'Electronics',
    'price': 50000,
    'stock': 10,
    'images': [],
    'isActive': true,
    'isFeatured': false,
    'rating': 0,
    'totalReviews': 0,
    'totalSales': 0,
    'views': 0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  });

  print('Test product created');
}
```

### Step 2: Run Tests

```bash
dart run scripts/create_test_data.dart
```

### Step 3: Verify in Firebase Console

1. Go to Firebase Console → Firestore Database
2. Check that collections are created
3. Verify data structure matches schema

---

## Part 10: Production Checklist

Before going to production:

- [ ] Change Firestore rules from test mode to production mode
- [ ] Change Storage rules from test mode to production mode
- [ ] Set up proper authentication (email verification, password reset)
- [ ] Create all necessary composite indexes
- [ ] Set up Firebase App Check for security
- [ ] Enable Firebase Performance Monitoring
- [ ] Set up Firebase Crashlytics
- [ ] Configure Firebase Cloud Messaging for push notifications
- [ ] Set up backup strategy for Firestore
- [ ] Configure billing alerts
- [ ] Test all CRUD operations
- [ ] Test security rules thoroughly
- [ ] Set up monitoring and alerts
- [ ] Document API keys and configuration
- [ ] Set up staging and production environments

---

## Troubleshooting

### Common Issues:

1. **"Firebase not initialized" error**
   - Ensure `Firebase.initializeApp()` is called before any Firebase operations
   - Check that `firebase_options.dart` exists

2. **"Permission denied" errors**
   - Check Firestore security rules
   - Verify user is authenticated
   - Check that user has correct role

3. **"Index required" errors**
   - Click the link in the error message to create the index
   - Or create manually in Firebase Console

4. **Build errors after adding Firebase**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Rebuild the app

5. **Android build issues**
   - Check `google-services.json` is in `android/app/`
   - Verify `minSdkVersion` is at least 21 in `android/app/build.gradle`

---

## Next Steps

1. **Implement Authentication**: Create sign-in/sign-up screens
2. **Create Services**: Build Firestore service classes for each collection
3. **Implement CRUD Operations**: Add, read, update, delete data
4. **Add Real-time Listeners**: Listen to Firestore changes
5. **Implement Offline Support**: Enable Firestore persistence
6. **Add Image Upload**: Implement Firebase Storage integration
7. **Set Up Push Notifications**: Configure FCM
8. **Add Analytics**: Track user behavior
9. **Implement Search**: Use Algolia or similar for full-text search
10. **Optimize Performance**: Add caching, pagination, lazy loading

---

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/data-model)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Cloud Functions Documentation](https://firebase.google.com/docs/functions)

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Author:** Campus Cart Development Team
