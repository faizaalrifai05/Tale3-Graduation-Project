import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/widgets/permission_dialog.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/screens/driver/ride_confirmation_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/theme/app_styles.dart';

// ignore_for_file: use_build_context_synchronously

class DriverCreateRideScreen extends StatelessWidget {
  const DriverCreateRideScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  // ── Same cities as admin pricing panel ──────────────────────────────────
  static const List<String> _cities = [
    'Amman', 'Zarqa', 'Irbid', 'Aqaba', 'Salt',
    'Madaba', 'Jerash', 'Ajloun', 'Karak', 'Mafraq',
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.read<app_auth.AuthProvider>();
    final user = auth.currentUser;
    final isVerified =
        user?.verificationStatus == VerificationStatus.verified;
    final isBlocked = user?.isBlocked ?? false;

    return Scaffold(
      backgroundColor: context.colors.surfaceColor,
      appBar: AppBar(
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.createRide,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Blocked banner ─────────────────────────────────────────
              if (isBlocked)
                _StatusBanner(
                  icon: Icons.block_rounded,
                  color: AppStyles.errorColor,
                  bgColor: context.colors.errorLightBg,
                  title: 'Account Blocked',
                  message:
                      'Your account has been blocked. You cannot create rides. Please contact support at support@tale3.app.',
                ),

              // ── Not verified banner ────────────────────────────────────
              if (!isBlocked && !isVerified)
                _StatusBanner(
                  icon: user?.verificationStatus == VerificationStatus.pending
                      ? Icons.hourglass_top_rounded
                      : user?.verificationStatus == VerificationStatus.rejected
                          ? Icons.cancel_outlined
                          : Icons.verified_user_outlined,
                  color: user?.verificationStatus == VerificationStatus.rejected
                      ? AppStyles.errorColor
                      : AppStyles.primaryColor,
                  bgColor:
                      user?.verificationStatus == VerificationStatus.rejected
                          ? context.colors.errorLightBg
                          : context.colors.highlightBackgroundColor,
                  title: user?.verificationStatus == VerificationStatus.pending
                      ? 'Verification Pending'
                      : user?.verificationStatus == VerificationStatus.rejected
                          ? 'Verification Rejected'
                          : 'Not Verified Yet',
                  message: user?.verificationStatus == VerificationStatus.pending
                      ? 'Your ID is under review. You will be able to create rides once the admin approves your account.'
                      : user?.verificationStatus == VerificationStatus.rejected
                          ? 'Your verification was rejected. Please resubmit your ID documents from your profile.'
                          : 'You need to submit your ID for verification before you can post rides. Go to your profile to submit.',
                ),

              // ── Form only shown if verified and not blocked ─────────────
              if (!isBlocked && isVerified)
                Consumer<RideProvider>(
                  builder: (context, rideProvider, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // ── Route Settings ───────────────────────────────
                        Text(
                          context.l10n.routeSettings,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Origin Dropdown
                        _buildDropdownField(
                          context: context,
                          label: context.l10n.date == 'Date' ? 'From' : 'من',
                          hint: context.l10n.selectOriginCity,
                          icon: Icons.radio_button_unchecked,
                          value: rideProvider.origin.isEmpty
                              ? null
                              : rideProvider.origin,
                          onChanged: (val) {
                            if (val != null) rideProvider.setOrigin(val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // Destination Dropdown
                        _buildDropdownField(
                          context: context,
                          label: context.l10n.date == 'Date' ? 'To' : 'إلى',
                          hint: context.l10n.selectDestinationCity,
                          icon: Icons.location_on,
                          value: rideProvider.destination.isEmpty
                              ? null
                              : rideProvider.destination,
                          onChanged: (val) {
                            if (val != null) rideProvider.setDestination(val);
                          },
                        ),
                        const SizedBox(height: 12),

                        // ── Price banner ─────────────────────────────────
                        if (rideProvider.origin.isNotEmpty &&
                            rideProvider.destination.isNotEmpty)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: rideProvider.hasAdminPrice
                                  ? context.colors.highlightBackgroundColor
                                  : rideProvider.priceError.isNotEmpty
                                      ? context.colors.errorLightBg
                                      : context.colors.cardBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rideProvider.hasAdminPrice
                                    ? AppStyles.primaryColor
                                        .withValues(alpha: 0.3)
                                    : rideProvider.priceError.isNotEmpty
                                        ? AppStyles.errorColor.withValues(alpha: 0.3)
                                        : context.colors.borderColor,
                              ),
                            ),
                            child: Row(
                              children: [
                                if (rideProvider.loadingPrice)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppStyles.primaryColor,
                                    ),
                                  )
                                else
                                  Icon(
                                    rideProvider.hasAdminPrice
                                        ? Icons.sell_outlined
                                        : rideProvider.priceError.isNotEmpty
                                            ? Icons.warning_amber_rounded
                                            : Icons.info_outline,
                                    color: rideProvider.hasAdminPrice
                                        ? context.colors.primaryColor
                                        : rideProvider.priceError.isNotEmpty
                                            ? AppStyles.errorColor
                                            : context.colors.textTertiary,
                                    size: 18,
                                  ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    rideProvider.loadingPrice
                                        ? 'Fetching route price...'
                                        : rideProvider.hasAdminPrice
                                            ? 'Admin price for ${rideProvider.origin} → ${rideProvider.destination}: ${rideProvider.adminPrice} JOD per seat'
                                            : rideProvider.priceError.isNotEmpty
                                                ? rideProvider.priceError
                                                : 'Select origin and destination to get price',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: rideProvider.hasAdminPrice
                                          ? context.colors.primaryColor
                                          : rideProvider.priceError.isNotEmpty
                                              ? AppStyles.errorColor
                                              : context.colors.textTertiary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 12),

                        // ── Date & Time ──────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: rideProvider.selectedDate ??
                                        DateTime.now()
                                            .add(const Duration(days: 1)),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 60)),
                                    builder: (ctx, child) => Theme(
                                      data: Theme.of(ctx).copyWith(
                                        colorScheme: const ColorScheme.light(
                                            primary: _primaryColor),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    rideProvider.setDate(picked);
                                  }
                                },
                                child: _buildInputBlock(
                                  context.l10n.date,
                                  rideProvider.dateLabel,
                                  Icons.calendar_today,
                                  context,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: rideProvider.selectedTime ??
                                        TimeOfDay.now(),
                                    builder: (ctx, child) => Theme(
                                      data: Theme.of(ctx).copyWith(
                                        colorScheme: const ColorScheme.light(
                                            primary: _primaryColor),
                                      ),
                                      child: child!,
                                    ),
                                  );
                                  if (picked != null) {
                                    rideProvider.setTime(picked);
                                  }
                                },
                                child: _buildInputBlock(
                                  context.l10n.time,
                                  rideProvider.timeLabel,
                                  Icons.access_time,
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Seats & Price ────────────────────────────────
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Available Seats — visual car selector
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        context.l10n.availableSeats,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: context.colors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${rideProvider.seats} seat${rideProvider.seats == 1 ? '' : 's'}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: _primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: context.colors.inputFillColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: context.colors.borderColor),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildDriverSeatDot(context),
                                            _buildPassengerSeatDot(
                                                context, 1, rideProvider),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            _buildPassengerSeatDot(
                                                context, 2, rideProvider),
                                            _buildPassengerSeatDot(
                                                context, 3, rideProvider),
                                            _buildPassengerSeatDot(
                                                context, 4, rideProvider),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Tap to include/exclude',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color:
                                                  context.colors.textTertiary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Price per seat — read only from admin
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.pricePerSeat,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: context.colors.inputFillColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: context.colors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.sell_outlined,
                                            color: AppStyles.primaryColor,
                                            size: 18),
                                        const SizedBox(width: 10),
                                        if (rideProvider.loadingPrice)
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppStyles.primaryColor,
                                            ),
                                          )
                                        else if (rideProvider.hasAdminPrice)
                                          Text(
                                            '${rideProvider.adminPrice} JOD',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppStyles.primaryColor,
                                            ),
                                          )
                                        else
                                          Text(
                                            rideProvider.origin.isNotEmpty &&
                                                    rideProvider.destination
                                                        .isNotEmpty
                                                ? 'Not set'
                                                : 'Auto-filled',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.colors.textTertiary,
                                            ),
                                          ),
                                        const Spacer(),
                                        Icon(Icons.lock_outline,
                                            color: context.colors.textTertiary,
                                            size: 16),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ── Features & Preferences ───────────────────────
                        Text(
                          context.l10n.featuresPreferences,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.8,
                          children: [
                            _PrefTile(
                              icon: Icons.ac_unit_rounded,
                              label: context.l10n.airConditioning,
                              value: rideProvider.acChecked,
                              onTap: () => rideProvider
                                  .toggleAc(!rideProvider.acChecked),
                            ),
                            _PrefTile(
                              icon: Icons.luggage_rounded,
                              label: context.l10n.luggage,
                              value: rideProvider.luggageChecked,
                              onTap: () => rideProvider
                                  .toggleLuggage(!rideProvider.luggageChecked),
                            ),
                            _PrefTile(
                              icon: Icons.pets_rounded,
                              label: context.l10n.petsAllowed,
                              value: rideProvider.petsChecked,
                              onTap: () => rideProvider
                                  .togglePets(!rideProvider.petsChecked),
                            ),
                            _PrefTile(
                              icon: Icons.smoke_free_rounded,
                              label: context.l10n.noSmoking,
                              value: rideProvider.noSmokingChecked,
                              onTap: () => rideProvider.toggleNoSmoking(
                                  !rideProvider.noSmokingChecked),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Additional Notes ─────────────────────────────
                        Text(
                          context.l10n.additionalNotes,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          maxLines: 4,
                          onChanged: rideProvider.setAdditionalNotes,
                          decoration: InputDecoration(
                            hintText: context.l10n.additionalNotesHint,
                            hintStyle: TextStyle(
                                color: context.colors.inputHintColor,
                                fontSize: 14),
                            filled: true,
                            fillColor: context.colors.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: context.colors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: context.colors.borderColor),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              borderSide: BorderSide(
                                  color: AppStyles.primaryColor, width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),

                        // ── Publish Button ───────────────────────────────
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: rideProvider.isPublishing
                                ? null
                                : () async {
                                    // 0. Location permission check
                                    final perm = await Geolocator.checkPermission();
                                    if (!context.mounted) return;
                                    if (perm == LocationPermission.denied ||
                                        perm == LocationPermission.deniedForever) {
                                      await showLocationSettingsReminder(context);
                                      return;
                                    }

                                    // 1. Synchronous field validation
                                    final error = rideProvider.validate();
                                    if (error != null) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(error),
                                          backgroundColor: AppStyles.errorColor,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      return;
                                    }

                                    // 2. Price check
                                    if (!rideProvider.hasAdminPrice) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            rideProvider
                                                    .priceError.isNotEmpty
                                                ? rideProvider.priceError
                                                : 'Please wait for route price to load.',
                                          ),
                                          backgroundColor: AppStyles.errorColor,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      return;
                                    }

                                    // 3. Schedule conflict check
                                    final conflictError = await rideProvider
                                        .checkScheduleConflict();
                                    if (!context.mounted) return;
                                    if (conflictError != null) {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (_) => AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // ── Red header ──────────
                                              Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 24,
                                                        horizontal: 20),
                                                decoration: BoxDecoration(
                                                  color: context.colors.errorLightBg,
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(20),
                                                    topRight:
                                                        Radius.circular(20),
                                                  ),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width: 56,
                                                      height: 56,
                                                      decoration:
                                                          BoxDecoration(
                                                        color: context.colors.surfaceColor,
                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons
                                                            .directions_car_rounded,
                                                        color:
                                                            AppStyles.primaryColor,
                                                        size: 28,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 12),
                                                    Text(
                                                      'Ride Already Scheduled',
                                                      style: TextStyle(
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        color:
                                                            AppStyles.primaryColor,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // ── Body ────────────────
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        20, 16, 20, 8),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Icon(
                                                          Icons.info_outline,
                                                          color: context
                                                              .colors
                                                              .textTertiary,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Expanded(
                                                          child: Text(
                                                            'You can only have one active ride at a time.',
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: context
                                                                  .colors
                                                                  .textSecondary,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                        height: 12),
                                                    Container(
                                                      width: double.infinity,
                                                      padding:
                                                          const EdgeInsets
                                                              .all(14),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: context.colors
                                                            .cardBackgroundColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        border: Border.all(
                                                            color: context
                                                                .colors
                                                                .borderColor),
                                                      ),
                                                      child: Text(
                                                        conflictError,
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: context
                                                              .colors
                                                              .textPrimary,
                                                          height: 1.6,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        height: 16),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      16, 0, 16, 16),
                                              child: SizedBox(
                                                width: double.infinity,
                                                height: 48,
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context),
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    backgroundColor:
                                                        _darkMaroon,
                                                    foregroundColor:
                                                        AppStyles.onPrimary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(12),
                                                    ),
                                                    elevation: 0,
                                                  ),
                                                  child: const Text(
                                                    'Got it',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                      return;
                                    }

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RideConfirmationScreen(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _darkMaroon,
                              foregroundColor: AppStyles.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              context.l10n.publishRide,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverSeatDot(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: context.colors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(Icons.drive_eta, color: context.colors.textTertiary, size: 20),
      ),
    );
  }

  Widget _buildPassengerSeatDot(
      BuildContext context, int index, RideProvider rideProvider) {
    final available = rideProvider.selectedSeats.contains(index);
    return GestureDetector(
      onTap: () => rideProvider.tapSeat(index),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: available ? _primaryColor : context.colors.inputFillColor,
          borderRadius: BorderRadius.circular(8),
          border: available
              ? null
              : Border.all(color: context.colors.borderColor),
        ),
        child: Center(
          child: Icon(
            Icons.person,
            size: 20,
            color: available ? AppStyles.onPrimary : context.colors.textTertiary,
          ),
        ),
      ),
    );
  }

  // ── Dropdown field ────────────────────────────────────────────────────────
  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.inputFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, color: _primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    hint,
                    style: TextStyle(
                      color: context.colors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down,
                  color: context.colors.textTertiary),
              items: _cities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      Icon(icon, color: _primaryColor, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        city,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // ── Input block (read only display) ──────────────────────────────────────
  Widget _buildInputBlock(
      String label, String value, IconData icon, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.inputFillColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.borderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: _primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Preference tile ───────────────────────────────────────────────────────
class _PrefTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final VoidCallback onTap;

  const _PrefTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  static const Color _primary = Color(0xFF8B1A2B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: value
              ? _primary.withValues(alpha: 0.08)
              : context.colors.inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? _primary : context.colors.borderColor,
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: value ? _primary : context.colors.textTertiary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: value ? _primary : context.colors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              value ? Icons.check_circle_rounded : Icons.circle_outlined,
              size: 18,
              color: value ? _primary : context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Status Banner ─────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String title;
  final String message;

  const _StatusBanner({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: color.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}