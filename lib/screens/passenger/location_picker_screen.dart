import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/theme/app_styles.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final LatLng initialPosition;
  final String confirmLabel;
  final Color pinColor;

  const LocationPickerScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.initialPosition,
    this.confirmLabel = 'Confirm Location',
    this.pinColor = AppStyles.primaryColor,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late LatLng _pickedLocation;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen draggable map — pin stays fixed in center
          GoogleMap(
            initialCameraPosition:
                CameraPosition(target: widget.initialPosition, zoom: 14),
            onMapCreated: (_) => setState(() => _mapReady = true),
            onCameraMove: (pos) => _pickedLocation = pos.target,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
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
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: Color(0xFF1A1A1A)),
                          onPressed: () => Navigator.of(context).pop(null),
                        ),
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
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
                      color: Colors.white,
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1A1A1A),
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
