import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/utils/app_logger.dart';

/// Seller store settings screen.
/// Allows sellers to update their store name, description, and contact preferences.
class SellerStoreSettingsScreen extends ConsumerStatefulWidget {
  const SellerStoreSettingsScreen({super.key});

  @override
  ConsumerState<SellerStoreSettingsScreen> createState() => _SellerStoreSettingsScreenState();
}

class _SellerStoreSettingsScreenState extends ConsumerState<SellerStoreSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _showContactToCustomers = true;
  String? _storeId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStoreData());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    try {
      final userState = ref.read(userProvider);
      final storeId = userState.storeId;
      final userId = userState.userId;

      if (storeId != null && storeId.isNotEmpty) {
        _storeId = storeId;
        final storeDoc = await FirebaseFirestore.instance.collection('stores').doc(storeId).get();
        if (storeDoc.exists) {
          final data = storeDoc.data()!;
          _nameController.text = data['storeName'] ?? '';
          _descriptionController.text = data['storeDescription'] ?? '';
          _phoneController.text = data['storePhone'] ?? '';
          _emailController.text = data['storeEmail'] ?? '';
          _showContactToCustomers = data['showContact'] ?? true;
        }
      } else if (userId != null && userId.isNotEmpty) {
        // No storeId yet — load from user data
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          _nameController.text = data['name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          _showContactToCustomers = data['showContact'] ?? true;
        }
      }
    } catch (e) {
      AppLogger.error('Error loading store data', error: e);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final userState = ref.read(userProvider);
      final userId = userState.userId;
      if (userId == null || userId.isEmpty) {
        if (mounted) _showError('User not logged in');
        return;
      }

      final storeData = {
        'storeName': _nameController.text.trim(),
        'storeDescription': _descriptionController.text.trim(),
        'storePhone': _phoneController.text.trim(),
        'storeEmail': _emailController.text.trim(),
        'showContact': _showContactToCustomers,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Update user doc with store description/contact info
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'description': _descriptionController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (_storeId != null && _storeId!.isNotEmpty) {
        // Update existing store doc
        await FirebaseFirestore.instance.collection('stores').doc(_storeId!).update(storeData);
      } else {
        // Create new store doc
        final storeRef = await FirebaseFirestore.instance.collection('stores').add({
          ...storeData,
          'sellerId': userId,
          'storeId': '',
          'isActive': true,
          'isVerified': false,
          'rating': 0,
          'totalProducts': 0,
          'totalOrders': 0,
          'totalSales': 0,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _storeId = storeRef.id;
        await FirebaseFirestore.instance.collection('stores').doc(storeRef.id).update({'storeId': storeRef.id});
        await FirebaseFirestore.instance.collection('users').doc(userId).update({'storeId': storeRef.id});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Store settings saved!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Error saving store', error: e);
      if (mounted) _showError('Failed to save: $e');
    }
    if (mounted) setState(() => _isSaving = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.getBackground(context),
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios, size: 16),
          ),
        ),
        title: Text(
          'Store Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Name
                      _buildLabel('Store Name'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: _inputDecoration('Enter your store name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Store name is required' : null,
                      ),
                      const SizedBox(height: 20),

                      // Store Description
                      _buildLabel('Store Description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration('Describe your store...'),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // Contact Info Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.getSurface(context),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDark ? [] : [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Contact Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Phone Number'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration('Enter phone number'),
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            _buildLabel('Email Address'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration('Enter email address'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                'Show contact to customers',
                                style: TextStyle(fontSize: 14),
                              ),
                              subtitle: const Text(
                                'When enabled, customers can see your phone and email',
                                style: TextStyle(fontSize: 12),
                              ),
                              value: _showContactToCustomers,
                              activeThumbColor: AppColors.primary,
                              onChanged: (v) => setState(() => _showContactToCustomers = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveStore,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Store Settings',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: AppColors.getSurface(context),
      contentPadding: const EdgeInsets.all(16),
    );
  }
}