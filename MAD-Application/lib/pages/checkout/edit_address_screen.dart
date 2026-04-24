import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:madpractical/constants/app_colors.dart';
import 'map_location_picker.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const EditAddressScreen({super.key, this.existing});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _phone2;
  late final TextEditingController _street;
  late final TextEditingController _additional;
  String _region = 'Kampala Region';
  bool _isDefault = false;
  LatLng? _pickedLocation;
  String _pickedLocationLabel = '';

  final List<String> _regions = [
    'Kampala Region',
    'Central Region',
    'Eastern Region',
    'Northern Region',
    'Western Region',
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final fullName = (e?['fullName'] ?? '').toString().split(' ');
    _firstName  = TextEditingController(text: fullName.isNotEmpty ? fullName.first : '');
    _lastName   = TextEditingController(
        text: fullName.length > 1 ? fullName.sublist(1).join(' ') : '');
    _phone      = TextEditingController(text: e?['phone'] ?? '');
    _phone2     = TextEditingController();
    _street     = TextEditingController(text: e?['addressLine1'] ?? '');
    _additional = TextEditingController();
    _isDefault  = e?['isDefault'] == true;
    final city  = e?['city'] ?? 'Kampala Region';
    _region     = _regions.contains(city) ? city : 'Kampala Region';
  }

  @override
  void dispose() {
    _firstName.dispose(); _lastName.dispose(); _phone.dispose();
    _phone2.dispose(); _street.dispose(); _additional.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: AppColors.secondaryText),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.lightGrey)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error)),
        filled: true,
        fillColor: AppColors.white,
      );

  Widget _field(TextEditingController ctrl, String label,
      {TextInputType keyboard = TextInputType.text,
      String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      decoration: _dec(label),
    );
  }

  Widget _prefixDropdown() => Container(
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(10),
          color: AppColors.white,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: '+256',
            items: const [
              DropdownMenuItem(value: '+256', child: Text('+256')),
              DropdownMenuItem(value: '+254', child: Text('+254')),
              DropdownMenuItem(value: '+255', child: Text('+255')),
            ],
            onChanged: (_) {},
            style: TextStyle(color: AppColors.text, fontSize: 14),
            icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            widget.existing != null ? 'Edit Address' : 'Add Address',
            style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_firstName, 'First Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            _field(_lastName, 'Last Name',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),

            // Primary phone
            Row(
              children: [
                SizedBox(width: 100, child: _prefixDropdown()),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(_phone, 'Phone Number',
                      keyboard: TextInputType.phone,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Additional phone
            Row(
              children: [
                SizedBox(width: 100, child: _prefixDropdown()),
                const SizedBox(width: 10),
                Expanded(
                  child: _field(
                      _phone2, 'Additional Phone Number (optional)',
                      keyboard: TextInputType.phone),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _field(_street,
                'Street Name / Building Number / Apartment Number',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Required' : null),
            const SizedBox(height: 14),
            _field(_additional, 'Additional information'),
            const SizedBox(height: 14),

            // Region dropdown
            DropdownButtonFormField<String>(
              value: _region,
              decoration: _dec('Region'),
              items: _regions
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _region = v!),
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            // Pick on map
            OutlinedButton.icon(
              onPressed: () async {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MapLocationPicker(
                      initialLocation: _pickedLocation,
                    ),
                  ),
                );
                if (result != null) {
                  setState(() {
                    _pickedLocation = result['location'] as LatLng;
                    _pickedLocationLabel = result['label'] as String? ?? '';
                    // Pre-fill street field if it's empty
                    if (_street.text.isEmpty && _pickedLocationLabel.isNotEmpty) {
                      _street.text = _pickedLocationLabel;
                    }
                  });
                }
              },
              icon: const Icon(Icons.map_outlined, color: AppColors.primary),
              label: Text(
                _pickedLocationLabel.isNotEmpty
                    ? _pickedLocationLabel
                    : 'Pick Location on Map',
                style: const TextStyle(color: AppColors.primary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                minimumSize: const Size(double.infinity, 0),
              ),
            ),
            const SizedBox(height: 16),

            // Default toggle
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _isDefault,
                    onChanged: (v) => setState(() => _isDefault = v),
                    activeColor: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Set as default address',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.text)),
                ],
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.pop(context, {
                    'firstName': _firstName.text.trim(),
                    'lastName': _lastName.text.trim(),
                    'phone': _phone.text.trim(),
                    'street': _street.text.trim(),
                    'region': _region,
                    'isDefault': _isDefault,
                    'label': _pickedLocationLabel.isNotEmpty
                        ? _pickedLocationLabel
                        : _region,
                    'latitude': _pickedLocation?.latitude,
                    'longitude': _pickedLocation?.longitude,
                    'locationLabel': _pickedLocationLabel,
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Save Address',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
