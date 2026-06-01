import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:testtale3/screens/passenger/rate_driver_screen.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/ride_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/rating_provider.dart';
import '../../models/ride_model.dart';
import '../../models/booking_model.dart';
import 'package:testtale3/screens/passenger/ride_results_screen.dart';
import 'package:testtale3/screens/passenger/ride_details_screen.dart';
import 'package:testtale3/screens/passenger/my_trips_screen.dart';
import 'package:testtale3/screens/passenger/passenger_chat_screen.dart';
import 'package:testtale3/screens/passenger/passenger_profile_screen.dart';
import 'package:testtale3/screens/community_guidelines_screen.dart';
import 'package:testtale3/providers/saved_places_provider.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  StreamSubscription<QuerySnapshot>? _completedBookingsSub;
  final Set<String> _seenCompletedBookings = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<app_auth.AuthProvider>().addListener(_checkIfBlocked);
      await _subscribeToCompletedBookings();
    });
  }

  @override
  void dispose() {
    context.read<app_auth.AuthProvider>().removeListener(_checkIfBlocked);
    _completedBookingsSub?.cancel();
    super.dispose();
  }

  /// Sets up a real-time listener that triggers the rating prompt ONLY when a
  /// booking transitions to 'completed' during the current app session.
  ///
  /// The fix for the premature-popup bug:
  ///   Firestore's onSnapshot always fires ALL matching documents as
  ///   DocumentChangeType.added on the very first emission, regardless of
  ///   whether they existed before the listener was attached. This caused the
  ///   rating dialog to appear on every app launch for any past unrated ride.
  ///
  ///   The solution is a two-phase start:
  ///   1. Fetch all already-completed booking IDs and pre-populate
  ///      _seenCompletedBookings BEFORE the listener is attached.
  ///   2. Only then attach the snapshot listener. Any document that arrives
  ///      as DocumentChangeType.added from this point forward is genuinely new
  ///      (i.e. it just transitioned to 'completed' in this session).
  Future<void> _subscribeToCompletedBookings() async {
    final uid = context.read<app_auth.AuthProvider>().currentUser?.uid;
    if (uid == null) return;

    // Phase 1 — snapshot all existing completed bookings so we can ignore them.
    try {
      final existing = await FirebaseFirestore.instance
          .collection('bookings')
          .where('passengerId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .get();
      for (final doc in existing.docs) {
        _seenCompletedBookings.add(doc.id);
      }
    } catch (e) {
      debugPrint('_subscribeToCompletedBookings pre-fetch error: $e');
    }

    if (!mounted) return;

    // Phase 2 — now attach the live listener. Every DocumentChangeType.added
    // that arrives from here on is a booking that JUST became completed.
    _completedBookingsSub = FirebaseFirestore.instance
        .collection('bookings')
        .where('passengerId', isEqualTo: uid)
        .where('status', isEqualTo: 'completed')
        .snapshots()
        .listen((snap) {
      for (final change in snap.docChanges) {
        if (change.type == DocumentChangeType.added &&
            !_seenCompletedBookings.contains(change.doc.id)) {
          _seenCompletedBookings.add(change.doc.id);
          _promptRating(BookingModel.fromDoc(change.doc));
        }
      }
    });
  }

  Future<void> _promptRating(BookingModel booking) async {
    final uid = context.read<app_auth.AuthProvider>().currentUser?.uid;
    if (uid == null) return;
    final existing = await FirebaseFirestore.instance
        .collection('ratings')
        .where('bookingId', isEqualTo: booking.id)
        .where('passengerId', isEqualTo: uid)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RateDriverScreen(booking: booking)),
    );
  }

  void _checkIfBlocked() {
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isLoggedIn && auth.wasBlocked) {
      auth.clearBlockedFlag();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.block_rounded, color: Colors.red, size: 26),
              const SizedBox(width: 10),
              Text(context.l10n.accountBlocked,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Text(
            context.l10n.accountBlockedDesc,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const CommunityGuidelinesScreen()),
                  (route) => false,
                );
              },
              child: Text(context.l10n.ok,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.red)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final isOnHomeTab = navProvider.passengerTabIndex == 0;

    return PopScope(
      canPop: isOnHomeTab,
      onPopInvoked: (didPop) {
        if (!didPop) navProvider.setPassengerTab(0);
      },
      child: Scaffold(
        backgroundColor: context.colors.backgroundColor,
        body: IndexedStack(
          index: navProvider.passengerTabIndex,
          children: const [
            _HomeTab(),
            MyTripsScreen(),
            PassengerChatScreen(),
            PassengerProfileScreen(),
          ],
        ),
        bottomNavigationBar: StreamBuilder<int>(
          stream: context.read<ChatProvider>().totalUnreadStream,
          builder: (context, snap) {
            return AppBottomNavBar(
              currentIndex: navProvider.passengerTabIndex,
              onTap: (index) =>
                  context.read<NavigationProvider>().setPassengerTab(index),
              unreadCount: snap.data ?? 0,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home_outlined),
                  activeIcon: const Icon(Icons.home),
                  label: context.l10n.home.toUpperCase(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.history_outlined),
                  activeIcon: const Icon(Icons.history),
                  label: context.l10n.myTrips.toUpperCase(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.chat_bubble_outline),
                  activeIcon: const Icon(Icons.chat_bubble),
                  label: context.l10n.chat.toUpperCase(),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: context.l10n.profile.toUpperCase(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Home Tab ────────────────────────────────────────────────────────────────

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  String? _pickupLabel;
  String? _destinationLabel;

  DateTime? _selectedDate;
  int _seats = 1;

  late Stream<List<RideModel>> _availableRidesStream;

  static const _cities = [
    'Amman', 'Irbid', 'Zarqa', 'Aqaba', 'Mafraq',
    'Salt', 'Madaba', 'Karak', 'Tafilah', 'Maan',
    'Jerash', 'Ajloun', 'Ramtha', 'Russeifa', 'Petra', 'Azraq',
  ];

  @override
  void initState() {
    super.initState();
    _availableRidesStream = context.read<RideProvider>().availableRidesStream;
  }

  void _pickCity({required bool isPickup}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.85,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isPickup ? 'Select Pickup City' : 'Select Destination City',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: context.colors.borderColor),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: _cities.length,
                separatorBuilder: (context, i) =>
                    Divider(height: 1, indent: 56, color: context.colors.borderColor),
                itemBuilder: (_, i) {
                  final city = _cities[i];
                  final selected = isPickup
                      ? _pickupLabel == city
                      : _destinationLabel == city;
                  return ListTile(
                    leading: Icon(
                      isPickup ? Icons.radio_button_checked : Icons.location_on,
                      color: isPickup ? AppStyles.primaryColor : AppStyles.successColor,
                      size: 20,
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle, color: AppStyles.primaryColor, size: 18)
                        : null,
                    onTap: () {
                      setState(() {
                        if (isPickup) {
                          _pickupLabel = city;
                        } else {
                          _destinationLabel = city;
                        }
                      });
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting(BuildContext context) {
    final l10n = context.l10n;
    final hour = DateTime.now().hour;
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  String _dateIso(DateTime d) {
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$m-$day';
  }

  String _dateLabel(BuildContext context, DateTime? d) {
    if (d == null) return context.l10n.today;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppStyles.primaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _search() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RideResultsScreen(
        origin: _pickupLabel ?? '',
        destination: _destinationLabel ?? '',
        date: _selectedDate != null ? _dateIso(_selectedDate!) : null,
        seats: _seats,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════
          //  GRADIENT HERO HEADER
          // ═══════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppStyles.primaryColor,
                  AppStyles.darkMaroon,
                  AppStyles.gradientDeepColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                child: Column(
                  children: [
                    // Top row
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2),
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0x33FFFFFF),
                            child: Icon(Icons.person,
                                color: AppStyles.onPrimary, size: 22),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GOOD ${_getGreeting(context).toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Colors.white.withValues(alpha: 0.7),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Hello, ${context.watch<app_auth.AuthProvider>().userName}!',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppStyles.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StreamBuilder<int>(
                          stream: context.read<ChatProvider>().totalUnreadStream,
                          builder: (context, snap) {
                            final hasUnread = (snap.data ?? 0) > 0;
                            return Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.notifications_none_rounded,
                                      color: AppStyles.onPrimary, size: 22),
                                  if (hasUnread)
                                    Positioned(
                                      top: 9,
                                      right: 10,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: AppStyles.notificationDot,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: AppStyles.darkMaroon,
                                              width: 1.5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Stats row (DYNAMIC) ──────────────────────────
                    StreamBuilder<List<BookingModel>>(
                      stream: context
                          .read<BookingProvider>()
                          .myBookingsStream,
                      builder: (ctx, bookingSnap) {
                        final allBookings = bookingSnap.data ?? [];
                        final completedCount = allBookings
                            .where((b) => b.status == 'completed')
                            .length;
                        final uid = context
                                .read<app_auth.AuthProvider>()
                                .currentUser
                                ?.uid ??
                            '';

                        return StreamBuilder<
                            List<Map<String, dynamic>>>(
                          stream: context
                              .read<RatingProvider>()
                              .passengerRatingsStream(uid),
                          builder: (ctx2, ratingSnap) {
                            final ratings = ratingSnap.data ?? [];
                            final avg = ratings.isEmpty
                                ? null
                                : ratings
                                        .map((r) =>
                                            (r['stars'] as num?)
                                                ?.toDouble() ??
                                            0.0)
                                        .reduce((a, b) => a + b) /
                                    ratings.length;

                            return Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.directions_car_rounded,
                                  label: context.l10n.tripsTaken,
                                  value: '$completedCount',
                                  iconColor: AppStyles.successColor,
                                ),
                                const SizedBox(width: 10),
                                _buildStatCard(
                                  icon: avg == null
                                      ? Icons.star_border_rounded
                                      : Icons.star_rounded,
                                  label: context.l10n.myRating,
                                  value: avg == null
                                      ? '—'
                                      : avg.toStringAsFixed(1),
                                  iconColor: avg == null
                                      ? Colors.white
                                          .withValues(alpha: 0.4)
                                      : AppStyles.goldStar,
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════
          //  SEARCH CARD (overlapping)
          // ═══════════════════════════════════════════════════════
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                borderRadius: BorderRadius.circular(20),
                elevation: 6,
                shadowColor: AppStyles.primaryColor.withValues(alpha: 0.2),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.planYourTrip,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Pickup location button ──────────────────────
                      _buildLocationButton(
                        icon: Icons.radio_button_checked,
                        iconColor: AppStyles.primaryColor,
                        label: _pickupLabel ?? context.l10n.selectPickupLocation,
                        isSet: _pickupLabel != null,
                        isLoading: false,
                        onTap: () => _pickCity(isPickup: true),
                      ),
                      const SizedBox(height: 1),

                      // Connecting line between the two buttons
                      Padding(
                        padding: const EdgeInsets.only(left: 22),
                        child: Container(
                          width: 2,
                          height: 12,
                          color: context.colors.borderColor,
                        ),
                      ),
                      const SizedBox(height: 1),

                      // ── Destination button ──────────────────────────
                      _buildLocationButton(
                        icon: Icons.location_on,
                        iconColor: AppStyles.successColor,
                        label: _destinationLabel ?? context.l10n.selectDestination,
                        isSet: _destinationLabel != null,
                        isLoading: false,
                        onTap: () => _pickCity(isPickup: false),
                      ),

                      // ── Saved places quick-pick ─────────────────────
                      Consumer<SavedPlacesProvider>(
                        builder: (_, sp, _) {
                          if (sp.places.isEmpty) {
                            return const SizedBox(height: 12);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                context.l10n.myPlaces,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.colors.textTertiary,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: sp.places
                                      .map((p) => _buildSavedPlaceChip(p))
                                      .toList(),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        },
                      ),

                      // Date + Seats row
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                height: 52,
                                decoration: BoxDecoration(
                                  color: context.colors.cardBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Icon(Icons.calendar_today,
                                        color: context.colors.textTertiary,
                                        size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      _dateLabel(context, _selectedDate),
                                      style: TextStyle(
                                        color: _selectedDate != null
                                            ? context.colors.textPrimary
                                            : context.colors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: context.colors.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (_seats > 1)
                                        setState(() => _seats--);
                                    },
                                    child: Icon(Icons.remove,
                                        size: 16,
                                        color:
                                            context.colors.textTertiary),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text('$_seats',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: context
                                                .colors.textPrimary)),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      if (_seats < 4)
                                        setState(() => _seats++);
                                    },
                                    child: Icon(Icons.add,
                                        size: 16,
                                        color:
                                            context.colors.textTertiary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (_pickupLabel != null && _destinationLabel != null)
                              ? _search
                              : null,
                          icon: const Icon(Icons.search, size: 20),
                          label: Text(context.l10n.searchRides,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyles.darkMaroon,
                            foregroundColor: AppStyles.onPrimary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Recommended for you
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.recommendedForYou,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const RideResultsScreen()),
                  ),
                  child: Text(
                    context.l10n.seeAll,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          StreamBuilder<List<BookingModel>>(
            stream: context.read<BookingProvider>().myBookingsStream,
            builder: (context, bookingSnap) {
              final pastBookings = bookingSnap.data ?? [];
              return StreamBuilder<List<RideModel>>(
                stream: _availableRidesStream,
                initialData: context.read<RideProvider>().lastAvailableRides,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      snapshot.data == null) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator()));
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(
                              color: Colors.red, fontSize: 12)),
                    );
                  }
                  final rides =
                      _rankRides(snapshot.data ?? [], pastBookings)
                          .take(3)
                          .toList();
                  if (rides.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: Text(context.l10n.noRidesAvailable,
                          style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 14)),
                    );
                  }
                  return Column(
                    children: rides
                        .map((ride) => _LiveRideCard(ride: ride))
                        .toList(),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 24),

          // Quick Destinations
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              context.l10n.quickDestinations,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDestinationCard(context, 'Amman'),
                _buildDestinationCard(context, 'Aqaba'),
                _buildDestinationCard(context, 'Irbid'),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Location button ─────────────────────────────────────────────────────
  Widget _buildLocationButton({
    required IconData icon,
    required Color iconColor,
    required String label,
    required bool isSet,
    required bool isLoading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSet
                ? iconColor.withValues(alpha: 0.4)
                : context.colors.borderColor,
          ),
        ),
        child: Row(
          children: [
            isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: iconColor))
                : Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSet ? FontWeight.w600 : FontWeight.w400,
                  color: isSet
                      ? context.colors.textPrimary
                      : context.colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 20, color: context.colors.textTertiary),
          ],
        ),
      ),
    );
  }

  // ── Saved place chip ────────────────────────────────────────────────────
  Widget _buildSavedPlaceChip(SavedPlace place) {
    return GestureDetector(
      onTap: () => _onSavedPlaceTapped(place),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.colors.borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(place.icon, size: 14, color: AppStyles.primaryColor),
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
  }

  void _onSavedPlaceTapped(SavedPlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: context.colors.surfaceColor,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(place.icon, color: AppStyles.primaryColor, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    place.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                place.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.radio_button_checked,
                  color: AppStyles.primaryColor),
              title: Text(context.l10n.setAsPickup,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                final label = place.subtitle.isNotEmpty
                    ? place.subtitle
                    : place.title;
                setState(() {
                  _pickupLabel = label;
                });
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.location_on, color: AppStyles.successColor),
              title: Text(context.l10n.setAsDestination,
                  style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(ctx);
                final label = place.subtitle.isNotEmpty
                    ? place.subtitle
                    : place.title;
                setState(() {
                  _destinationLabel = label;
                });
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Stat card ───────────────────────────────────────────────────────────
  static Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(value,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.onPrimary)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.6),
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  static List<RideModel> _rankRides(
      List<RideModel> rides, List<BookingModel> past) {
    if (past.isEmpty) return rides;
    final destFreq = <String, int>{};
    final originFreq = <String, int>{};
    final knownDrivers = <String>{};
    for (final b in past) {
      destFreq[b.destination] = (destFreq[b.destination] ?? 0) + 1;
      originFreq[b.origin] = (originFreq[b.origin] ?? 0) + 1;
      knownDrivers.add(b.driverId);
    }
    int score(RideModel r) =>
        (destFreq[r.destination] ?? 0) * 3 +
        (originFreq[r.origin] ?? 0) * 2 +
        (knownDrivers.contains(r.driverId) ? 1 : 0);
    return [...rides]..sort((a, b) {
        final diff = score(b) - score(a);
        return diff != 0 ? diff : b.createdAt.compareTo(a.createdAt);
      });
  }

  Widget _buildDestinationCard(BuildContext context, String city) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => RideResultsScreen(destination: city),
      )),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: context.colors.highlightBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/${city.toLowerCase()}_city.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: context.colors.cardBackgroundColor),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x88000000)],
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Text(city,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppStyles.onPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live ride card ───────────────────────────────────────────────────────────
class _LiveRideCard extends StatelessWidget {
  final RideModel ride;
  const _LiveRideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => RideDetailsScreen(ride: ride)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.borderColor),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: context.colors.highlightBackgroundColor,
              child: Text(
                ride.driverName.isNotEmpty
                    ? ride.driverName[0].toUpperCase()
                    : 'D',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(ride.driverName,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary)),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: context.colors.highlightBackgroundColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${ride.origin} → ${ride.destination}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppStyles.primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${ride.date}  ·  ${ride.time}',
                      style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event_seat_rounded,
                          size: 13, color: context.colors.textTertiary),
                      const SizedBox(width: 4),
                      Text(
                          '${ride.availableSeats} ${context.l10n.seatsLeft}',
                          style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Text('${ride.pricePerSeat} JOD',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.primaryColor)),
          ],
        ),
      ),
    );
  }
}