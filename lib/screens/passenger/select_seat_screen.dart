import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/passenger/booking_status_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

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
  double? _pickupLat;
  double? _pickupLng;

  // seatIndex (1-4) → gender of whoever booked it (assigned in booking order)
  Map<int, String> _seatGenders = {};
  StreamSubscription<List<BookingModel>>? _bookingSub;

  String _mapError(String? code) {
    switch (code) {
      case 'already_booked':
        return "You've already booked this ride.";
      case 'not_enough_seats':
        return 'No seats available. Someone may have just booked the last one.';
      case 'permission_denied':
        return 'Booking failed — please make sure you are logged in and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<BookingProvider>();
      provider.initFromRide(widget.ride);
      _bookingSub = provider.rideBookingsStream(widget.ride.id).listen((bookings) {
        if (!mounted) return;
        final sorted = [...bookings]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        final map = <int, String>{};
        for (int i = 0; i < sorted.length && i < 4; i++) {
          map[i + 1] = sorted[i].passengerGender;
        }
        provider.updateOccupiedSeats(sorted.length, widget.ride.totalSeats);
        setState(() => _seatGenders = map);
      });
    });
    _fetchLocation();
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );
      if (!mounted) return;
      setState(() {
        _pickupLat = pos.latitude;
        _pickupLng = pos.longitude;
      });
    } catch (_) {}
  }

  Future<void> _confirm() async {
    setState(() => _isConfirming = true);
    final BookingModel? booking =
        await context.read<BookingProvider>().confirmBooking(
              pickupLat: _pickupLat,
              pickupLng: _pickupLng,
            );
    setState(() => _isConfirming = false);

    if (booking == null) {
      final code = context.read<BookingProvider>().confirmError;
      setState(() => _errorMessage = _mapError(code));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingStatusScreen(booking: booking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.selectYourSeat,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
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
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.ride.date}  •  ${widget.ride.time}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF757575),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Car Layout Visual
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                                color: const Color(0xFFEEEEEE), width: 3),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildLegendItem(
                                const Color(0xFFE0E0E0), context.l10n.available),
                            const SizedBox(width: 16),
                            _buildLegendItem(_primaryColor, context.l10n.selectedLabel,
                                isSelected: true),
                            const SizedBox(width: 16),
                            _buildLegendItem(const Color(0xFFBDBDBD),
                                context.l10n.occupied,
                                iconColor: Colors.white),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Summary & Action
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 10,
                        offset: Offset(0, -5),
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
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF757575)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${bookingProvider.selectedCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                context.l10n.totalPrice,
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF757575)),
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
                            color: const Color(0xFFFFF0F0),
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
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_isConfirming ||
                                  bookingProvider.selectedCount == 0)
                              ? null
                              : () {
                                  setState(() => _errorMessage = null);
                                  _confirm();
                                },
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

    Color bgColor;
    Color iconColor;
    if (state == 1) {
      bgColor = _primaryColor;
      iconColor = Colors.white;
    } else if (state == 2) {
      bgColor = const Color(0xFFE0E0E0);
      iconColor = Colors.white;
    } else {
      bgColor = const Color(0xFFF5F5F5);
      iconColor = const Color(0xFFBDBDBD);
    }

    final gender = state == 2 ? (_seatGenders[index] ?? '') : '';
    final genderIcon = gender.toLowerCase() == 'female' || gender.toLowerCase() == 'أنثى'
        ? Icons.female
        : gender.toLowerCase() == 'male' || gender.toLowerCase() == 'ذكر'
            ? Icons.male
            : Icons.person;

    return GestureDetector(
      onTap: () => provider.toggleSeat(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border:
              state == 0 ? Border.all(color: const Color(0xFFE0E0E0)) : null,
        ),
        child: Center(child: Icon(genderIcon, color: iconColor, size: 24)),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label,
      {bool isSelected = false, Color iconColor = Colors.transparent}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: iconColor != Colors.transparent
              ? Icon(Icons.person, size: 10, color: iconColor)
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
