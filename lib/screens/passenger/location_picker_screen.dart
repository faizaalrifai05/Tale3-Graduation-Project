import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/saved_places_provider.dart';
import 'package:testtale3/theme/app_styles.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final LatLng initialPosition;
  final String confirmLabel;
  final Color pinColor;
  final bool showSavedPlaces;

  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.initialPosition,
    this.confirmLabel = 'Confirm Location',
    this.pinColor = AppStyles.primaryColor,
    this.showSavedPlaces = false,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _pickedLocation;
  bool _mapReady = false;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
  }

  void _snapToPlace(SavedPlace place) {
    if (place.lat == null || place.lng == null) return;
    final target = LatLng(place.lat!, place.lng!);
    _mapController?.animateCamera(CameraUpdate.newLatLng(target));
    setState(() => _pickedLocation = target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen draggable map — pin stays fixed in center
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.initialPosition, zoom: 13),
            onMapCreated: (c) {
              _mapController = c;
              setState(() => _mapReady = true);
            },
            onCameraMove: (pos) => _pickedLocation = pos.target,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Top bar (back + title + instruction chip)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back row
                  Container(
                    color: context.colors.surfaceColor,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back,
                              color: context.colors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(null),
                        ),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Instruction pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_with_rounded,
                            size: 15, color: widget.pinColor),
                        const SizedBox(width: 7),
                        Text(
                          widget.instruction,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: context.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fixed center pin (IgnorePointer so map gestures pass through)
          if (_mapReady) ...[
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.location_pin,
                      size: 52, color: widget.pinColor),
                ),
              ),
            ),
            // Pin shadow
            IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 44),
                  child: Container(
                    width: 10,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Saved places strip (shown only when requested)
          if (widget.showSavedPlaces)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Consumer<SavedPlacesProvider>(
                builder: (context, spp, _) {
                  final places = spp.places
                      .where((p) => p.lat != null && p.lng != null)
                      .toList();
                  if (places.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: places.length,
                      separatorBuilder: (context, i) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final place = places[i];
                        return GestureDetector(
                          onTap: () => _snapToPlace(place),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.colors.surfaceColor,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(place.icon,
                                    size: 16, color: AppStyles.primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  place.title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

          // Confirm button
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: ElevatedButton(
              onPressed: _mapReady
                  ? () => Navigator.of(context).pop(_pickedLocation)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.darkMaroon,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBDBDBD),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                minimumSize: const Size(double.infinity, 52),
              ),
              child: Text(
                widget.confirmLabel,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
