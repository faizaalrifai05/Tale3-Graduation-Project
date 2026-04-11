import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_styles.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'package:testtale3/screens/welcome_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controllers for Personal Information
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Controllers for Password & Security
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppStyles.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppStyles.textPrimary),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          // ── ACCOUNT ──
          _buildSectionHeader('ACCOUNT'),
          _buildSettingsTile(
            Icons.person_outline,
            'Personal Information',
            onTap: () => _showPersonalInfoSheet(auth),
          ),
          _buildSettingsTile(
            Icons.security,
            'Password & Security',
            onTap: () => _showPasswordSecuritySheet(),
          ),
          _buildSettingsTile(
            Icons.swap_horiz_rounded,
            'Switch Account',
            onTap: () => _showSwitchAccountSheet(),
          ),
          const SizedBox(height: 24),

          // ── PREFERENCES ──
          _buildSectionHeader('PREFERENCES'),
          _buildToggleTile(
            Icons.notifications_none,
            'Push Notifications',
            value: settings.pushNotificationsEnabled,
            onChanged: (v) => settings.togglePushNotifications(v),
          ),
          _buildSettingsTile(
            Icons.language,
            'Language',
            trailingText: settings.language,
            onTap: () => _showLanguagePicker(settings),
          ),
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            trailingText: settings.themeMode,
            onTap: () => _showThemeModePicker(settings),
          ),
          const SizedBox(height: 24),

          // ── SUPPORT ──
          _buildSectionHeader('SUPPORT'),
          _buildSettingsTile(
            Icons.help_outline,
            'Help Center',
            onTap: () => _showHelpCenter(),
          ),
          _buildSettingsTile(
            Icons.message_outlined,
            'Contact Us',
            onTap: () => _showContactUs(),
          ),
          _buildSettingsTile(
            Icons.article_outlined,
            'Terms & Privacy Policy',
            onTap: () => _showTermsAndPrivacy(),
          ),
          const SizedBox(height: 24),

          // ── DANGER ZONE ──
          _buildSectionHeader('DANGER ZONE'),
          _buildDeleteAccountTile(),
          const SizedBox(height: 32),

          Center(
            child: Text(
              'Tale3 App Version 1.0.0',
              style: TextStyle(
                color: AppStyles.textTertiary,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  SECTION HEADER
  // ─────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppStyles.textTertiary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  STANDARD SETTINGS TILE
  // ─────────────────────────────────────────────────────────
  Widget _buildSettingsTile(
    IconData icon,
    String title, {
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppStyles.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppStyles.textTertiary),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  TOGGLE TILE (for Push Notifications)
  // ─────────────────────────────────────────────────────────
  Widget _buildToggleTile(
    IconData icon,
    String title, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppStyles.primaryColor,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE ACCOUNT TILE
  // ─────────────────────────────────────────────────────────
  Widget _buildDeleteAccountTile() {
    return Container(
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ),
        trailing:
            const Icon(Icons.chevron_right, color: AppStyles.textTertiary),
        onTap: () => _showDeleteAccountConfirmation(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  BOTTOM SHEET HELPERS
  // ═══════════════════════════════════════════════════════════

  /// Reusable drag handle + header for every bottom sheet.
  Widget _sheetHeader(String title) {
    return Column(
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppStyles.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Divider(),
      ],
    );
  }

  /// Primary action button used inside bottom sheets.
  Widget _sheetButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.darkMaroon,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Styled text field used inside bottom sheets.
  Widget _sheetTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
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
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFFBDBDBD), size: 20),
            suffixIcon: suffixIcon,
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

  /// Shows a snackbar with styled feedback.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  SWITCH ACCOUNT
  // ═══════════════════════════════════════════════════════════
  void _showSwitchAccountSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHeader('Switch Account'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F4),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.swap_horiz_rounded,
                        color: AppStyles.primaryColor, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'You will be signed out and taken back to the role selection screen.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppStyles.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sheetButton('Switch Account', () {
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const WelcomeScreen(),
                  ),
                  (route) => false,
                );
              }),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppStyles.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  1. PERSONAL INFORMATION
  // ═══════════════════════════════════════════════════════════
  void _showPersonalInfoSheet(AuthProvider auth) {
    _nameController.text = auth.userName;
    _emailController.text = auth.currentUser?.email ?? '';
    _phoneController.text = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
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
                _sheetHeader('Personal Information'),
                const SizedBox(height: 20),

                // Avatar
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppStyles.primaryColor, width: 2),
                        ),
                        child: const CircleAvatar(
                          backgroundColor: Color(0xFFE0E0E0),
                          child:
                              Icon(Icons.person, color: Colors.white, size: 40),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
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
                const SizedBox(height: 24),

                _sheetTextField(
                  controller: _nameController,
                  label: 'FULL NAME',
                  hint: 'Your full name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                _sheetTextField(
                  controller: _emailController,
                  label: 'EMAIL ADDRESS',
                  hint: 'name@example.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _sheetTextField(
                  controller: _phoneController,
                  label: 'PHONE NUMBER',
                  hint: '+966 5X XXX XXXX',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 28),

                _sheetButton('Save Changes', () {
                  Navigator.pop(ctx);
                  _showSnackBar('Personal information updated');
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  2. PASSWORD & SECURITY
  // ═══════════════════════════════════════════════════════════
  void _showPasswordSecuritySheet() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
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
                    _sheetHeader('Password & Security'),
                    const SizedBox(height: 20),

                    // Security icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFDF2F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_outline,
                          color: AppStyles.primaryColor, size: 28),
                    ),
                    const SizedBox(height: 24),

                    _sheetTextField(
                      controller: _currentPasswordController,
                      label: 'CURRENT PASSWORD',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscureCurrent,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        onPressed: () => setSheetState(
                            () => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sheetTextField(
                      controller: _newPasswordController,
                      label: 'NEW PASSWORD',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscureNew,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        onPressed: () =>
                            setSheetState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _sheetTextField(
                      controller: _confirmPasswordController,
                      label: 'CONFIRM NEW PASSWORD',
                      hint: '••••••••',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xFFBDBDBD),
                          size: 20,
                        ),
                        onPressed: () => setSheetState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _sheetButton('Update Password', () {
                      if (_newPasswordController.text.isEmpty ||
                          _currentPasswordController.text.isEmpty) {
                        _showSnackBar('Please fill in all fields',
                            isError: true);
                        return;
                      }
                      if (_newPasswordController.text !=
                          _confirmPasswordController.text) {
                        _showSnackBar('Passwords do not match',
                            isError: true);
                        return;
                      }
                      if (_newPasswordController.text.length < 6) {
                        _showSnackBar(
                            'Password must be at least 6 characters',
                            isError: true);
                        return;
                      }
                      Navigator.pop(ctx);
                      _showSnackBar('Password updated successfully');
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  3. LANGUAGE PICKER
  // ═══════════════════════════════════════════════════════════
  void _showLanguagePicker(SettingsProvider settings) {
    final languages = [
      {'code': 'English', 'native': 'English', 'flag': '🇺🇸'},
      {'code': 'العربية', 'native': 'Arabic', 'flag': '🇸🇦'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHeader('Select Language'),
              const SizedBox(height: 8),
              ...languages.map((lang) {
                final isSelected = settings.language == lang['code'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? const Color(0xFFFDF2F4)
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        settings.setLanguage(lang['code']!);
                        Navigator.pop(ctx);
                        _showSnackBar('Language set to ${lang['native']}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppStyles.primaryColor
                                : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!,
                                style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['native']!,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppStyles.primaryColor
                                          : AppStyles.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    lang['code']!,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppStyles.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppStyles.primaryColor, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  4. THEME MODE PICKER
  // ═══════════════════════════════════════════════════════════
  void _showThemeModePicker(SettingsProvider settings) {
    final modes = [
      {
        'mode': 'System',
        'icon': Icons.settings_suggest_outlined,
        'desc': 'Follow device settings'
      },
      {
        'mode': 'Light',
        'icon': Icons.light_mode_outlined,
        'desc': 'Always light theme'
      },
      {
        'mode': 'Dark',
        'icon': Icons.dark_mode_outlined,
        'desc': 'Always dark theme'
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHeader('Appearance'),
              const SizedBox(height: 8),
              ...modes.map((m) {
                final isSelected = settings.themeMode == m['mode'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? const Color(0xFFFDF2F4)
                        : const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        settings.setThemeMode(m['mode'] as String);
                        Navigator.pop(ctx);
                        _showSnackBar(
                            'Theme set to ${m['mode']}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppStyles.primaryColor
                                : const Color(0xFFE0E0E0),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppStyles.primaryColor
                                        .withValues(alpha: 0.1)
                                    : const Color(0xFFF0F0F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                m['icon'] as IconData,
                                color: isSelected
                                    ? AppStyles.primaryColor
                                    : AppStyles.textSecondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m['mode'] as String,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? AppStyles.primaryColor
                                          : AppStyles.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    m['desc'] as String,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppStyles.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_circle,
                                  color: AppStyles.primaryColor, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  5. HELP CENTER
  // ═══════════════════════════════════════════════════════════
  void _showHelpCenter() {
    final faqs = [
      {
        'q': 'How do I book a ride?',
        'a':
            'Go to the Home tab, enter your destination and departure city, choose a date, and browse available rides. Tap "Book Now" on the ride you prefer.',
      },
      {
        'q': 'How do I become a driver?',
        'a':
            'Sign out, choose "Driver" on the role selection screen, and complete the registration form including vehicle details and ID verification.',
      },
      {
        'q': 'Can I cancel a booked ride?',
        'a':
            'Yes. Go to My Trips, select the trip, and tap "Cancel Trip". Note that late cancellations may affect your rating.',
      },
      {
        'q': 'How are payments handled?',
        'a':
            'Currently Tale3 supports cash payments between riders and drivers. In-app payment will be available soon.',
      },
      {
        'q': 'How do I report an issue?',
        'a':
            'Use the "Contact Us" option in Settings or email us at support@tale3.app.',
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _sheetHeader('Help Center'),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: faqs.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        return _FaqTile(
                          question: faqs[i]['q']!,
                          answer: faqs[i]['a']!,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  6. CONTACT US
  // ═══════════════════════════════════════════════════════════
  void _showContactUs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).padding.bottom;
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: bottomInset + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHeader('Contact Us'),
                const SizedBox(height: 16),

                // Illustration
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDF2F4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.headset_mic_outlined,
                      color: AppStyles.primaryColor, size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'We\'d love to hear from you',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppStyles.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                _contactRow(Icons.email_outlined, 'Email', 'support@tale3.app'),
                const SizedBox(height: 12),
                _contactRow(Icons.phone_outlined, 'Phone', '+966 50 000 0000'),
                const SizedBox(height: 12),
                _contactRow(Icons.access_time, 'Hours', 'Sun \u2013 Thu, 9 AM \u2013 6 PM'),
                const SizedBox(height: 24),

                _sheetButton('Send us a Message', () {
                  Navigator.pop(ctx);
                  _showSnackBar('Opening message composer\u2026');
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contactRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11,
                    color: AppStyles.textTertiary,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 14,
                    color: AppStyles.textPrimary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  7. TERMS & PRIVACY POLICY
  // ═══════════════════════════════════════════════════════════
  void _showTermsAndPrivacy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _sheetHeader('Terms & Privacy Policy'),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: const [
                        SizedBox(height: 16),
                        _PolicySection(
                          title: '1. Terms of Service',
                          body:
                              'By using Tale3, you agree to these terms. Tale3 provides a carpooling platform connecting drivers and passengers for shared rides. Users must be at least 18 years old and hold a valid government-issued ID to use the service.',
                        ),
                        _PolicySection(
                          title: '2. User Responsibilities',
                          body:
                              'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate information during registration and to keep your profile up to date. Any misuse of the platform may result in account suspension.',
                        ),
                        _PolicySection(
                          title: '3. Ride Policies',
                          body:
                              'Drivers must hold a valid driving license and vehicle registration. Both parties should confirm ride details before departure. Cancellations within 30 minutes of the scheduled pickup may affect your reliability score.',
                        ),
                        _PolicySection(
                          title: '4. Privacy Policy',
                          body:
                              'We collect personal information such as name, email, phone number, and location data to operate our services. Your data is encrypted and stored securely. We do not sell your personal information to third parties.',
                        ),
                        _PolicySection(
                          title: '5. Data Usage',
                          body:
                              'Location data is used solely for ride matching and navigation. Usage analytics help us improve the app experience. You can request data deletion by contacting support@tale3.app.',
                        ),
                        _PolicySection(
                          title: '6. Limitation of Liability',
                          body:
                              'Tale3 acts as a platform connecting drivers and passengers. We are not responsible for the conduct of users during rides. Users participate in rides at their own risk.',
                        ),
                        _PolicySection(
                          title: '7. Contact',
                          body:
                              'For questions regarding these terms or your privacy, please contact us at legal@tale3.app or call +966 50 000 0000.',
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Last updated: April 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppStyles.textTertiary,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  8. DELETE ACCOUNT CONFIRMATION
  // ═══════════════════════════════════════════════════════════
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF0F0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Account',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.textPrimary),
              ),
            ],
          ),
          content: const Text(
            'This action is permanent and cannot be undone. All your data, ride history, and ratings will be permanently removed.',
            style: TextStyle(
                fontSize: 14,
                color: AppStyles.textSecondary,
                height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                    color: AppStyles.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // close dialog
                context.read<AuthProvider>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (_) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Delete',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  HELPER WIDGETS (private to this file)
// ═══════════════════════════════════════════════════════════

/// Expandable FAQ tile used in Help Center.
class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _expanded ? const Color(0xFFFDF2F4) : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded ? AppStyles.primaryColor : const Color(0xFFE0E0E0),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _expanded
                              ? AppStyles.primaryColor
                              : AppStyles.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _expanded
                            ? AppStyles.primaryColor
                            : AppStyles.textTertiary,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.answer,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppStyles.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                  crossFadeState: _expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Section block used in Terms & Privacy Policy.
class _PolicySection extends StatelessWidget {
  final String title;
  final String body;
  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppStyles.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: AppStyles.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
