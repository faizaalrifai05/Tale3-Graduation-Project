import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import '../../providers/saved_places_provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverSavedPlacesScreen extends StatelessWidget {
  const DriverSavedPlacesScreen({super.key});

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
          ? Center(child: CircularProgressIndicator())
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
                    onPressed: () => _showAddDialog(context),
                    icon: Icon(Icons.add, color: AppStyles.onPrimary),
                    label: Text(
                      context.l10n.addNewPlace,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _AddPlaceDialog(
        onSave: (title, subtitle, iconName) async {
          final error = await context.read<SavedPlacesProvider>().addPlace(
                title: title,
                subtitle: subtitle,
                iconName: iconName,
              );
          if (error != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: AppStyles.errorColor),
            );
          }
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TILE
// ─────────────────────────────────────────────────────────────────────────────
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
        child: Icon(Icons.delete_outline, color: AppStyles.onPrimary, size: 24),
      ),
      onDismissed: (_) => context.read<SavedPlacesProvider>().deletePlace(place.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              child: Icon(place.icon, color: AppStyles.primaryColor, size: 24),
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
                    style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.colors.textTertiary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ADD DIALOG
// ─────────────────────────────────────────────────────────────────────────────
class _AddPlaceDialog extends StatefulWidget {
  final Future<void> Function(String title, String subtitle, String iconName) onSave;
  const _AddPlaceDialog({required this.onSave});

  @override
  State<_AddPlaceDialog> createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<_AddPlaceDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  String _selectedIcon = 'place';
  bool _saving = false;


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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        context.l10n.addPlace,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon picker
          Text(context.l10n.placeType, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.colors.textSecondary)),
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
                          color: selected ? AppStyles.onPrimary : AppStyles.primaryColor),
                    ),
                    const SizedBox(height: 4),
                    Text(label,
                        style: TextStyle(
                            fontSize: 10,
                            color: selected ? AppStyles.primaryColor : context.colors.textSecondary,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          // Title field
          TextField(
            controller: _titleController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: context.l10n.placeNameLabel,
              labelStyle: TextStyle(fontSize: 13, color: context.colors.textSecondary),
              filled: true,
              fillColor: context.colors.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.colors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Address field
          TextField(
            controller: _subtitleController,
            decoration: InputDecoration(
              labelText: context.l10n.addressLabel,
              labelStyle: TextStyle(fontSize: 13, color: context.colors.textSecondary),
              filled: true,
              fillColor: context.colors.inputFillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: context.colors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel,
              style: TextStyle(color: context.colors.textSecondary, fontWeight: FontWeight.w600)),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: AppStyles.onPrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: _saving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(color: AppStyles.onPrimary, strokeWidth: 2),
                )
              : Text(context.l10n.save, style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
