import 'package:flutter/material.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'package:madpractical/services/firebase_auth_service.dart';
import 'package:madpractical/services/user_manager.dart';
import 'edit_address_screen.dart';

class SelectAddressScreen extends StatefulWidget {
  const SelectAddressScreen({super.key});

  @override
  State<SelectAddressScreen> createState() => _SelectAddressScreenState();
}

class _SelectAddressScreenState extends State<SelectAddressScreen> {
  final _authService = FirebaseAuthService();
  final _userManager = UserManager();

  List<Map<String, dynamic>> _addresses = [];
  String? _selectedId;
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
    // Filter out placeholder addresses with no real data
    final valid = list.where((a) {
      final line1 = (a['addressLine1'] ?? '').toString().trim();
      final name  = (a['fullName'] ?? '').toString().trim();
      return line1.isNotEmpty || name.isNotEmpty;
    }).toList();
    setState(() {
      _addresses = valid;
      _loading = false;
      final def = valid.firstWhere((a) => a['isDefault'] == true,
          orElse: () => valid.isNotEmpty ? valid.first : <String, dynamic>{});
      if (def.isNotEmpty) _selectedId = def['addressId'];
    });
  }

  Future<void> _openEdit([Map<String, dynamic>? addr]) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditAddressScreen(existing: addr)),
    );
    if (result != null) {
      final uid = _userManager.userId ?? _authService.currentUser?.uid;
      String? docId;
      if (uid != null) {
        docId = await _authService.addUserAddress(
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
      final newAddr = {
        'addressId': docId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'label': result['label'] ?? 'Address',
        'fullName': '${result['firstName']} ${result['lastName']}'.trim(),
        'phone': result['phone'] ?? '',
        'addressLine1': result['street'] ?? '',
        'city': result['region'] ?? '',
        'isDefault': result['isDefault'] == true,
      };
      setState(() {
        if (newAddr['isDefault'] == true) {
          for (final a in _addresses) { a['isDefault'] = false; }
        }
        if (addr != null) {
          final idx = _addresses.indexWhere((a) => a['addressId'] == addr['addressId']);
          if (idx >= 0) _addresses[idx] = newAddr;
        } else {
          _addresses.add(newAddr);
        }
        _selectedId = newAddr['addressId'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Address',
            style: TextStyle(
                color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ))
          : _addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off_outlined,
                          size: 56, color: AppColors.lightGrey),
                      const SizedBox(height: 12),
                      const Text('No saved addresses yet.',
                          style: TextStyle(color: AppColors.secondaryText)),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _openEdit(),
                        icon: const Icon(Icons.add, color: AppColors.primary),
                        label: const Text('Add Address',
                            style: TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _addresses.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: AppColors.lightGrey),
                  itemBuilder: (_, i) {
                    final addr = _addresses[i];
                    final isSelected = _selectedId == addr['addressId'];
                    final isDefault = addr['isDefault'] == true;
                    return InkWell(
                      onTap: () => setState(() => _selectedId = addr['addressId']),
                      child: Container(
                        color: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Radio<String>(
                              value: addr['addressId'],
                              groupValue: _selectedId,
                              activeColor: AppColors.primary,
                              onChanged: (v) =>
                                  setState(() => _selectedId = v),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(addr['fullName'] ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.text)),
                                  const SizedBox(height: 3),
                                  Text(addr['addressLine1'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryText)),
                                  Text(addr['city'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.secondaryText)),
                                  if (isDefault) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.check_circle_outline,
                                            size: 14,
                                            color: AppColors.success),
                                        const SizedBox(width: 4),
                                        Text('Default address',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.success,
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.primary, size: 20),
                              onPressed: () => _openEdit(addr),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _selectedId == null
                        ? null
                        : () {
                            final addr = _addresses.firstWhere(
                                (a) => a['addressId'] == _selectedId);
                            Navigator.pop(context, addr);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.lightGrey,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Select Address',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 52,
                width: 52,
                child: OutlinedButton(
                  onPressed: () => _openEdit(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                  ),
                  child: const Icon(Icons.add, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
