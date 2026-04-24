import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'package:madpractical/pages/checkout/edit_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _authService = FirebaseAuthService();
  final _userManager = UserManager();

  List<Map<String, dynamic>> _addresses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    final list = await _authService.getUserAddresses(uid);
    setState(() {
      _addresses = list.where((a) {
        final line1 = (a['addressLine1'] ?? '').toString().trim();
        final name  = (a['fullName'] ?? '').toString().trim();
        return line1.isNotEmpty || name.isNotEmpty;
      }).toList();
      _loading = false;
    });
  }

  Future<void> _openEdit([Map<String, dynamic>? existing]) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditAddressScreen(existing: existing)),
    );
    if (result == null) return;

    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid != null) {
      await _authService.addUserAddress(
        userId: uid,
        label: result['label'] ?? 'Address',
        fullName: '${result['firstName']} ${result['lastName']}'.trim(),
        phone: result['phone'] ?? '',
        addressLine1: result['street'] ?? '',
        city: result['region'] ?? '',
        state: result['region'] ?? '',
        postalCode: '',
        isDefault: result['isDefault'] == true,
      );
    }
    _load(); // reload from Firestore
  }

  Future<void> _delete(Map<String, dynamic> addr) async {
    final uid = _userManager.userId ?? _authService.currentUser?.uid;
    if (uid == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Firestore delete — reload after removal
    try {
      final uid2 = _userManager.userId ?? _authService.currentUser?.uid;
      if (uid2 != null) await _authService.getUserAddresses(uid2);
    } catch (_) {}

    setState(() => _addresses.remove(addr));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Address deleted'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
          onPressed: () => Navigator.pop(context),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.getSurface(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Icon(Icons.arrow_back_ios, color: Theme.of(context).iconTheme.color, size: 16),
          ),
        ),
        title: Text('My Addresses',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined, size: 64, color: AppColors.lightGrey),
                      const SizedBox(height: 12),
                      const Text('No saved addresses', style: TextStyle(fontSize: 16, color: AppColors.secondaryText)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _openEdit(),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Address'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _addresses.length,
                  itemBuilder: (_, i) {
                    final addr = _addresses[i];
                    final isDefault = addr['isDefault'] == true;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.getSurface(context),
                        borderRadius: BorderRadius.circular(16),
                        border: isDefault ? Border.all(color: AppColors.primary, width: 2) : null,
                        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, 5))],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(addr['label'] ?? 'Address',
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ),
                                if (isDefault) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text('Default',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success)),
                                  ),
                                ],
                                const Spacer(),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                                  onPressed: () => _openEdit(addr),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => _delete(addr),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(addr['fullName'] ?? '',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            const SizedBox(height: 4),
                            if ((addr['phone'] ?? '').isNotEmpty)
                              Text(addr['phone'], style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                            const SizedBox(height: 4),
                            Text(addr['addressLine1'] ?? '', style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                            if ((addr['city'] ?? '').isNotEmpty)
                              Text(addr['city'], style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: _addresses.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openEdit(),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: AppColors.white),
              label: const Text('Add Address', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
    );
  }
}
