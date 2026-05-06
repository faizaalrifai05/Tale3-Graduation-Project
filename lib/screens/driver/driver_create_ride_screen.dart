import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.createRide,
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Blocked banner ─────────────────────────────────────────
              if (isBlocked)
                _StatusBanner(
                  icon: Icons.block_rounded,
                  color: Colors.red,
                  bgColor: const Color(0xFFFFEBEE),
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
                      ? Colors.red
                      : const Color(0xFF8B1A2B),
                  bgColor:
                      user?.verificationStatus == VerificationStatus.rejected
                          ? const Color(0xFFFFEBEE)
                          : const Color(0xFFFDF2F4),
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
                          hint: 'Select origin city',
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
                          hint: 'Select destination city',
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
                                  ? const Color(0xFFFDF2F4)
                                  : rideProvider.priceError.isNotEmpty
                                      ? const Color(0xFFFFEBEE)
                                      : const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: rideProvider.hasAdminPrice
                                    ? const Color(0xFF8B1A2B)
                                        .withValues(alpha: 0.3)
                                    : rideProvider.priceError.isNotEmpty
                                        ? Colors.red.withValues(alpha: 0.3)
                                        : const Color(0xFFE0E0E0),
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
                                      color: Color(0xFF8B1A2B),
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
                                        ? _primaryColor
                                        : rideProvider.priceError.isNotEmpty
                                            ? Colors.red
                                            : const Color(0xFF9E9E9E),
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
                                          ? _primaryColor
                                          : rideProvider.priceError.isNotEmpty
                                              ? Colors.red
                                              : const Color(0xFF9E9E9E),
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
                          children: [
                            // Available Seats
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.availableSeats,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: context.colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      color: context.colors.inputFillColor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: context.colors.borderColor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove,
                                              color:
                                                  context.colors.textPrimary,
                                              size: 16),
                                          onPressed:
                                              rideProvider.decrementSeats,
                                        ),
                                        Text(
                                          '${rideProvider.seats}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.add,
                                              color:
                                                  context.colors.textPrimary,
                                              size: 16),
                                          onPressed:
                                              rideProvider.incrementSeats,
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
                                      color: const Color(0xFFF0F0F0),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: context.colors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.sell_outlined,
                                            color: Color(0xFF8B1A2B),
                                            size: 18),
                                        const SizedBox(width: 10),
                                        if (rideProvider.loadingPrice)
                                          const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Color(0xFF8B1A2B),
                                            ),
                                          )
                                        else if (rideProvider.hasAdminPrice)
                                          Text(
                                            '${rideProvider.adminPrice} JOD',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF8B1A2B),
                                            ),
                                          )
                                        else
                                          Text(
                                            rideProvider.origin.isNotEmpty &&
                                                    rideProvider.destination
                                                        .isNotEmpty
                                                ? 'Not set'
                                                : 'Auto-filled',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF9E9E9E),
                                            ),
                                          ),
                                        const Spacer(),
                                        const Icon(Icons.lock_outline,
                                            color: Color(0xFF9E9E9E),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: rideProvider.acChecked,
                                onChanged: (v) =>
                                    rideProvider.toggleAc(v ?? false),
                                title: Text(context.l10n.airConditioning,
                                    style: const TextStyle(fontSize: 13)),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppStyles.primaryColor,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: rideProvider.luggageChecked,
                                onChanged: (v) =>
                                    rideProvider.toggleLuggage(v ?? false),
                                title: Text(context.l10n.luggage,
                                    style: const TextStyle(fontSize: 13)),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppStyles.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CheckboxListTile(
                                value: rideProvider.petsChecked,
                                onChanged: (v) =>
                                    rideProvider.togglePets(v ?? false),
                                title: Text(context.l10n.petsAllowed,
                                    style: const TextStyle(fontSize: 13)),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppStyles.primaryColor,
                              ),
                            ),
                            Expanded(
                              child: CheckboxListTile(
                                value: rideProvider.noSmokingChecked,
                                onChanged: (v) =>
                                    rideProvider.toggleNoSmoking(v ?? false),
                                title: Text(context.l10n.noSmoking,
                                    style: const TextStyle(fontSize: 13)),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.zero,
                                activeColor: AppStyles.primaryColor,
                              ),
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
                              borderSide:
                                  BorderSide(color: context.colors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: context.colors.borderColor),
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
                            onPressed: () {
                              final error = rideProvider.validate();
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(error),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
                                  ),
                                );
                                return;
                              }
                              if (!rideProvider.hasAdminPrice) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      rideProvider.priceError.isNotEmpty
                                          ? rideProvider.priceError
                                          : 'Please wait for route price to load.',
                                    ),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    margin: const EdgeInsets.all(16),
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
                              foregroundColor: Colors.white,
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