import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';
import 'package:testtale3/theme/app_styles.dart';


class RidePostedScreen extends StatefulWidget {
  final String origin;
  final String destination;

  const RidePostedScreen({
    super.key,
    required this.origin,
    required this.destination,
  });

  @override
  State<RidePostedScreen> createState() => _RidePostedScreenState();
}

class _RidePostedScreenState extends State<RidePostedScreen> with SingleTickerProviderStateMixin {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showShareSheet(BuildContext context) {
    final shareText =
        'Check out this ride on Tale3!\n🚗 ${widget.origin} → ${widget.destination}\nBook now on Tale3 — the trusted carpool app.';
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.colors.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              ctx.l10n.shareRide,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ctx.colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              shareText,
              style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: Text(
                  ctx.l10n.copyRideDetails,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: shareText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(context.l10n.rideCopied),
                    backgroundColor: AppStyles.successColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.darkMaroon,
                  foregroundColor: AppStyles.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        title: Text(
          context.l10n.ridePosted,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radar Design
              SizedBox(
                height: 200,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ScaleTransition(
                        scale: _animation,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _primaryColor.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryColor.withValues(alpha: 0.2),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primaryColor,
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Status Text
              Text(
                context.l10n.rideIsLive,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.matchingPassengers,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              // Route Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.highlightBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.route, color: _primaryColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.departure,
                          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.origin.isEmpty ? 'Origin' : widget.origin,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, color: context.colors.textTertiary, size: 16),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.destination,
                          style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.destination.isEmpty ? 'Destination' : widget.destination,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _showShareSheet(context),
                  icon: const Icon(Icons.share, size: 20),
                  label: Text(
                    context.l10n.shareTrip,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const DriverHomeScreen()),
                      (route) => false,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.colors.textPrimary,
                    backgroundColor: context.colors.cardBackgroundColor,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    context.l10n.goToDashboard,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}


