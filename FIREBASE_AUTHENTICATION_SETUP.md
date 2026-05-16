# Firebase Authentication Setup Guide for Campus Cart

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Flutter Project Configuration](#flutter-project-configuration)
4. [Install Dependencies](#install-dependencies)
5. [Configure Firebase for Android](#configure-firebase-for-android)
6. [Configure Firebase for iOS](#configure-firebase-for-ios)
7. [Enable Authentication Methods](#enable-authentication-methods)
8. [Create Authentication Service](#create-authentication-service)
9. [Update Existing Screens](#update-existing-screens)
10. [Testing](#testing)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

- Flutter SDK installed (version 3.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Google account for Firebase Console
- Basic understanding of Flutter and Dart

---

## 1. Firebase Project Setup

### Step 1.1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: `campus-cart` (or your preferred name)
4. (Optional) Enable Google Analytics
5. Click "Create project"
6. Wait for project creation to complete

### Step 1.2: Register Your App

1. In Firebase Console, click on your project
2. Click the Flutter icon (or "Add app" > Flutter)
3. Follow the Firebase CLI setup instructions

---

## 2. Flutter Project Configuration

### Step 2.1: Install Firebase CLI

Open terminal and run:

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

### Step 2.2: Configure Firebase in Your Flutter Project

Navigate to your project directory and run:

```bash
# Make sure you're in the project root directory
cd /path/to/your/Campus_Cart-Mobile-App-Flutter-/MAD-Application

# Configure Firebase
flutterfire configure
```

Follow the prompts:
- Select your Firebase project (campus-cart)
- Select platforms: Android, iOS, Web (if needed)
- This will create `firebase_options.dart` file

---

## 3. Install Dependencies

### Step 3.1: Update pubspec.yaml

Add the following dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase Core (Required)
  firebase_core: ^2.24.2
  
  # Firebase Authentication
  firebase_auth: ^4.15.3
  
  # Cloud Firestore (for user data)
  cloud_firestore: ^4.13.6
  
  # Firebase Storage (for profile images)
  firebase_storage: ^11.5.6
  
  # Google Sign In (optional)
  google_sign_in: ^6.1.6
  
  # State Management (if not already added)
  provider: ^6.1.1
```

### Step 3.2: Install Packages

Run in terminal:

```bash
flutter pub get
```

---

## 4. Configure Firebase for Android

### Step 4.1: Update android/build.gradle

Open `android/build.gradle` and update:

```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Add this line
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### Step 4.2: Update android/app/build.gradle

Open `android/app/build.gradle` and add at the bottom:

```gradle
apply plugin: 'com.google.gms.google-services'
```

Also update the `minSdkVersion` in the same file:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Change from 16 to 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

### Step 4.3: Add google-services.json

The `flutterfire configure` command should have created this file at:
`android/app/google-services.json`

If not, download it from Firebase Console:
1. Go to Project Settings > Your apps > Android app
2. Download `google-services.json`
3. Place it in `android/app/` directory

---

## 5. Configure Firebase for iOS

### Step 5.1: Update ios/Podfile

Open `ios/Podfile` and ensure it has:

```ruby
platform :ios, '12.0'  # Minimum iOS version
```

### Step 5.2: Add GoogleService-Info.plist

The `flutterfire configure` command should have created this file at:
`ios/Runner/GoogleService-Info.plist`

If not, download it from Firebase Console:
1. Go to Project Settings > Your apps > iOS app
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/` directory

### Step 5.3: Install Pods

```bash
cd ios
pod install
cd ..
```

---

## 6. Enable Authentication Methods

### Step 6.1: Enable Email/Password Authentication

1. Go to Firebase Console > Authentication
2. Click "Get started" (if first time)
3. Go to "Sign-in method" tab
4. Click "Email/Password"
5. Enable "Email/Password"
6. Click "Save"

### Step 6.2: (Optional) Enable Google Sign-In

1. In "Sign-in method" tab
2. Click "Google"
3. Enable Google Sign-In
4. Select support email
5. Click "Save"

### Step 6.3: (Optional) Enable Phone Authentication

1. In "Sign-in method" tab
2. Click "Phone"
3. Enable Phone authentication
4. Click "Save"

---

## 7. Create Authentication Service

### Step 7.1: Create Firebase Service File

Create `lib/services/firebase_auth_service.dart`:

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
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
        'role': role,
        'isActive': true,
        'isEmailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'totalOrders': 0,
        'totalSpent': 0,
      });

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign up. Please try again.';
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last login time
      await _firestore.collection('users').doc(userCredential.user!.uid).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred during sign in. Please try again.';
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw 'Google sign in was cancelled';
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Check if user document exists, if not create it
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'userId': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'User',
          'role': 'customer', // Default role
          'profileImage': userCredential.user!.photoURL,
          'isActive': true,
          'isEmailVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'totalOrders': 0,
          'totalSpent': 0,
        });
      }

      return userCredential;
    } catch (e) {
      throw 'Google sign in failed: ${e.toString()}';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out: ${e.toString()}';
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An error occurred. Please try again.';
    }
  }

  // Verify email
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw 'Error sending verification email: ${e.toString()}';
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error updating password: ${e.toString()}';
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      String uid = _auth.currentUser!.uid;
      
      // Delete user document from Firestore
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete user from Firebase Auth
      await _auth.currentUser?.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Error deleting account: ${e.toString()}';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (_auth.currentUser == null) return null;
      
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      throw 'Error fetching user data: ${e.toString()}';
    }
  }

  // Update user data
  Future<void> updateUserData(Map<String, dynamic> data) async {
    try {
      if (_auth.currentUser == null) throw 'No user logged in';
      
      data['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .update(data);
    } catch (e) {
      throw 'Error updating user data: ${e.toString()}';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
```

### Step 7.2: Initialize Firebase in main.dart

Update your `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// ... other imports

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... your theme configuration
      ),
      // Use AuthWrapper to check authentication state
      home: const AuthWrapper(),
      // ... your routes
    );
  }
}
```

### Step 7.3: Create Auth Wrapper

Create `lib/widgets/auth_wrapper.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:madpractical/pages/sign_in_screen.dart';
import 'package:madpractical/pages/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // User is signed in
        if (snapshot.hasData) {
          return HomeScreen();
        }
        
        // User is not signed in
        return SignInScreen();
      },
    );
  }
}
```

---

## 8. Update Existing Screens

### Step 8.1: Update Sign In Screen

Update `lib/pages/sign_in_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/constants/app_colors.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = FirebaseAuthService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Navigation is handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();
      // Navigation is handled by AuthWrapper
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo or Title
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 8),
                
                const Text(
                  'Sign in to continue',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Google Sign In Button
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  icon: Image.asset(
                    'assets/google_logo.png', // Add Google logo to assets
                    height: 24,
                    width: 24,
                  ),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Step 8.2: Update Sign Up Screen

Similar updates for `lib/pages/sign_up_screen.dart` using `_authService.signUpWithEmail()`.

### Step 8.3: Update Profile Screen Logout

Update logout in `lib/pages/profile_screen.dart`:

```dart
// In logout button onPressed
ElevatedButton(
  onPressed: () async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              
              try {
                await FirebaseAuthService().signOut();
                // Navigation handled by AuthWrapper
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  },
  child: const Text('Logout'),
),
```

---

## 9. Testing

### Step 9.1: Test on Android

```bash
flutter run
```

### Step 9.2: Test Authentication Flow

1. **Sign Up**: Create a new account
2. **Email Verification**: Check email for verification link
3. **Sign In**: Log in with created account
4. **Forgot Password**: Test password reset
5. **Google Sign In**: Test Google authentication
6. **Sign Out**: Test logout functionality

### Step 9.3: Check Firebase Console

1. Go to Firebase Console > Authentication > Users
2. Verify new users appear in the list
3. Go to Firestore > users collection
4. Verify user documents are created

---

## 10. Troubleshooting

### Common Issues and Solutions

#### Issue 1: "MissingPluginException"
**Solution**: Run `flutter clean` then `flutter pub get`

#### Issue 2: "PlatformException: sign_in_failed"
**Solution**: 
- Check SHA-1 fingerprint is added in Firebase Console
- Regenerate google-services.json

#### Issue 3: "FirebaseException: [core/no-app]"
**Solution**: Ensure Firebase.initializeApp() is called before runApp()

#### Issue 4: Google Sign In not working
**Solution**:
- Enable Google Sign-In in Firebase Console
- Add SHA-1 and SHA-256 fingerprints
- Download updated google-services.json

#### Issue 5: iOS build fails
**Solution**:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Get SHA-1 Fingerprint

**For Debug:**
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**For Release:**
```bash
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

Add the SHA-1 and SHA-256 to Firebase Console:
1. Project Settings > Your apps > Android app
2. Add fingerprint
3. Download new google-services.json

---

## 11. Next Steps

After successful Firebase Authentication setup:

1. **Implement User Roles**: Add role-based access control
2. **Add Profile Management**: Allow users to update profile
3. **Implement Email Verification Flow**: Force email verification
4. **Add Phone Authentication**: Implement OTP verification
5. **Setup Firestore Security Rules**: Secure your database
6. **Add Error Handling**: Improve error messages
7. **Implement Offline Support**: Add local caching
8. **Add Analytics**: Track user behavior
9. **Setup Push Notifications**: Use Firebase Cloud Messaging
10. **Deploy to Production**: Configure release builds

---

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Auth Flutter](https://firebase.flutter.dev/docs/auth/overview)
- [Firebase Console](https://console.firebase.google.com/)

---

## Security Best Practices

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to public repos
2. **Use environment variables** for sensitive data
3. **Implement proper security rules** in Firestore
4. **Enable App Check** for additional security
5. **Use HTTPS** for all API calls
6. **Implement rate limiting** to prevent abuse
7. **Validate all user inputs** on both client and server
8. **Keep dependencies updated** regularly
9. **Use strong password requirements**
10. **Implement 2FA** for sensitive operations

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Author:** Campus Cart Development Team
