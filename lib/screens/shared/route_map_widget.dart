import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/theme/app_styles.dart';

class RouteMapWidget extends StatefulWidget {
  final String origin;
  final String destination;
  final double height;

  const RouteMapWidget({
    super.key,
    required this.origin,
    required this.destination,
    this.height = 200,
  });

  @override
  State<RouteMapWidget> createState() => _RouteMapWidgetState();
}

class _RouteMapWidgetState extends State<RouteMapWidget> {
  GoogleMapController? _controller;
  List<LatLng> _points = [];
  bool _loading = true;

  static const LatLng _fallback = LatLng(31.9539, 35.9106);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final pts = await MapsService.getRoute(widget.origin, widget.destination);
    if (mounted) setState(() { _points = pts; _loading = false; });
  }

  void _onMapCreated(GoogleMapController c) async {
    _controller = c;
    if (_points.isEmpty) return;
    final bounds = await MapsService.getBounds(widget.origin, widget.destination);
    if (bounds != null && mounted) {
      _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 48));
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: _loading
            ? Container(
                color: AppStyles.successLightBg,
                child: const Center(child: CircularProgressIndicator()),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _points.isNotEmpty ? _points.first : _fallback,
                  zoom: 10,
                ),
                onMapCreated: _onMapCreated,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                zoomGesturesEnabled: false,
                markers: {
                  if (_points.isNotEmpty) ...[
                    Marker(
                      markerId: const MarkerId('origin'),
                      position: _points.first,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed),
                      infoWindow: InfoWindow(title: widget.origin),
                    ),
                    Marker(
                      markerId: const MarkerId('destination'),
                      position: _points.last,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(title: widget.destination),
                    ),
                  ],
                },
                polylines: {
                  if (_points.isNotEmpty)
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: _points,
                      color: AppStyles.primaryColor,
                      width: 4,
                    ),
                },
              ),
      ),
    );
  }
}
