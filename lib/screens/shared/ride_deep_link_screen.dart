import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/screens/passenger/ride_details_screen.dart';
import 'package:testtale3/screens/driver/driver_ride_details_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';

/// Landing screen when the app is opened via a tale3://ride/{rideId} link.
/// Fetches the ride and forwards to the correct details screen.
class RideDeepLinkScreen extends StatefulWidget {
  final String rideId;
  const RideDeepLinkScreen({super.key, required this.rideId});

  @override
  State<RideDeepLinkScreen> createState() => _RideDeepLinkScreenState();
}

class _RideDeepLinkScreenState extends State<RideDeepLinkScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ride =
        await context.read<RideProvider>().getRideById(widget.rideId);
    if (!mounted) return;
    if (ride == null) {
      _showError('Ride not found or no longer available.');
      return;
    }
    _navigate(ride);
  }

  void _navigate(RideModel ride) {
    final user = context.read<AuthProvider>().currentUser;
    final isDriver = user?.role == UserRole.driver &&
        user?.uid == ride.driverId;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isDriver
            ? DriverRideDetailsScreen(ride: ride)
            : RideDetailsScreen(ride: ride),
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.linkUnavailable,
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text(context.l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppStyles.primaryColor),
            const SizedBox(height: 16),
            Text('Loading ride…',
                style: TextStyle(color: context.colors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
