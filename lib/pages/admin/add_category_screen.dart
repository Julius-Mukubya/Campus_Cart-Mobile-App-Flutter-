import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/category_service.dart';
import 'package:madpractical/utils/icon_utils.dart';

class AddCategoryScreen extends StatefulWidget {
  final Map<String, dynamic>? category; // null = add mode, non-null = edit mode

  const AddCategoryScreen({super.key, this.category});

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final CategoryService _categoryService = CategoryService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _orderController;
  late TextEditingController _imageController;
  String _selectedIcon = 'category';
  bool _isSaving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    _nameController = TextEditingController(text: cat?['name'] ?? '');
    _descController = TextEditingController(text: cat?['description'] ?? '');
    _orderController = TextEditingController(
      text: cat != null ? '${cat['order'] ?? cat['displayOrder'] ?? 0}' : '',
    );
    _imageController = TextEditingController(text: cat?['image'] ?? '');
    // Determine the initial icon: try new identifier format first, fallback to legacy name
    final rawIcon = cat?['icon']?.toString() ?? 'category';
    _selectedIcon = AppIcons.all.containsKey(rawIcon) ? rawIcon : _legacyToNew(rawIcon);
  }

  /// Map old category title names to new icon identifiers
  String _legacyToNew(String legacyName) {
    const legacyMap = {
      'Electronics': 'devices',
      'Fashion': 'checkroom',
      'Books': 'menu_book',
      'Food': 'restaurant',
      'Stationery': 'edit',
      'Sports': 'sports_soccer',
      'Home': 'home',
      'Beauty': 'face',
      'Music': 'music_note',
      'Pets': 'pets',
      'Toys': 'toys',
      'Health': 'local_hospital',
      'Accessories': 'watch',
      'General': 'category',
    };
    return legacyMap[legacyName] ?? 'category';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _orderController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final order = int.tryParse(_orderController.text.trim()) ?? 0;
    final image = _imageController.text.trim();

    if (_isEditing) {
      await _categoryService.updateCategory(
        widget.category!['id'],
        name: name,
        description: desc,
        icon: _selectedIcon,
        order: order,
        image: image.isNotEmpty ? image : null,
      );
    } else {
      await _categoryService.addCategory(
        name: name,
        description: desc,
        icon: _selectedIcon,
        order: order,
        image: image.isNotEmpty ? image : null,
      );
    }

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Category updated!' : 'Category added!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'Add Category'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.text),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              const Text(
                'Category Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter category name',
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
                  fillColor: AppColors.getSurface(context),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Category name is required'
                    : null,
              ),

              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Enter category description',
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
                  fillColor: AppColors.getSurface(context),
                ),
              ),

              const SizedBox(height: 20),

              // Image URL
              const Text(
                'Image URL',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _imageController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/category-image.jpg',
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
                  fillColor: AppColors.getSurface(context),
                  suffixIcon: _imageController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.preview, color: AppColors.primary),
                          onPressed: () => _showImagePreview(_imageController.text),
                        )
                      : null,
                ),
                onChanged: (_) => setState(() {}),
              ),

              // Image preview thumbnail
              if (_imageController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _imageController.text,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('Invalid image URL', style: TextStyle(color: AppColors.grey)),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Display Order
              const Text(
                'Display Order',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _orderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter display order (e.g. 1, 2, 3)',
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
                  fillColor: AppColors.getSurface(context),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Display order is required';
                  if (int.tryParse(value.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Icon Picker
              const Text(
                'Icon',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedIcon,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.getSurface(context),
                ),
                items: AppIcons.pickerItems.map((entry) {
                  return DropdownMenuItem(
                    value: entry['name'] as String,
                    child: Row(
                      children: [
                        Icon(entry['icon'] as IconData, size: 20, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Text('${entry['label']} (${entry['name']})'),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedIcon = value ?? 'category');
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
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
                      : Text(
                          _isEditing ? 'Update Category' : 'Add Category',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePreview(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Container(
              padding: const EdgeInsets.all(32),
              color: AppColors.white,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image, size: 48, color: AppColors.grey),
                  SizedBox(height: 8),
                  Text('Invalid image URL', style: TextStyle(color: AppColors.grey)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}