import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:madpractical/constants/app_colors.dart';

class MapLocationPicker extends StatefulWidget {
  final LatLng? initialLocation;
  const MapLocationPicker({super.key, this.initialLocation});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  static const LatLng _kampala = LatLng(0.3476, 32.5825);

  late final MapController _mapController;
  LatLng _picked = _kampala;
  String _pickedLabel = '';

  // Search
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  List<Map<String, dynamic>> _suggestions = [];
  bool _searching = false;
  Timer? _debounce;

  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    if (widget.initialLocation != null) _picked = widget.initialLocation!;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Nominatim geocoding (free, no key) ──────────────────────────────────────
  Future<void> _search(String query) async {
    if (query.trim().length < 3) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=6&addressdetails=1',
      );
      final res = await http.get(uri,
          headers: {'User-Agent': 'CampusCartApp/1.0'});
      if (res.statusCode == 200) {
        final List data = jsonDecode(res.body);
        setState(() {
          _suggestions = data
              .map<Map<String, dynamic>>((e) => {
                    'display_name': e['display_name'],
                    'lat': double.parse(e['lat']),
                    'lon': double.parse(e['lon']),
                  })
              .toList();
        });
      }
    } catch (_) {
      // silently fail — user can still tap the map
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(v));
  }

  void _selectSuggestion(Map<String, dynamic> s) {
    final loc = LatLng(s['lat'], s['lon']);
    // Shorten the display name to the first two comma-separated parts
    final parts = (s['display_name'] as String).split(',');
    final label = parts.take(2).join(',').trim();
    setState(() {
      _picked = loc;
      _pickedLabel = label;
      _suggestions = [];
      _searchCtrl.text = label;
    });
    _searchFocus.unfocus();
    _mapController.move(loc, 15);
  }

  void _onMapTap(TapPosition _, LatLng loc) {
    setState(() {
      _picked = loc;
      _pickedLabel = '';
      _suggestions = [];
    });
    _searchFocus.unfocus();
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locating = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Location permission denied. Enable it in settings.'),
            backgroundColor: AppColors.error,
          ));
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _picked = loc;
        _pickedLabel = 'My Location';
        _searchCtrl.text = 'My Location';
      });
      _mapController.move(loc, 16);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not get location: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pick Delivery Location',
            style: TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: Stack(
        children: [
          // ── Map ─────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _picked,
              initialZoom: 14,
              onTap: _onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.madpractical',
              ),
              MarkerLayer(markers: [
                Marker(
                  point: _picked,
                  width: 48,
                  height: 48,
                  child: const Icon(Icons.location_pin,
                      color: AppColors.primary, size: 48),
                ),
              ]),
            ],
          ),

          // ── Search bar + suggestions ─────────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Column(
              children: [
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    focusNode: _searchFocus,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search for a place, e.g. Makerere University',
                      hintStyle: const TextStyle(
                          color: AppColors.grey, fontSize: 14),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.primary),
                      suffixIcon: _searching
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primary),
                                ),
                              ),
                            )
                          : _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: AppColors.grey, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    setState(() => _suggestions = []);
                                  },
                                )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                // Suggestions dropdown
                if (_suggestions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const Divider(
                          height: 1, color: AppColors.lightGrey),
                      itemBuilder: (_, i) {
                        final s = _suggestions[i];
                        final parts =
                            (s['display_name'] as String).split(',');
                        final title = parts.first.trim();
                        final subtitle =
                            parts.skip(1).take(2).join(',').trim();
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.location_on_outlined,
                              color: AppColors.primary, size: 20),
                          title: Text(title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text)),
                          subtitle: subtitle.isNotEmpty
                              ? Text(subtitle,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.secondaryText),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis)
                              : null,
                          onTap: () => _selectSuggestion(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ── Selected location label ──────────────────────────────────────────
          if (_pickedLabel.isNotEmpty || _suggestions.isEmpty)
            Positioned(
              bottom: 90,
              left: 12,
              right: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _pickedLabel.isNotEmpty
                            ? _pickedLabel
                            : 'Tap the map to pin your location',
                        style: TextStyle(
                          fontSize: 13,
                          color: _pickedLabel.isNotEmpty
                              ? AppColors.text
                              : AppColors.secondaryText,
                          fontWeight: _pickedLabel.isNotEmpty
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── My location FAB ──────────────────────────────────────────────────
          Positioned(
            bottom: 90,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'my_loc',
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              onPressed: _locating ? null : _goToMyLocation,
              child: _locating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary)))
                  : const Icon(Icons.my_location, size: 20),
            ),
          ),
        ],
      ),

      // ── Confirm button ───────────────────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, {
                'location': _picked,
                'label': _pickedLabel,
              }),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Confirm Location',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
