import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/passenger/booking_status_screen.dart';
import 'package:testtale3/screens/passenger/location_picker_screen.dart';
import 'package:testtale3/Services/maps_service.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';

// ignore_for_file: use_build_context_synchronously

class SelectSeatScreen extends StatefulWidget {
  final RideModel ride;
  const SelectSeatScreen({super.key, required this.ride});

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  bool _isConfirming = false;
  String? _errorMessage;
  // ignore: prefer_final_fields
  String _rideStatus = 'active';

  bool get _isRideOpen {
    if (_rideStatus != 'active') return false;
    try {
      final departure = DateTime.parse('${widget.ride.date} ${widget.ride.time}:00');
      return DateTime.now().isBefore(departure);
    } catch (_) {
      return false;
    }
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;
  StreamSubscription<List<BookingModel>>? _bookingsSub;
  StreamSubscription<List<BookingModel>>? _pendingBookingsSub;

  // confirmed bookings (accepted by driver)
  List<BookingModel> _confirmedBookings = [];
  // pending booking requests (awaiting driver approval)
  List<BookingModel> _pendingBookings = [];

  // seat index (1-4) → gender string for that seat
  final Map<int, String> _seatGenders = {};        // confirmed seats
  final Map<int, String> _pendingSeatGenders = {}; // pending seats

  String _mapError(String? code, BookingProvider provider) {
    switch (code) {
      case 'already_booked':
        return "You've already booked this ride.";
      case 'not_enough_seats':
        return 'No seats available. Someone may have just booked the last one.';
      case 'permission_denied':
        return 'Booking failed — permission denied. Check Firestore rules.';
      case 'not_logged_in':
        return 'Your session has expired. Please sign out and sign in again.';
      default:
        final raw = provider.rawError;
        if (raw != null && raw.isNotEmpty) return 'Error: $raw';
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BookingProvider>();
      provider.initFromRide(widget.ride);
      _rideSub = FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.ride.id)
          .snapshots()
          .listen((snap) {
        if (!mounted || !snap.exists) return;
        final data = snap.data()!;
        final newStatus = data['status'] as String? ?? 'active';
        if (newStatus != _rideStatus) setState(() => _rideStatus = newStatus);
        final newTotal = (data['totalSeats'] as num?)?.toInt() ?? widget.ride.totalSeats;
        final newBooked = (data['bookedSeats'] as num?)?.toInt() ?? 0;

        // Resolve which seat positions exist for this ride.
        // New rides store explicit indices; legacy rides fall back to sequential.
        final rawIndices = data['seatIndices'] as List<dynamic>?;
        final seatIndices = rawIndices != null && rawIndices.isNotEmpty
            ? rawIndices.map((e) => (e as num).toInt()).toList()
            : List.generate(newTotal, (i) => i + 1);

        // Parse pending genders + seat indices from ride doc.
        // New format: "seatIdx:gender[,seatIdx:gender]" (e.g. "2:female,3:male").
        // Old format fallback: plain gender string assigned sequentially.
        final rawEntries = (data['pendingGenderEntries'] as Map<String, dynamic>?) ?? {};
        final newPendingGenders = <int, String>{};
        final pendingIndices = <int>[];
        int fallbackSeat = newBooked + 1;

        final sorted = rawEntries.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        for (final entry in sorted) {
          final value = entry.value as String? ?? '';
          bool usedIndex = false;
          for (final part in value.split(',')) {
            final colon = part.indexOf(':');
            if (colon > 0) {
              final idx = int.tryParse(part.substring(0, colon).trim());
              final g = part.substring(colon + 1).trim();
              if (idx != null && idx >= 1 && idx <= 4) {
                newPendingGenders[idx] = g;
                pendingIndices.add(idx);
                usedIndex = true;
              }
            }
          }
          if (!usedIndex) {
            // Legacy entries without seat index — assign sequentially.
            for (final g in value.split(',')) {
              if (fallbackSeat <= 4) {
                newPendingGenders[fallbackSeat] = g.trim();
                pendingIndices.add(fallbackSeat);
                fallbackSeat++;
              }
            }
          }
        }

        provider.updateSeatsExact(
          newBooked,
          pendingIndices,
          seatIndices,
          pendingGenders: newPendingGenders,
        );
      });

      // Booking queries are best-effort for gender colours only.
      // Firestore rules may block these for passengers not yet in a booking —
      // onError silently swallows rule violations so the seat map still works.
      _bookingsSub = provider.rideBookingsStream(widget.ride.id).listen((bookings) {
        if (!mounted) return;
        _confirmedBookings = bookings;
        _updateGenders();
      }, onError: (_) {});

      _pendingBookingsSub = provider.ridePendingBookingsStream(widget.ride.id).listen((bookings) {
        if (!mounted) return;
        _pendingBookings = bookings;
        _updateGenders();
      }, onError: (_) {});
    });
  }

  /// Rebuilds gender colour maps from the latest confirmed + pending booking lists.
  /// Seat states are driven by the ride document via [updateAllSeats], not here.
  void _updateGenders() {
    final newConfirmed = <int, String>{};
    int seat = 1;
    int confirmedCount = 0;
    for (final b in _confirmedBookings) {
      confirmedCount += b.seatsBooked;
      final parts = b.passengerGender.split(',');
      for (int i = 0; i < b.seatsBooked; i++) {
        if (seat <= 4) {
          newConfirmed[seat] = i < parts.length ? parts[i].trim() : b.passengerGender;
          seat++;
        }
      }
    }

    final newPending = <int, String>{};
    int pendingSeat = confirmedCount + 1;
    for (final b in _pendingBookings) {
      final parts = b.passengerGender.split(',');
      for (int i = 0; i < b.seatsBooked; i++) {
        if (pendingSeat <= 4) {
          newPending[pendingSeat] = i < parts.length ? parts[i].trim() : b.passengerGender;
          pendingSeat++;
        }
      }
    }

    if (mounted) {
      setState(() {
        _seatGenders..clear()..addAll(newConfirmed);
        _pendingSeatGenders..clear()..addAll(newPending);
      });
    }
  }

  @override
  void dispose() {
    _rideSub?.cancel();
    _bookingsSub?.cancel();
    _pendingBookingsSub?.cancel();
    super.dispose();
  }

  Future<void> _startConfirmFlow() async {
    if (!_isRideOpen) return;
    final provider = context.read<BookingProvider>();

    // Step 0 — passenger specifies gender for each booked seat
    final genders = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _GenderSelectionSheet(
        seatCount: provider.selectedCount,
        ownGender: context.read<AuthProvider>().currentUser?.gender ?? '',
      ),
    );
    if (genders == null || !mounted) return;

    // Step 1 — passenger picks their pickup pin in the origin city
    final origin = MapsService.cityCoords(widget.ride.origin)
        ?? const LatLng(31.9539, 35.9106);
    final LatLng? pickup = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: context.l10n.setPickupLocation,
          instruction: 'Drag map to your pickup point',
          initialPosition: origin,
          confirmLabel: 'Confirm Pickup →',
          showSavedPlaces: true,
        ),
      ),
    );
    if (pickup == null || !mounted) return;

    // Step 2 — passenger picks their drop-off pin in the destination city
    final dest = MapsService.cityCoords(widget.ride.destination)
        ?? const LatLng(31.9539, 35.9106);
    final LatLng? dropoff = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          title: context.l10n.setDropoffLocation,
          instruction: 'Drag map to your drop-off point',
          initialPosition: dest,
          confirmLabel: 'Confirm Booking',
          pinColor: const Color(0xFF2E7D32),
          showSavedPlaces: true,
        ),
      ),
    );
    if (dropoff == null || !mounted) return;

    // Step 3 — show booking summary and wait for passenger confirmation
    final confirmed = await _showBookingSummary(context, provider,
        pickup: pickup, dropoff: dropoff);
    if (!confirmed || !mounted) return;

    // Step 4 — write booking to Firestore with both coordinates
    setState(() { _isConfirming = true; _errorMessage = null; });
    final BookingModel? booking = await provider.confirmBooking(
      pickupLat: pickup.latitude,
      pickupLng: pickup.longitude,
      dropoffLat: dropoff.latitude,
      dropoffLng: dropoff.longitude,
      passengerGender: genders.join(','),
    );
    if (!mounted) return;
    setState(() => _isConfirming = false);

    if (booking == null) {
      setState(() => _errorMessage = _mapError(provider.confirmError, provider));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => BookingStatusScreen(booking: booking)),
    );
  }

  Future<bool> _showBookingSummary(
      BuildContext context, BookingProvider provider,
      {required LatLng pickup, required LatLng dropoff}) async {
    final ride = widget.ride;
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ctx.colors.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // drag handle
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
                'Booking Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: ctx.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              // Route row
              _summaryRow(
                Icons.route_rounded,
                'Route',
                '${ride.origin}  →  ${ride.destination}',
              ),
              _summaryRow(
                Icons.calendar_today_rounded,
                'Date & Time',
                '${ride.date}  •  ${ride.time}',
              ),
              _summaryRow(
                Icons.person_outline_rounded,
                'Driver',
                ride.driverName,
              ),
              _summaryRow(
                Icons.directions_car_rounded,
                'Car',
                ride.carShortInfo,
              ),
              _summaryRow(
                Icons.confirmation_number_outlined,
                'Plate',
                ride.plateNumber,
              ),
              _summaryRow(
                Icons.event_seat_rounded,
                'Seats',
                '${provider.selectedCount}',
              ),
              _summaryRow(
                Icons.my_location_rounded,
                'Your Pickup',
                '${pickup.latitude.toStringAsFixed(5)}, ${pickup.longitude.toStringAsFixed(5)}',
              ),
              _summaryRow(
                Icons.flag_rounded,
                'Your Drop-off',
                '${dropoff.latitude.toStringAsFixed(5)}, ${dropoff.longitude.toStringAsFixed(5)}',
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ctx.colors.textPrimary,
                    ),
                  ),
                  Text(
                    '${provider.totalPrice} JOD',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8B1A2B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ctx.colors.textSecondary,
                        side: BorderSide(color: ctx.colors.borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(context.l10n.cancel,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5C0A1A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Confirm & Book',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
    return result == true;
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8B1A2B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.selectYourSeat,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 24),
                    child: Column(
                      children: [
                        Text(
                          widget.ride.carShortInfo,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.ride.date}  •  ${widget.ride.time}',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Car Layout Visual
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceColor,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                                color: context.colors.borderColor, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSeat(bookingProvider, 0),
                                  _buildSeat(bookingProvider, 1),
                                ],
                              ),
                              const SizedBox(height: 40),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSeat(bookingProvider, 2),
                                  _buildSeat(bookingProvider, 3),
                                  _buildSeat(bookingProvider, 4),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Legend
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 8,
                          children: [
                            _buildLegendItem(
                                const Color(0xFFE0E0E0), context.l10n.available),
                            _buildLegendItem(_primaryColor, context.l10n.selectedLabel,
                                isSelected: true),
                            _buildLegendItem(
                              const Color(0xFFE3F2FD),
                              'Male',
                              iconColor: const Color(0xFF1565C0),
                              icon: Icons.man_rounded,
                            ),
                            _buildLegendItem(
                              const Color(0xFFFCE4EC),
                              'Female',
                              iconColor: const Color(0xFFE91E8C),
                              icon: Icons.woman_rounded,
                            ),
                            _buildLegendItem(
                              const Color(0xFFFFF9C4),
                              'Pending',
                              iconColor: const Color(0xFFFFB300),
                              icon: Icons.hourglass_top_rounded,
                              isBordered: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Summary & Action
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.l10n.selectedSeats,
                                style: TextStyle(
                                    fontSize: 12, color: context.colors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${bookingProvider.selectedCount}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                context.l10n.totalPrice,
                                style: TextStyle(
                                    fontSize: 12, color: context.colors.textSecondary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${bookingProvider.totalPrice} JOD',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: _primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: context.colors.errorLightBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFFFCDD2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  color: Color(0xFFB71C1C), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFB71C1C),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (!_isRideOpen) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 16),
                          decoration: BoxDecoration(
                            color: context.colors.pendingLightBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFFB300)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.lock_clock_rounded,
                                  color: Color(0xFFE65100), size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _rideStatus == 'in_progress'
                                      ? 'This ride has already started.'
                                      : 'Booking is closed — departure time has passed.',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFE65100),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_isConfirming ||
                                  bookingProvider.selectedCount == 0 ||
                                  !_isRideOpen)
                              ? null
                              : _startConfirmFlow,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkMaroon,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color(0xFFBDBDBD),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isConfirming
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  context.l10n.confirmSeatSelection,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeat(BookingProvider provider, int index) {
    final state = provider.seatStates[index] ?? 0;

    // ── Driver seat ──────────────────────────────────────────────────────────
    if (state == 3) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.drive_eta, color: Color(0xFF9FA8DA), size: 24),
        ),
      );
    }

    // ── Non-existent seat ────────────────────────────────────────────────────
    if (state == 4) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colors.borderColor),
        ),
        child: const Center(
          child: Icon(Icons.block, color: Color(0xFFCCCCCC), size: 18),
        ),
      );
    }

    // ── Pending request seat ─────────────────────────────────────────────────
    if (state == 5) {
      final gender = provider.pendingGenders[index];
      Color bgColor;
      Color borderColor;
      IconData icon;
      if (gender != null) {
        final g = gender.toLowerCase();
        if (g == 'female' || g == 'أنثى') {
          bgColor = const Color(0xFFFCE4EC);
          borderColor = const Color(0xFFE91E8C);
          icon = Icons.woman_rounded;
        } else {
          bgColor = const Color(0xFFE3F2FD);
          borderColor = const Color(0xFF1565C0);
          icon = Icons.man_rounded;
        }
      } else {
        bgColor = const Color(0xFFFFF9C4);
        borderColor = const Color(0xFFFFB300);
        icon = Icons.person;
      }
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1.5),
        ),
        child: Center(
          child: Icon(icon, color: borderColor.withValues(alpha: 0.7), size: 24),
        ),
      );
    }

    // ── Confirmed / available / selected seats ───────────────────────────────
    final gender = state == 2 ? _seatGenders[index] : null;

    Color bgColor;
    Color iconColor;
    if (state == 1) {
      bgColor = _primaryColor;
      iconColor = Colors.white;
    } else if (state == 2) {
      if (gender != null) {
        final g = gender.toLowerCase();
        if (g == 'female' || g == 'أنثى') {
          bgColor = const Color(0xFFFCE4EC);
          iconColor = const Color(0xFFE91E8C);
        } else if (g == 'male' || g == 'ذكر') {
          bgColor = const Color(0xFFE3F2FD);
          iconColor = const Color(0xFF1565C0);
        } else {
          bgColor = const Color(0xFFBDBDBD);
          iconColor = Colors.white;
        }
      } else {
        bgColor = const Color(0xFFBDBDBD);
        iconColor = Colors.white;
      }
    } else {
      bgColor = context.colors.cardBackgroundColor;
      iconColor = const Color(0xFFBDBDBD);
    }

    IconData genderIcon;
    if (state == 2 && gender != null) {
      final g = gender.toLowerCase();
      if (g == 'female' || g == 'أنثى') {
        genderIcon = Icons.woman_rounded;
      } else if (g == 'male' || g == 'ذكر') {
        genderIcon = Icons.man_rounded;
      } else {
        genderIcon = Icons.person;
      }
    } else {
      genderIcon = Icons.person;
    }

    return GestureDetector(
      onTap: state == 2 ? null : () => provider.toggleSeat(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: state == 0 ? Border.all(color: context.colors.borderColor) : null,
        ),
        child: Center(child: Icon(genderIcon, color: iconColor, size: 24)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool isSelected = false, bool isBordered = false, Color iconColor = Colors.transparent, IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isBordered ? 0.4 : 1.0),
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? null
                : isBordered
                    ? Border.all(color: iconColor.withValues(alpha: 0.6), width: 1.5)
                    : Border.all(color: context.colors.borderColor),
          ),
          child: iconColor != Colors.transparent
              ? Icon(icon ?? Icons.person, size: 10, color: iconColor.withValues(alpha: isBordered ? 0.7 : 1.0))
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Gender selection sheet — shown before location picker
// ─────────────────────────────────────────────────────────────────────────────
class _GenderSelectionSheet extends StatefulWidget {
  final int seatCount;
  final String ownGender;
  const _GenderSelectionSheet({required this.seatCount, required this.ownGender});

  @override
  State<_GenderSelectionSheet> createState() => _GenderSelectionSheetState();
}

class _GenderSelectionSheetState extends State<_GenderSelectionSheet> {
  static const Color _primary = Color(0xFF8B1A2B);
  static const Color _female = Color(0xFFE91E8C);
  static const Color _male = Color(0xFF1565C0);

  late List<String> _genders;

  @override
  void initState() {
    super.initState();
    final g = widget.ownGender.toLowerCase();
    final defaultGender = (g == 'female' || g == 'أنثى') ? 'female' : 'male';
    _genders = List.generate(widget.seatCount, (_) => defaultGender);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Who's joining?",
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Select the gender for each seat so the driver knows who to expect.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          const SizedBox(height: 24),

          ...List.generate(widget.seatCount, (i) {
            final isYou = i == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  // Seat label
                  Container(
                    width: 80,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    decoration: BoxDecoration(
                      color: context.colors.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isYou ? 'You' : 'Seat ${i + 1}',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Male toggle
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _genders[i] = 'male'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _genders[i] == 'male'
                              ? _male.withValues(alpha: 0.12)
                              : context.colors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _genders[i] == 'male' ? _male : context.colors.borderColor,
                            width: _genders[i] == 'male' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.man_rounded,
                                color: _genders[i] == 'male' ? _male : const Color(0xFFBDBDBD),
                                size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Male',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _genders[i] == 'male' ? _male : context.colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Female toggle
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _genders[i] = 'female'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _genders[i] == 'female'
                              ? _female.withValues(alpha: 0.12)
                              : context.colors.cardBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _genders[i] == 'female' ? _female : context.colors.borderColor,
                            width: _genders[i] == 'female' ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.woman_rounded,
                                color: _genders[i] == 'female' ? _female : const Color(0xFFBDBDBD),
                                size: 20),
                            const SizedBox(width: 4),
                            Text(
                              'Female',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _genders[i] == 'female' ? _female : context.colors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_genders),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
