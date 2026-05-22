import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agree = false;
  String _selectedRole = 'customer'; // Default role

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signUp() {
    final name = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorMessage('Please fill in all fields');
      return;
    }

    if (!_agree) {
      _showErrorMessage('Please agree to the terms and conditions');
      return;
    }

    if (password.length < 6) {
      _showErrorMessage('Password must be at least 6 characters');
      return;
    }

    ref.read(authProvider.notifier).signUp(
      email: email,
      password: password,
      name: name,
      role: _selectedRole,
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Handle auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isLoggedIn && (previous == null || !previous.isLoggedIn)) {
        _showSuccessMessage('Account created successfully!');
        Future.microtask(() {
          if (mounted) {
            context.go('/home');
          }
        });
      } else if (next.error != null && next.error!.isNotEmpty && !next.isLoggedIn) {
        if (next.error == 'Account created. Your seller application is pending approval.') {
          _showSuccessMessage(next.error!);
          Future.microtask(() {
            if (mounted) {
              context.go('/signin');
            }
          });
        } else {
          _showErrorMessage(next.error!);
        }
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // App logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // Title
                const Text(
                  "Create Your Account",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  "Sign up to get started with\nyour shopping experience",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.grey),
                ),

                const SizedBox(height: 32),

                // Username label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Username",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
                    hintText: "Enter your username",
                    hintStyle: const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Email label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                    hintText: "Enter your email address",
                    hintStyle: const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Password label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    hintText: "Enter your password",
                    hintStyle: const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.lightGrey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.white,
                  ),
                ),

                const SizedBox(height: 20),

                // Role Selection label
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Account Type",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Role Selection Dropdown
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                    color: AppColors.white,
                  ),
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: _selectedRole,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    hint: const Text(
                      "Select account type",
                      style: TextStyle(color: AppColors.grey),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'customer',
                        child: Text('Customer'),
                      ),
                      DropdownMenuItem(
                        value: 'seller',
                        child: Text('Seller (requires approval)'),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRole = newValue!;
                      });
                    },
                    dropdownColor: AppColors.white,
                    style: const TextStyle(color: AppColors.text),
                  ),
                ),

                const SizedBox(height: 20),

                // Checkbox Terms
                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _agree = value!;
                        });
                      },
                    ),
                    Expanded(
                      child: Wrap(
                        children: [
                          const Text(
                            "I agree to ",
                            style: TextStyle(color: AppColors.text),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Privacy Policy",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Text(
                            " and ",
                            style: TextStyle(color: AppColors.text),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              "Terms of use",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Create Account Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: (_agree && !authState.isLoading) ? _signUp : null,
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Text(
                            "Create Account",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(color: AppColors.text),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/signin');
                      },
                      child: const Text(
                        "Log in here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}