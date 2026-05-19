import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/booking_model.dart';
import 'package:testtale3/providers/navigation_provider.dart';
import 'package:testtale3/providers/rating_provider.dart';
import 'package:testtale3/screens/passenger/cancel_trip_screen.dart';
import 'package:testtale3/screens/passenger/passenger_home_screen.dart';
import 'package:testtale3/screens/passenger/passenger_live_ride_screen.dart';
import 'package:testtale3/screens/passenger/rate_driver_screen.dart';
import 'package:testtale3/screens/shared/conversation_screen.dart';
import 'package:testtale3/screens/shared/route_map_widget.dart';
import 'package:testtale3/l10n/app_localizations.dart';

// ignore_for_file: use_build_context_synchronously

class BookingStatusScreen extends StatefulWidget {
  final BookingModel booking;
  const BookingStatusScreen({super.key, required this.booking});

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);

  late BookingModel _booking;
  String _rideStatus = 'active';

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _bookingSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _rideSub;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;

    _bookingSub = FirebaseFirestore.instance
        .collection('bookings')
        .doc(widget.booking.id)
        .snapshots()
        .listen((snap) {
      if (!mounted || !snap.exists) return;
      setState(() => _booking = BookingModel.fromDoc(snap));
    });

    _rideSub = FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.booking.rideId)
        .snapshots()
        .listen((snap) {
      if (!mounted || !snap.exists) return;
      final status = snap.data()?['status'] as String? ?? 'active';
      setState(() => _rideStatus = status);
    });
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    _rideSub?.cancel();
    super.dispose();
  }

  bool get _isPending => _booking.status == 'pending';
  bool get _isRejected => _booking.status == 'rejected';
  bool get _isCompleted => _booking.status == 'completed';

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PassengerHomeScreen()),
      (route) => false,
    );
  }

  bool get _isPast {
    try {
      final d = DateTime.parse(_booking.date);
      final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return d.isBefore(today);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRideLive = _rideStatus == 'live' && _booking.status == 'confirmed';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) => _goHome(),
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: _goHome,
        ),
        title: Text(
          context.l10n.bookingStatus,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
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
              // Driver arrived banner — shown when driver taps "I've Arrived" for this passenger
              if (_booking.driverArrivedAt != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF81C784)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_car_rounded,
                          color: Color(0xFF2E7D32), size: 22),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your driver has arrived!',
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Head to your pickup point — your driver is waiting.',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Status icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: (_isPending
                          ? const Color(0xFFF57F17)
                          : _isRejected
                              ? const Color(0xFFB71C1C)
                              : _isCompleted
                                  ? const Color(0xFF2E7D32)
                                  : isRideLive
                                      ? const Color(0xFFE53935)
                                      : _primaryColor)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _isPending
                          ? const Color(0xFFF57F17)
                          : _isRejected
                              ? const Color(0xFFB71C1C)
                              : _isCompleted
                                  ? const Color(0xFF2E7D32)
                                  : isRideLive
                                      ? const Color(0xFFE53935)
                                      : _primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPending
                          ? Icons.hourglass_top_rounded
                          : _isRejected
                              ? Icons.close_rounded
                              : _isCompleted
                                  ? Icons.flag_rounded
                                  : isRideLive
                                      ? Icons.directions_car_rounded
                                      : Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _isPending
                    ? 'Awaiting Driver Approval'
                    : _isRejected
                        ? 'Request Rejected'
                        : _isCompleted
                            ? 'Ride Completed'
                            : isRideLive
                                ? 'Your Ride is Live!'
                                : context.l10n.bookingConfirmed,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isPending
                    ? 'Your request has been sent. The driver will review and confirm shortly.'
                    : _isRejected
                        ? 'The driver could not accommodate your pickup location. You can search for another ride.'
                        : _isCompleted
                            ? 'Thanks for travelling with Tale3! Don\'t forget to rate your driver.'
                            : isRideLive
                                ? 'Your driver has started the ride. Tap the button below to track it.'
                                : context.l10n.bookingConfirmedDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Trip details card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.tripDetails,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9E9E9E),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      Icons.location_on,
                      '${_booking.origin} → ${_booking.destination}',
                    ),
                    const Divider(height: 24),
                    _detailRow(
                      Icons.calendar_today,
                      '${_booking.date}  •  ${_booking.time}',
                    ),
                    const Divider(height: 24),
                    _detailRow(
                      Icons.directions_car,
                      '${_booking.carInfo}\nPlate: ${_booking.plateNumber}',
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.event_seat, color: _primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${_booking.seatsBooked} Seat${_booking.seatsBooked > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDF2F4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${_booking.totalPrice} JOD',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Route map
              RouteMapWidget(
                origin: _booking.origin,
                destination: _booking.destination,
                height: 180,
              ),

              const SizedBox(height: 24),

              // Rate driver — shown for completed rides
              if (_isCompleted)
                StreamBuilder<bool>(
                  stream: context
                      .read<RatingProvider>()
                      .hasRatedBooking(_booking.id),
                  builder: (context, snap) {
                    final alreadyRated = snap.data ?? false;
                    if (alreadyRated) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9F6E0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE8C94F)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Color(0xFFE8A800), size: 18),
                            SizedBox(width: 8),
                            Text('You rated this ride',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF7A5A00))),
                          ],
                        ),
                      );
                    }
                    return SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RateDriverScreen(booking: _booking),
                          ),
                        ),
                        icon: const Icon(Icons.star_rounded, size: 20),
                        label: const Text('Rate Your Driver',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE8A800),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    );
                  },
                ),
              if (_isCompleted) const SizedBox(height: 8),

              // Track Live Ride button
              if (isRideLive) ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PassengerLiveRideScreen(booking: _booking),
                    )),
                    icon: const Icon(Icons.my_location_rounded, size: 20),
                    label: const Text('Track Live Ride',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 8),

              // View My Trips button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<NavigationProvider>().setPassengerTab(1);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const PassengerHomeScreen()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.myTrips,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        otherUserId: _booking.driverId,
                        otherUserName: _booking.driverName,
                      ),
                    ));
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text(
                    'Message Driver',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primaryColor,
                    side: const BorderSide(color: _primaryColor, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (!_isPast && !_isRejected && !_isCompleted) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CancelTripScreen(booking: _booking),
                      ));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: const BorderSide(color: _primaryColor, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _isPending ? 'Withdraw Request' : context.l10n.cancelRide,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ],
    );
  }
}
