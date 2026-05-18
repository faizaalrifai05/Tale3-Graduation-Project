import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/screens/passenger/location_picker_screen.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/providers/saved_places_provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class PassengerSavedPlacesScreen extends StatefulWidget {
  const PassengerSavedPlacesScreen({super.key});

  @override
  State<PassengerSavedPlacesScreen> createState() =>
      _PassengerSavedPlacesScreenState();
}

class _PassengerSavedPlacesScreenState
    extends State<PassengerSavedPlacesScreen> {
  static const LatLng _amman = LatLng(31.9539, 35.9106);

  Future<String> _reverseGeocode(LatLng point) async {
    const cities = {
      'Amman': LatLng(31.9539, 35.9106),
      'Zarqa': LatLng(32.0728, 36.0878),
      'Irbid': LatLng(32.5556, 35.8500),
      'Aqaba': LatLng(29.5269, 35.0065),
      'Madaba': LatLng(31.7167, 35.8000),
      'Jerash': LatLng(32.2833, 35.9000),
      'Ajloun': LatLng(32.3333, 35.7500),
      'Karak': LatLng(31.1833, 35.7000),
      'Mafraq': LatLng(32.3417, 36.2042),
      'Salt': LatLng(32.0333, 35.7167),
      'Russeifa': LatLng(32.0417, 36.0583),
      'Ramtha': LatLng(32.5667, 36.0000),
      'Tafilah': LatLng(30.8333, 35.6000),
      'Maan': LatLng(30.2000, 35.7333),
      'Petra': LatLng(30.3217, 35.4789),
      'Azraq': LatLng(31.8417, 36.8167),
    };
    String? nearest;
    double nearestDist = double.infinity;
    for (final entry in cities.entries) {
      final d = MapsService.distanceKm(point, entry.value);
      if (d < nearestDist) {
        nearestDist = d;
        nearest = entry.key;
      }
    }
    if (nearestDist <= 15 && nearest != null) return nearest;
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=${point.latitude},${point.longitude}'
        '&key=${MapsService.apiKey}'
        '&language=en'
        '&result_type=locality|sublocality|administrative_area_level_2',
      );
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final components =
                (results.first['address_components'] as List)
                    .map((c) => c as Map<String, dynamic>)
                    .toList();
            for (final type in [
              'locality',
              'sublocality',
              'administrative_area_level_2'
            ]) {
              final match = components.firstWhere(
                (c) => (c['types'] as List).contains(type),
                orElse: () => {},
              );
              if (match.isNotEmpty) return match['long_name'] as String;
            }
          }
        }
      }
    } catch (_) {}
    return '${point.latitude.toStringAsFixed(4)}, '
        '${point.longitude.toStringAsFixed(4)}';
  }

  Future<void> _openAddPlace() async {
    if (!mounted) return;

    final picked = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: 'Pick Location',
          instruction: 'Drag the map to your saved place',
          initialPosition: _amman,
          confirmLabel: 'Use This Location',
        ),
      ),
    );

    if (picked == null || !mounted) return;

    final address = await _reverseGeocode(picked);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => _AddPlaceDialog(
        initialSubtitle: address,
        onSave: (title, subtitle, iconName) async {
          final provider = context.read<SavedPlacesProvider>();
          final messenger = ScaffoldMessenger.of(context);
          final error = await provider.addPlace(
            title: title,
            subtitle: subtitle,
            iconName: iconName,
            lat: picked.latitude,
            lng: picked.longitude,
          );
          if (error != null && mounted) {
            messenger.showSnackBar(
              SnackBar(
                  content: Text(error),
                  backgroundColor: AppStyles.errorColor),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SavedPlacesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Places',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (provider.places.isEmpty) ...[
                  const SizedBox(height: 60),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.colors.highlightBackgroundColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.bookmark_border_rounded,
                              size: 48, color: AppStyles.primaryColor),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          context.l10n.noSavedPlaces,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.savedPlacesEmptyDesc,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                  ...provider.places.map((place) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _SavedPlaceTile(place: place),
                      )),
                  const SizedBox(height: 20),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _openAddPlace,
                    icon: Icon(Icons.add, color: AppStyles.onPrimary),
                    label: Text(
                      context.l10n.addNewPlace,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.primaryColor,
                      foregroundColor: AppStyles.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _SavedPlaceTile extends StatelessWidget {
  final SavedPlace place;
  const _SavedPlaceTile({required this.place});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(place.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppStyles.errorColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline,
            color: AppStyles.onPrimary, size: 24),
      ),
      onDismissed: (_) =>
          context.read<SavedPlacesProvider>().deletePlace(place.id),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.colors.highlightBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(place.icon, color: AppStyles.primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.subtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (place.lat != null)
              Icon(Icons.location_on_rounded,
                  size: 16, color: AppStyles.primaryColor.withValues(alpha: 0.5)),
            Icon(Icons.chevron_right,
                color: context.colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _AddPlaceDialog extends StatefulWidget {
  final Future<void> Function(String title, String subtitle, String iconName)
      onSave;
  final String initialSubtitle;

  const _AddPlaceDialog({
    required this.onSave,
    this.initialSubtitle = '',
  });

  @override
  State<_AddPlaceDialog> createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<_AddPlaceDialog> {
  final _titleController = TextEditingController();
  late final TextEditingController _subtitleController;
  String _selectedIcon = 'place';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _subtitleController =
        TextEditingController(text: widget.initialSubtitle);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    if (title.isEmpty || subtitle.isEmpty) return;
    setState(() => _saving = true);
    await widget.onSave(title, subtitle, _selectedIcon);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      ('home', Icons.home_rounded, context.l10n.placeTypeHome),
      ('work', Icons.work_rounded, context.l10n.placeTypeWork),
      ('star', Icons.star_rounded, context.l10n.placeTypeFavourite),
      ('place', Icons.place_rounded, context.l10n.placeTypeOther),
    ];
    return AlertDialog(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        context.l10n.addPlace,
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: context.colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.placeType,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textSecondary)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: icons.map((entry) {
              final (id, icon, label) = entry;
              final selected = _selectedIcon == id;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = id),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppStyles.primaryColor
                            : context.colors.highlightBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon,
                          size: 22,
                          color: selected
                              ? AppStyles.onPrimary
                              : AppStyles.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            color: selected
                                ? AppStyles.primaryColor
                                : context.colors.textSecondary,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: context.l10n.placeNameLabel,
              labelStyle: TextStyle(
                  fontSize: 13, color: context.colors.textSecondary),
              filled: true,
              fillColor: context.colors.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.colors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: context.l10n.addressLabel,
              labelStyle: TextStyle(
                  fontSize: 13, color: context.colors.textSecondary),
              filled: true,
              fillColor: context.colors.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: context.colors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel,
              style: TextStyle(
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: AppStyles.onPrimary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: _saving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppStyles.onPrimary, strokeWidth: 2),
                )
              : Text(context.l10n.save,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
