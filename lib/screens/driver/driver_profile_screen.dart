import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/screens/settings_screen.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/screens/driver/driver_saved_places_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  String _displayName = '';
  String _phoneNumber = '';
  File? _profileImage;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      setState(() {
        _displayName = auth.userName;
        _phoneNumber = auth.userPhone;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, StateSetter setSheetState) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      setSheetState(() {});
    }
  }

  void _showImagePickerOptions(StateSetter setSheetState) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppStyles.primaryColor),
                title: Text(context.l10n.takeAPhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, setSheetState);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppStyles.primaryColor),
                title: Text(context.l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery, setSheetState);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditSheet() {
    _nameController.text = _displayName;
    _phoneController.text = _phoneNumber;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setSheetState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.l10n.editProfile,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 20),

                // Profile photo
                GestureDetector(
                  onTap: () => _showImagePickerOptions(setSheetState),
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppStyles.primaryColor, width: 2),
                        ),
                        child: _profileImage != null
                            ? ClipOval(
                                child: Image.file(
                                  _profileImage!,
                                  width: 90,
                                  height: 90,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: context.colors.borderColor,
                                child:
                                    Icon(Icons.person, color: AppStyles.onPrimary, size: 48),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppStyles.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt,
                              color: AppStyles.onPrimary, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.tapToChangePhoto,
                  style: TextStyle(fontSize: 12, color: context.colors.textTertiary),
                ),
                const SizedBox(height: 24),

                _buildSheetField(
                  controller: _nameController,
                  label: context.l10n.fullName.toUpperCase(),
                  hint: context.l10n.yourFullName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildSheetField(
                  controller: _phoneController,
                  label: context.l10n.phoneNumber.toUpperCase(),
                  hint: context.l10n.phoneHint,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final phone = _phoneController.text.trim();
                      setState(() {
                        _displayName = name;
                        _phoneNumber = phone;
                      });
                      context.read<AuthProvider>().updateProfile(
                            name: name, phone: phone);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: AppStyles.onPrimary, size: 20),
                              SizedBox(width: 12),
                              Text(context.l10n.profileUpdated,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          backgroundColor: AppStyles.successDarkText,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.darkMaroon,
                      foregroundColor: AppStyles.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(context.l10n.saveChanges,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
        });
      },
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colors.textTertiary,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: context.colors.inputHintColor, fontSize: 14),
            prefixIcon:
                Icon(icon, color: context.colors.inputHintColor, size: 20),
            filled: true,
            fillColor: context.colors.inputFillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().currentUser;
    final shownName = _displayName.isNotEmpty
        ? _displayName
        : (authUser?.name.isNotEmpty == true ? authUser!.name : context.l10n.yourName);
    final displayPhone = _phoneNumber.isNotEmpty
        ? _phoneNumber
        : (authUser?.phone.isNotEmpty == true ? authUser!.phone : context.l10n.addPhoneNumber);

    return Stack(
      children: [
        // Background
        Container(color: context.colors.backgroundColor),

        Column(
          children: [
            // ════════════════════════════════════════════════════════
            // RED GRADIENT HEADER
            // ════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppStyles.primaryColor, AppStyles.darkMaroon],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 50),
                  child: Column(
                    children: [
                      // Top Row: Title & Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            context.l10n.driverProfile,
                            style: TextStyle(
                              color: AppStyles.onPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _openEditSheet,
                                icon: Icon(Icons.edit_outlined,
                                    size: 16, color: AppStyles.onPrimary),
                                label: Text(
                                  context.l10n.edit,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppStyles.onPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.settings_outlined,
                                    color: AppStyles.onPrimary),
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => const SettingsScreen()));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Avatar & Name Row
                      Row(
                        children: [
                          // Avatar
                          GestureDetector(
                            onTap: _openEditSheet,
                            child: Stack(
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        width: 3),
                                  ),
                                  child: _profileImage != null
                                      ? ClipOval(
                                          child: Image.file(
                                            _profileImage!,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.all(2),
                                          child: CircleAvatar(
                                            backgroundColor: Color(0x33FFFFFF),
                                            child: Icon(Icons.person,
                                                color: AppStyles.onPrimary, size: 42),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppStyles.cameraButtonColor,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppStyles.darkMaroon,
                                          width: 2),
                                    ),
                                    child: Icon(Icons.camera_alt,
                                        color: AppStyles.onPrimary, size: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),

                          // Name & Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shownName.isEmpty ? context.l10n.driverName : shownName,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppStyles.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone_outlined,
                                        size: 14, color: AppStyles.onPrimary),
                                    const SizedBox(width: 6),
                                    Text(
                                      displayPhone,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppStyles.onPrimary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Gold Driver badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33FFFFFF),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.workspace_premium,
                                          color: AppStyles.goldStar, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        context.l10n.goldDriver,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppStyles.goldStar,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // ════════════════════════════════════════════════════════
            // REMAINING CONTENT (Scrollable)
            // ════════════════════════════════════════════════════════
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 60), // Space for overlapping card
                  child: Column(
                    children: [
                      // ── Vehicle Information ──────────────────────────
                      _buildSection(
                        title: context.l10n.vehicle,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.colors.inputFillColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.colors.borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: context.colors.highlightBackgroundColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.directions_car,
                                    color: AppStyles.primaryColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final user = context.watch<AuthProvider>().currentUser;
                                    final makeModel = [user?.carMake, user?.carModel]
                                        .where((s) => s != null && s.isNotEmpty)
                                        .join(' ');
                                    final details = [user?.carColor, user?.carYear, user?.plateNumber]
                                        .where((s) => s != null && s.isNotEmpty)
                                        .join(' • ');
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          makeModel.isNotEmpty ? makeModel : context.l10n.noVehicleAdded,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.textPrimary,
                                          ),
                                        ),
                                        if (details.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            details,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: context.colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    );
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppStyles.successLightBg,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  context.l10n.active,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: AppStyles.successDarkText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Verification Status ──────────────────────────
                      _buildSection(
                        title: context.l10n.verification,
                        child: Column(
                          children: [
                            _buildVerificationItem(context.l10n.identityVerified, true),
                            const SizedBox(height: 10),
                            _buildVerificationItem(context.l10n.backgroundCheck, true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Quick Links ──────────────────────────────────
                      _buildSection(
                        title: context.l10n.quickLinks,
                        child: _buildLinkTile(
                            Icons.favorite_border_rounded, context.l10n.savedPlaces),
                      ),
                      const SizedBox(height: 24),

                      // ── Logout ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: Text(context.l10n.logOut,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                  content: Text(
                                      context.l10n.logOutConfirm,
                                      style: TextStyle(fontSize: 14)),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(context.l10n.cancel),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            AppStyles.primaryColor,
                                        foregroundColor: AppStyles.onPrimary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        elevation: 0,
                                      ),
                                      child: Text(context.l10n.logOut),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true && context.mounted) {
                                context.read<AuthProvider>().logout();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const WelcomeScreen()),
                                  (route) => false,
                                );
                              }
                            },
                            icon: Icon(Icons.logout,
                                color: AppStyles.primaryColor),
                            label: Text(
                              context.l10n.logOut,
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  BorderSide(color: AppStyles.primaryColor),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        // ════════════════════════════════════════════════════════
        // OVERLAPPING STATS CARD
        // (Positioned absolutely over the gradient edge)
        // ════════════════════════════════════════════════════════
        Positioned(
          top: 200, // Roughly where the gradient ends
          left: 20,
          right: 20,
          child: Material(
            borderRadius: BorderRadius.circular(20),
            elevation: 8,
            shadowColor: AppStyles.primaryColor.withValues(alpha: 0.15),
            color: context.colors.surfaceColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildStatCard(
                      icon: Icons.star_rounded,
                      iconColor: AppStyles.goldStar,
                      value: '4.9',
                      label: context.l10n.rating),
                  Container(width: 1, height: 40, color: context.colors.dividerColor),
                  _buildStatCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: AppStyles.primaryColor,
                      value: '1,418',
                      label: context.l10n.rides),
                  Container(width: 1, height: 40, color: context.colors.dividerColor),
                  _buildStatCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppStyles.successColor,
                      value: '4.2',
                      label: context.l10n.years),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      color: context.colors.surfaceColor,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: context.colors.textTertiary,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, bool isVerified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isVerified
            ? AppStyles.successBgVerified
            : context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? AppStyles.successBorder
              : context.colors.borderColor,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.access_time,
            color: isVerified
                ? AppStyles.successColor
                : context.colors.textTertiary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? AppStyles.successColor
                  : context.colors.borderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isVerified ? context.l10n.verified : context.l10n.pending,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppStyles.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile(IconData icon, String title) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.inputFillColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppStyles.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      trailing:
          Icon(Icons.chevron_right, color: context.colors.textTertiary),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DriverSavedPlacesScreen()),
        );
      },
    );
  }
}
