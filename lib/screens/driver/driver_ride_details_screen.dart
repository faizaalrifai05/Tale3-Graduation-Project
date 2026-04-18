import 'package:flutter/services.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/driver/driver_ride_live_screen.dart';

class DriverRideDetailsScreen extends StatelessWidget {
  const DriverRideDetailsScreen({super.key});

  void _showShareSheet(BuildContext context) {
    const shareText =
        'Check out this ride on Tale3!\n🚗 From → To • Today at 14:30\nBook now on Tale3 — the trusted carpool app.';
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
                width: 40, height: 4,
                decoration: BoxDecoration(color: ctx.colors.borderColor, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Share Ride', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: ctx.colors.textPrimary)),
            const SizedBox(height: 8),
            Text(shareText, style: TextStyle(fontSize: 14, color: ctx.colors.textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copy Ride Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: shareText));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Ride details copied to clipboard'),
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
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              color: context.colors.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Ride Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.share, color: AppStyles.primaryColor, size: 18),
                      onPressed: () => _showShareSheet(context),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable body ──────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // ── Map placeholder ──────────────────────────────────────
                    _MapSection(),
                    const SizedBox(height: 8),

                    // ── Route timeline ───────────────────────────────────────
                    _RouteSection(),
                    const SizedBox(height: 8),

                    // ── Info cards (date / seats / price) ────────────────────
                    Container(
                      color: context.colors.surfaceColor,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          _buildInfoCard(context, Icons.calendar_today_rounded,
                              'DATE & TIME', 'Today\n14:30'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.event_seat_rounded,
                              'SEATS LEFT', '3 / 4'),
                          const SizedBox(width: 12),
                          _buildInfoCard(context, Icons.payments_outlined,
                              'PRICE', '\$15.00',
                              isPrice: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── Passengers ───────────────────────────────────────────
                    _PassengersSection(),
                    const SizedBox(height: 8),

                    // ── Rules & preferences ──────────────────────────────────
                    _RulesSection(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── Bottom action bar ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surfaceColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const DriverRideLiveScreen()),
                    );
                  },
                  icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
                  label: Text(
                    'Start Ride',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String label,
      String value, {bool isPrice = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppStyles.primaryColor, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: context.colors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPrice ? AppStyles.primaryColor : context.colors.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAP SECTION — stylised route map placeholder
// ─────────────────────────────────────────────────────────────────────────────
class _MapSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 180,
          width: double.infinity,
          child: Stack(
            children: [
              // Tinted map background
              Container(color: AppStyles.successLightBg),

              // Decorative road lines
              CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _RoutePainter(color: AppStyles.primaryColor),
              ),

              // Origin pin
              Positioned(
                left: 48,
                top: 32,
                child: _MapPin(
                  label: 'Pickup',
                  color: AppStyles.primaryColor,
                  icon: Icons.radio_button_checked,
                ),
              ),

              // Destination pin
              Positioned(
                right: 48,
                bottom: 32,
                child: _MapPin(
                  label: 'Drop-off',
                  color: AppStyles.successDarkText,
                  icon: Icons.location_on,
                ),
              ),

              // Distance badge
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route_rounded,
                          size: 13, color: AppStyles.primaryColor),
                      const SizedBox(width: 4),
                      Text(
                        '12.4 km · 15 min',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _MapPin({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: context.colors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
            ],
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
        const SizedBox(height: 3),
        Icon(icon, color: color, size: 22),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final Color color;
  const _RoutePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..cubicTo(
        size.width * 0.35, size.height * 0.15,
        size.width * 0.55, size.height * 0.75,
        size.width * 0.85, size.height * 0.72,
      );

    // Draw dashed path
    const dashLen = 10.0;
    const gapLen = 6.0;
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashLen).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        distance += dashLen + gapLen;
      }
    }

    // Draw dots at endpoints
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(size.width * 0.15, size.height * 0.25), 5, dotPaint);
    canvas.drawCircle(
        Offset(size.width * 0.85, size.height * 0.72), 5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
//  ROUTE SECTION — origin → dropoffs → destination timeline
// ─────────────────────────────────────────────────────────────────────────────
class _RouteSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ROUTE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _routeStop(
            context,
            icon: Icons.radio_button_checked,
            iconColor: AppStyles.primaryColor,
            label: 'Pickup',
            address: 'Downtown Dubai, Sheikh Mohammed Blvd',
            isLast: false,
          ),
          _routeStop(
            context,
            icon: Icons.arrow_downward_rounded,
            iconColor: context.colors.textTertiary,
            label: 'Drop-off 1',
            address: 'Business Bay Metro Station',
            isLast: false,
            isDim: true,
          ),
          _routeStop(
            context,
            icon: Icons.location_on_rounded,
            iconColor: AppStyles.successDarkText,
            label: 'Final destination',
            address: 'Dubai Marina Walk, JBR',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _routeStop(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String address,
    required bool isLast,
    bool isDim = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon + connecting line
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDim
                    ? context.colors.cardBackgroundColor
                    : iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 16,
                  color: isDim ? context.colors.textTertiary : iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.borderColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDim ? context.colors.textSecondary : context.colors.textPrimary,
                  ),
                ),
                if (!isLast) const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  PASSENGERS SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _PassengersSection extends StatelessWidget {
  static const _passengers = [
    ('Sarah J.', 'Seat 1', true),
    ('Thomas K.', 'Seat 2', false),
    ('Aisha M.', 'Seat 3', true),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PASSENGERS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textTertiary,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppStyles.successLightBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_passengers.length} booked',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.successDarkText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._passengers.map((p) => _PassengerRow(
                name: p.$1,
                seat: p.$2,
                isOnline: p.$3,
              )),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  final String name;
  final String seat;
  final bool isOnline;
  const _PassengerRow(
      {required this.name, required this.seat, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  name[0],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              if (isOnline)
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppStyles.successColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: context.colors.surfaceColor, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  seat,
                  style: TextStyle(
                      fontSize: 12, color: context.colors.textSecondary),
                ),
              ],
            ),
          ),
          // Rating badge
          Row(
            children: [
              Icon(Icons.star_rounded,
                  size: 13, color: AppStyles.starRatingColor),
              const SizedBox(width: 3),
              Text(
                '4.8',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textSecondary),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.colors.highlightBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.chat_bubble_outline_rounded,
                size: 16, color: AppStyles.primaryColor),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RULES SECTION
// ─────────────────────────────────────────────────────────────────────────────
class _RulesSection extends StatelessWidget {
  static const _rules = [
    (Icons.ac_unit_rounded, 'Air conditioning', true),
    (Icons.luggage_rounded, 'Luggage space available', true),
    (Icons.smoke_free_rounded, 'No smoking', true),
    (Icons.pets_rounded, 'No pets', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.all(20),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RIDE PREFERENCES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _rules.map((r) {
              final (icon, label, enabled) = r;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppStyles.successLightBg
                      : context.colors.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: enabled
                        ? AppStyles.successColor.withValues(alpha: 0.3)
                        : context.colors.borderColor,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: enabled
                          ? AppStyles.successDarkText
                          : context.colors.textTertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: enabled
                            ? AppStyles.successDarkText
                            : context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
