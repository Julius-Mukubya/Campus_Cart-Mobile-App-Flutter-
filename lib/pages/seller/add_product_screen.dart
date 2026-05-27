import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/providers/user_provider.dart';
import 'package:madpractical/providers/seller_provider.dart';
import 'package:madpractical/widgets/common/notification_icon.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Electronics';
  String _storeName = '';
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  final List<String> _categories = [
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Groceries',
    'Books',
  ];

  bool _isLoadingStore = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSellerStore());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerStore() async {
    setState(() => _isLoadingStore = true);
    try {
      final userState = ref.read(userProvider);
      final storeId = userState.storeId;

      if (storeId != null && storeId.isNotEmpty) {
        final storeDoc = await FirebaseFirestore.instance
            .collection('stores')
            .doc(storeId)
            .get();
        if (storeDoc.exists) {
          _storeName = storeDoc.data()?['storeName'] as String? ?? 'My Store';
        } else {
          _storeName = 'My Store';
        }
      } else {
        _storeName = 'No store found';
      }
    } catch (e) {
      _storeName = 'Error loading store';
    }
    if (mounted) setState(() => _isLoadingStore = false);
  }

  Future<void> _pickImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages = pickedFiles.map((xFile) => File(xFile.path)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking images: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (pickedFile != null) {
        setState(() {
          _selectedImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() { _selectedImages.removeAt(index); });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            filled: true, fillColor: AppColors.white, contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.lightGrey)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
            filled: true, fillColor: AppColors.white, contentPadding: const EdgeInsets.all(16),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(value: category, child: Text(category));
          }).toList(),
          onChanged: (value) { setState(() { _selectedCategory = value!; }); },
        ),
      ],
    );
  }

  Widget _buildStoreDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Store', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGrey),
          ),
          child: Row(
            children: [
              Icon(Icons.store, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isLoadingStore ? 'Loading...' : _storeName,
                  style: TextStyle(fontSize: 16, color: _isLoadingStore ? AppColors.grey : AppColors.text),
                ),
              ),
              if (_isLoadingStore)
                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('Your store is automatically selected', style: TextStyle(fontSize: 12, color: AppColors.grey, fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget _buildImageUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Product Images', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.text)),
        const SizedBox(height: 8),
        if (_selectedImages.isEmpty)
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(leading: const Icon(Icons.photo_library), title: const Text('Pick from Gallery'), onTap: () { Navigator.pop(context); _pickImages(); }),
                    ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take a Photo'), onTap: () { Navigator.pop(context); _pickImageFromCamera(); }),
                  ]),
                ),
              );
            },
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.lightGrey)),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.cloud_upload, color: AppColors.primary, size: 32)),
                  const SizedBox(height: 12),
                  const Text('Tap to upload images', style: TextStyle(fontSize: 14, color: AppColors.secondaryText)),
                ]),
              ),
            ),
          )
        else
          Column(children: [
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Pick from Gallery'), onTap: () { Navigator.pop(context); _pickImages(); }),
                              ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take a Photo'), onTap: () { Navigator.pop(context); _pickImageFromCamera(); }),
                            ]),
                          ),
                        );
                      },
                      child: Container(
                        width: 100, margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: AppColors.lightGrey, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary)),
                        child: const Center(child: Icon(Icons.add, color: AppColors.primary, size: 28)),
                      ),
                    );
                  }
                  return Container(
                    width: 100, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: FileImage(_selectedImages[index]), fit: BoxFit.cover)),
                    child: Stack(children: [
                      Positioned(top: 4, right: 4, child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.close, color: AppColors.white, size: 16)),
                      )),
                    ]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text('${_selectedImages.length} image(s) selected', style: const TextStyle(fontSize: 12, color: AppColors.secondaryText)),
          ]),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final userState = ref.read(userProvider);
    final storeId = userState.storeId;
    final sellerId = userState.userId;

    if (storeId == null || storeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No store found. Set up your store in Store Settings first.'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (sellerId == null || sellerId.isEmpty) return;

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(children: [CircularProgressIndicator(strokeWidth: 2, color: AppColors.white), SizedBox(width: 12), Text('Uploading...')]),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 30),
      ),
    );

    // Upload first image if selected
    String productImage = '';
    if (_selectedImages.isNotEmpty) {
      try {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final storageRef = FirebaseStorage.instance.ref().child('product_images/${sellerId}_$timestamp.jpg');
        await storageRef.putFile(_selectedImages.first);
        productImage = await storageRef.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image upload failed: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
        return;
      }
    }

    // Save product to Firestore
    ref.read(sellerProvider.notifier).addProduct({
      'sellerId': sellerId,
      'storeId': storeId,
      'productName': _nameController.text.trim(),
      'productDescription': _descriptionController.text.trim(),
      'category': _selectedCategory,
      'price': double.tryParse(_priceController.text) ?? 0,
      'stockQuantity': int.tryParse(_stockController.text) ?? 0,
      'productImage': productImage,
      'discount': double.tryParse(_discountController.text) ?? 0,
    });

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
      );
      // Navigate to My Products — safe from any entry point
      context.go('/seller/products');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
              BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2)),
            ]),
            child: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 16),
          ),
        ),
        title: const Text('Add Product', style: TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 20)),
        actions: const [NotificationIcon()],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildTextField(controller: _nameController, label: 'Product Name', hint: 'Enter product name',
                validator: (value) { if (value == null || value.isEmpty) return 'Please enter product name'; return null; },
              ),
              const SizedBox(height: 20),
              _buildCategoryDropdown(),
              const SizedBox(height: 20),
              _buildStoreDropdown(),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _buildTextField(controller: _priceController, label: 'Price (UGX)', hint: '0', keyboardType: TextInputType.number,
                  validator: (value) { if (value == null || value.isEmpty) return 'Please enter price'; return null; },
                )),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(controller: _discountController, label: 'Discount (%)', hint: '0', keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 20),
              _buildTextField(controller: _stockController, label: 'Stock Quantity', hint: '0', keyboardType: TextInputType.number,
                validator: (value) { if (value == null || value.isEmpty) return 'Please enter stock quantity'; return null; },
              ),
              const SizedBox(height: 20),
              _buildTextField(controller: _descriptionController, label: 'Description', hint: 'Enter product description', maxLines: 4,
                validator: (value) { if (value == null || value.isEmpty) return 'Please enter product description'; return null; },
              ),
              const SizedBox(height: 20),
              _buildImageUploader(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 2),
                  child: const Text('Save Product', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}