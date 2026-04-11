import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_styles.dart';
import 'package:testtale3/screens/settings_screen.dart';
import 'package:testtale3/providers/auth_provider.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/screens/saved_places_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
                leading: const Icon(Icons.camera_alt, color: AppStyles.primaryColor),
                title: const Text('Take a photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera, setSheetState);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: AppStyles.primaryColor),
                title: const Text('Choose from gallery'),
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
      backgroundColor: Colors.white,
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
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Divider(),
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
                            : const CircleAvatar(
                                backgroundColor: Color(0xFFE0E0E0),
                                child:
                                    Icon(Icons.person, color: Colors.white, size: 48),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: const BoxDecoration(
                            color: AppStyles.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
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
                      setState(() {
                        _displayName = _nameController.text.trim();
                        _phoneNumber = _phoneController.text.trim();
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.check_circle_outline,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 12),
                              Text('Profile updated',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500)),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.darkMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Save Changes',
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
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppStyles.textTertiary,
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
                const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon:
                Icon(icon, color: const Color(0xFFBDBDBD), size: 20),
            filled: true,
            fillColor: const Color(0xFFF9F9F9),
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
    final shownName =
        _displayName.isNotEmpty ? _displayName : 'Alex Johnson';
    final displayPhone = _phoneNumber.isNotEmpty ? _phoneNumber : '+966 5X XXX XXXX';

    return Stack(
      children: [
        // Background
        Container(color: AppStyles.backgroundColor),

        Column(
          children: [
            // ════════════════════════════════════════════════════════
            // RED GRADIENT HEADER
            // ════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
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
                          const Text(
                            'Driver Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: _openEditSheet,
                                icon: const Icon(Icons.edit_outlined,
                                    size: 16, color: Colors.white),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    color: Colors.white),
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
                                      : const Padding(
                                          padding: EdgeInsets.all(2),
                                          child: CircleAvatar(
                                            backgroundColor: Color(0x33FFFFFF),
                                            child: Icon(Icons.person,
                                                color: Colors.white, size: 42),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF4D4D),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: AppStyles.darkMaroon,
                                          width: 2),
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        color: Colors.white, size: 12),
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
                                  shownName.isEmpty ? 'Driver Name' : shownName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone_outlined,
                                        size: 14, color: Colors.white70),
                                    const SizedBox(width: 6),
                                    Text(
                                      displayPhone,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
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
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.workspace_premium,
                                          color: Color(0xFFFFD700), size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Gold Driver',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFFFD700),
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
                        title: 'Vehicle',
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDF2F4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.directions_car,
                                    color: AppStyles.primaryColor, size: 28),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tesla Model 3',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'White • 2022 • ABC 1234',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF757575),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'ACTIVE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E7D32),
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
                        title: 'Verification',
                        child: Column(
                          children: [
                            _buildVerificationItem('Identity Verified', true),
                            const SizedBox(height: 10),
                            _buildVerificationItem('Background Check', true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

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
                            onPressed: () {
                              context.read<AuthProvider>().logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()),
                                (route) => false,
                              );
                            },
                            icon: const Icon(Icons.logout,
                                color: AppStyles.primaryColor),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(
                                color: AppStyles.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side:
                                  const BorderSide(color: AppStyles.primaryColor),
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
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  _buildStatCard(
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFFFD700),
                      value: '4.9',
                      label: 'Rating'),
                  Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                  _buildStatCard(
                      icon: Icons.directions_car_rounded,
                      iconColor: AppStyles.primaryColor,
                      value: '1,418',
                      label: 'Rides'),
                  Container(width: 1, height: 40, color: const Color(0xFFEEEEEE)),
                  _buildStatCard(
                      icon: Icons.calendar_today_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      value: '4.2',
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppStyles.textTertiary,
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppStyles.textTertiary,
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
            ? const Color(0xFFF0FBF1)
            : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVerified
              ? const Color(0xFFA5D6A7)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.access_time,
            color: isVerified
                ? const Color(0xFF4CAF50)
                : const Color(0xFF9E9E9E),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isVerified
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isVerified ? 'VERIFIED' : 'PENDING',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.white,
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
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppStyles.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppStyles.textPrimary,
        ),
      ),
      trailing:
          const Icon(Icons.chevron_right, color: AppStyles.textTertiary),
      onTap: () {
        if (title == 'Saved Places') {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SavedPlacesScreen()),
          );
        }
      },
    );
  }
}
