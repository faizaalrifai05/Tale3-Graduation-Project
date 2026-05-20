import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/rating_provider.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/screens/shared/report_screen.dart';

// ignore_for_file: use_build_context_synchronously

class RateDriverScreen extends StatefulWidget {
  final BookingModel booking;
  const RateDriverScreen({super.key, required this.booking});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  int _stars = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final err = await context.read<RatingProvider>().submitRating(
          driverId: widget.booking.driverId,
          rideId: widget.booking.rideId,
          bookingId: widget.booking.id,
          stars: _stars,
          comment: _commentController.text.trim(),
        );
    setState(() => _submitting = false);
    if (err != null && err != 'already_rated') {
      setState(() => _error = err);
      return;
    }
    if (mounted) Navigator.of(context).pop(true);
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
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: Text(
          'Rate Your Driver',
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
            children: [

              // ── Driver avatar ──────────────────────────────────
              CircleAvatar(
                radius: 40,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  widget.booking.driverName.isNotEmpty
                      ? widget.booking.driverName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.booking.driverName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                '${widget.booking.origin} → ${widget.booking.destination}',
                style: TextStyle(
                    fontSize: 13, color: context.colors.textSecondary),
              ),
              const SizedBox(height: 32),

              // ── How was your ride ──────────────────────────────
              Text(
                'How was your ride?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // ── Stars ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  return GestureDetector(
                    onTap: () => setState(() => _stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        i < _stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: AppStyles.goldStar,
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _starLabel(_stars),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppStyles.primaryColor,
                ),
              ),
              const SizedBox(height: 28),

              // ── Comment ───────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: context.colors.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.borderColor),
                ),
                child: TextField(
                  controller: _commentController,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Leave a comment (optional)…',
                    hintStyle: TextStyle(
                        color: context.colors.textTertiary, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Error ─────────────────────────────────────────
              if (_error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F0),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Color(0xFFB71C1C), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(
                                fontSize: 13, color: Color(0xFFB71C1C))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Submit Rating ─────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Submit Rating',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 12),

              // ── Skip ──────────────────────────────────────────
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                      color: context.colors.textSecondary, fontSize: 14),
                ),
              ),

              const SizedBox(height: 24),

              // ── Divider ───────────────────────────────────────
              Row(
                children: [
                  Expanded(
                      child: Divider(color: context.colors.borderColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Had a problem?',
                      style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textTertiary),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: context.colors.borderColor)),
                ],
              ),
              const SizedBox(height: 16),

              // ── Report Driver button ───────────────────────────
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(
                          reportedUserId: widget.booking.driverId,
                          reportedUserName: widget.booking.driverName,
                          reportedUserRole: 'driver',
                          rideId: widget.booking.rideId,
                          origin: widget.booking.origin,
                          destination: widget.booking.destination,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flag_outlined,
                      size: 18, color: Colors.red),
                  label: const Text(
                    'Report Driver',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                        color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
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

  String _starLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      default:
        return 'Excellent!';
    }
  }
}