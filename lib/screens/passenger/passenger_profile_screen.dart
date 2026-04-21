import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/screens/passenger/passenger_saved_places_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PassengerProfileScreen extends StatefulWidget {
  const PassengerProfileScreen({super.key});

  @override
  State<PassengerProfileScreen> createState() => _PassengerProfileScreenState();
}

class _PassengerProfileScreenState extends State<PassengerProfileScreen> {
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
                title: Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, setSheetState);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppStyles.primaryColor),
                title: Text('Choose from gallery'),
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
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Divider(),
                const SizedBox(height: 20),

                // Profile photo picker
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
                                child: Icon(Icons.person,
                                    color: AppStyles.onPrimary, size: 48),
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
                  'Tap to change photo',
                  style: TextStyle(fontSize: 12, color: context.colors.textTertiary),
                ),
                const SizedBox(height: 24),

                _buildSheetField(
                  controller: _nameController,
                  label: 'FULL NAME',
                  hint: 'Your full name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _buildSheetField(
                  controller: _phoneController,
                  label: 'PHONE NUMBER',
                  hint: '+966 5X XXX XXXX',
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
                              Text('Profile updated',
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
                    child: Text('Save Changes',
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
            prefixIcon: Icon(icon, color: context.colors.inputHintColor, size: 20),
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
        : (authUser?.name.isNotEmpty == true ? authUser!.name : 'Your Name');
    final displayPhone = _phoneNumber.isNotEmpty
        ? _phoneNumber
        : (authUser?.phone.isNotEmpty == true ? authUser!.phone : 'Add phone number');

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
                            'My Profile',
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
                                  'Edit',
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
                                  shownName.isEmpty ? 'Passenger Name' : shownName,
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
                      // ── Quick Links ──────────────────────────────────
                      _buildSection(
                        title: 'Quick Links',
                        child: _buildLinkTile(
                            Icons.favorite_border_rounded, 'Saved Places'),
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
                                  title: Text('Log Out',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700)),
                                  content: Text(
                                      'Are you sure you want to log out?',
                                      style: TextStyle(fontSize: 14)),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text('Cancel'),
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
                                      child: Text('Log Out'),
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
                              'Log Out',
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: AppStyles.primaryColor),
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
                      value: '4.8',
                      label: 'Rating'),
                  Container(width: 1, height: 40, color: context.colors.dividerColor),
                  _buildStatCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: AppStyles.primaryColor,
                      value: '42',
                      label: 'Trips'),
                  Container(width: 1, height: 40, color: context.colors.dividerColor),
                  _buildStatCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: AppStyles.successColor,
                      value: '2',
                      label: 'Years'),
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
        if (title == 'Saved Places') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PassengerSavedPlacesScreen()),
          );
        }
      },
    );
  }
}
