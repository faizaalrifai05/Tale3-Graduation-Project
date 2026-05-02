import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import 'package:testtale3/screens/welcome_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/models/saved_account.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';
import 'package:testtale3/screens/driver/driver_login_screen.dart';
import 'package:testtale3/screens/choose_role_screen.dart';

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
      backgroundColor: context.colors.backgroundColor,
      appBar: AppBar(
        title: Text(
          context.l10n.settings,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: context.colors.surfaceColor,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 16),

          // ── ACCOUNT ──
          _buildSectionHeader(context.l10n.account),
          _buildSettingsTile(
            Icons.person_outline,
            context.l10n.personalInfo,
            onTap: () => _showPersonalInfoSheet(auth),
          ),
          _buildSettingsTile(
            Icons.security,
            context.l10n.passwordSecurity,
            onTap: () => _showPasswordSecuritySheet(),
          ),
          _buildSettingsTile(
            Icons.swap_horiz_rounded,
            context.l10n.switchAccount,
            onTap: () => _showSwitchAccountSheet(),
          ),
          const SizedBox(height: 24),

          // ── PREFERENCES ──
          _buildSectionHeader(context.l10n.preferences),
          _buildToggleTile(
            Icons.notifications_none,
            context.l10n.pushNotifications,
            value: settings.notificationsEnabled,
            onChanged: (v) => settings.toggleNotifications(v),
          ),
          _buildToggleTile(
            Icons.location_on_outlined,
            context.l10n.location,
            value: settings.locationEnabled,
            onChanged: (v) => settings.toggleLocation(v),
          ),
          _buildSettingsTile(
            Icons.language,
            context.l10n.language,
            trailingText: settings.languageLabel,
            onTap: () => _showLanguagePicker(settings),
          ),
          _buildSettingsTile(
            Icons.dark_mode_outlined,
            context.l10n.darkMode,
            trailingText: settings.themeModeLabel,
            onTap: () => _showThemeModePicker(settings),
          ),
          const SizedBox(height: 24),

          // ── SUPPORT ──
          _buildSectionHeader(context.l10n.support),
          _buildSettingsTile(
            Icons.help_outline,
            context.l10n.helpCenter,
            onTap: () => _showHelpCenter(),
          ),
          _buildSettingsTile(
            Icons.message_outlined,
            context.l10n.contactUs,
            onTap: () => _showContactUs(),
          ),
          _buildSettingsTile(
            Icons.article_outlined,
            context.l10n.termsPrivacy,
            onTap: () => _showTermsAndPrivacy(),
          ),
          const SizedBox(height: 24),

          // ── DANGER ZONE ──
          _buildSectionHeader(context.l10n.dangerZone),
          _buildDeleteAccountTile(),
          const SizedBox(height: 32),

          Center(
            child: Text(
              'Tale3 App Version 1.0.0',
              style: TextStyle(
                color: context.colors.textTertiary,
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.colors.textTertiary,
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
      color: context.colors.surfaceColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.inputFillColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.colors.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: context.colors.textTertiary),
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
      color: context.colors.surfaceColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.inputFillColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: context.colors.primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: context.colors.primaryColor,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  DELETE ACCOUNT TILE
  // ─────────────────────────────────────────────────────────
  Widget _buildDeleteAccountTile() {
    return Container(
      color: context.colors.surfaceColor,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.colors.errorLightBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              Icon(Icons.delete_outline, color: AppStyles.errorColor, size: 20),
        ),
        title: Text(
          context.l10n.deleteAccount,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppStyles.errorColor,
          ),
        ),
        trailing:
            Icon(Icons.chevron_right, color: context.colors.textTertiary),
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
            color: context.colors.borderColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Divider(),
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
          backgroundColor: context.colors.darkMaroon,
          foregroundColor: AppStyles.onPrimary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.colors.inputHintColor, fontSize: 14),
            prefixIcon: Icon(icon, color: context.colors.inputHintColor, size: 20),
            suffixIcon: suffixIcon,
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

  /// Shows a snackbar with styled feedback.
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppStyles.onPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor:
            isError ? AppStyles.errorColor : AppStyles.successDarkText,
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
  //  SWITCH ACCOUNT — multi-account sheet
  // ═══════════════════════════════════════════════════════════
  void _showSwitchAccountSheet() {
    final auth = context.read<AuthProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        // StatefulBuilder so we can rebuild the list after removing an account
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final accounts = auth.savedAccounts;
            final currentUid = auth.currentUser?.uid;

            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _sheetHeader(context.l10n.switchAccount),
                  const SizedBox(height: 4),

                  // ── Account list ───────────────────────────────────
                  if (accounts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        context.l10n.noSavedAccounts,
                        style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    )
                  else
                    ...accounts.map((account) {
                      final isCurrent = account.uid == currentUid;
                      return _buildAccountTile(
                        ctx: ctx,
                        account: account,
                        isCurrent: isCurrent,
                        onTap: isCurrent
                            ? null // already logged in — no action
                            : () => _switchToAccount(ctx, account),
                        onRemove: isCurrent
                            ? null // can't remove currently active account
                            : () {
                                auth.removeSavedAccount(account.uid);
                                setSheetState(() {});
                              },
                      );
                    }),

                  const SizedBox(height: 12),
                  Divider(),
                  const SizedBox(height: 8),

                  // ── Add new account ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _addNewAccount(ctx),
                      icon: const Icon(Icons.add),
                      label: Text(
                        context.l10n.addNewAccount,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.primaryColor,
                        side: BorderSide(
                            color: context.colors.primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Cancel ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        context.l10n.cancel,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textSecondary,
                        ),
                      ),
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

  // ── Single account tile ──────────────────────────────────────────────────
  Widget _buildAccountTile({
    required BuildContext ctx,
    required SavedAccount account,
    required bool isCurrent,
    required VoidCallback? onTap,
    required VoidCallback? onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isCurrent
            ? context.colors.highlightBackgroundColor
            : context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isCurrent
                    ? context.colors.primaryColor.withValues(alpha: 0.5)
                    : context.colors.borderColor,
                width: isCurrent ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(account),
                const SizedBox(width: 14),

                // Name + email + role chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              account.name,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildRoleChip(account.isDriver),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.email,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right side: checkmark if current, remove button otherwise
                if (isCurrent)
                  Icon(Icons.check_circle,
                      color: context.colors.primaryColor, size: 20)
                else if (onRemove != null)
                  IconButton(
                    icon: Icon(Icons.close,
                        size: 18, color: context.colors.textTertiary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Remove',
                    onPressed: onRemove,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Circle avatar with photo or initials fallback
  Widget _buildAvatar(SavedAccount account) {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppStyles.primaryColor.withValues(alpha: 0.12),
      backgroundImage: account.photoUrl.isNotEmpty
          ? NetworkImage(account.photoUrl)
          : null,
      child: account.photoUrl.isEmpty
          ? Text(
              account.initials,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppStyles.primaryColor,
              ),
            )
          : null,
    );
  }

  // Small role badge
  Widget _buildRoleChip(bool isDriver) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDriver
            ? AppStyles.primaryColor.withValues(alpha: 0.1)
            : AppStyles.successColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isDriver ? 'Driver' : 'Passenger',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDriver ? AppStyles.primaryColor : AppStyles.successDarkText,
        ),
      ),
    );
  }

  /// Sign out current user then navigate to the saved account's login screen.
  Future<void> _switchToAccount(BuildContext ctx, SavedAccount account) async {
    Navigator.pop(ctx); // close sheet
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => account.isDriver
            ? DriverLoginScreen(preFilledEmail: account.email)
            : PassengerLoginScreen(preFilledEmail: account.email),
      ),
      (route) => false,
    );
  }

  /// Sign out current user then go to role-choice screen to register/login fresh.
  Future<void> _addNewAccount(BuildContext ctx) async {
    Navigator.pop(ctx); // close sheet
    await context.read<AuthProvider>().signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChooseRoleScreen()),
      (route) => false,
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
      backgroundColor: context.colors.surfaceColor,
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
                _sheetHeader(context.l10n.personalInfo),
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
                              color: context.colors.primaryColor, width: 2),
                        ),
                        child:  CircleAvatar(
                          backgroundColor: context.colors.borderColor,
                          child:
                              Icon(Icons.person, color: AppStyles.onPrimary, size: 40),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.camera_alt,
                              color: AppStyles.onPrimary, size: 14),
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

                _sheetButton(context.l10n.saveChanges, () {
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
      backgroundColor: context.colors.surfaceColor,
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
                    _sheetHeader(context.l10n.passwordSecurity),
                    const SizedBox(height: 20),

                    // Security icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.colors.highlightBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_outline,
                          color: context.colors.primaryColor, size: 28),
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
                          color: context.colors.inputHintColor,
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
                          color: context.colors.inputHintColor,
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
                          color: context.colors.inputHintColor,
                          size: 20,
                        ),
                        onPressed: () => setSheetState(
                            () => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    const SizedBox(height: 28),

                    _sheetButton(context.l10n.updatePassword, () async {
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
                      final authProvider = context.read<AuthProvider>();
                      Navigator.pop(ctx);
                      final error = await authProvider.changePassword(
                        currentPassword: _currentPasswordController.text,
                        newPassword: _newPasswordController.text,
                      );
                      if (!mounted) return;
                      if (error != null) {
                        _showSnackBar(error, isError: true);
                      } else {
                        _showSnackBar('Password updated successfully');
                      }
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
      (locale: const Locale('en'), flag: '🇺🇸', label: 'English', native: 'English'),
      (locale: const Locale('ar'), flag: '🇸🇦', label: 'العربية', native: 'Arabic'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHeader(context.l10n.selectLanguage),
              const SizedBox(height: 8),
              ...languages.map((lang) {
                final isSelected = settings.locale == lang.locale;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? context.colors.highlightBackgroundColor
                        : context.colors.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        settings.setLocale(lang.locale);
                        Navigator.pop(ctx);
                        _showSnackBar('Language set to ${lang.native}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primaryColor
                                : context.colors.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang.flag, style: TextStyle(fontSize: 24)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? context.colors.primaryColor
                                          : context.colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    lang.native,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: context.colors.primaryColor, size: 22),
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
    final l10n = context.l10n;
    final modes = [
      (mode: ThemeMode.system, icon: Icons.settings_suggest_outlined,
       label: l10n.themeSystem, desc: l10n.themeSystemDesc),
      (mode: ThemeMode.light,  icon: Icons.light_mode_outlined,
       label: l10n.themeLight,  desc: l10n.themeLightDesc),
      (mode: ThemeMode.dark,   icon: Icons.dark_mode_outlined,
       label: l10n.themeDark,   desc: l10n.themeDarkDesc),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _sheetHeader(l10n.appearance),
              const SizedBox(height: 8),
              ...modes.map((m) {
                final isSelected = settings.themeMode == m.mode;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: isSelected
                        ? context.colors.highlightBackgroundColor
                        : context.colors.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        settings.setThemeMode(m.mode);
                        Navigator.pop(ctx);
                        _showSnackBar('Theme set to ${m.label}');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? context.colors.primaryColor
                                : context.colors.borderColor,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? context.colors.primaryColor
                                        .withValues(alpha: 0.1)
                                    : context.colors.cardBackgroundColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                m.icon,
                                color: isSelected
                                    ? context.colors.primaryColor
                                    : context.colors.textSecondary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.label,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? context.colors.primaryColor
                                          : context.colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    m.desc,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: context.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: context.colors.primaryColor, size: 22),
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
      backgroundColor: context.colors.surfaceColor,
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
                  _sheetHeader(context.l10n.helpCenter),
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
      backgroundColor: context.colors.surfaceColor,
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
                _sheetHeader(context.l10n.contactUs),
                const SizedBox(height: 16),

                // Illustration
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: context.colors.highlightBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.headset_mic_outlined,
                      color: context.colors.primaryColor, size: 28),
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'d love to hear from you',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                _contactRow(Icons.email_outlined, 'Email', 'support@tale3.app'),
                const SizedBox(height: 12),
                _contactRow(Icons.phone_outlined, 'Phone', '+966 50 000 0000'),
                const SizedBox(height: 12),
                _contactRow(Icons.access_time, 'Hours', 'Sun \u2013 Thu, 9 AM \u2013 6 PM'),
                const SizedBox(height: 24),

                _sheetButton(context.l10n.sendUsMessage, () {
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
        color: context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.colors.primaryColor, size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    fontSize: 11,
                    color: context.colors.textTertiary,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textPrimary,
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
      backgroundColor: context.colors.surfaceColor,
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
                  _sheetHeader(context.l10n.termsPrivacy),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 16),
                        const _PolicySection(
                          title: '1. Terms of Service',
                          body:
                              'By using Tale3, you agree to these terms. Tale3 provides a carpooling platform connecting drivers and passengers for shared rides. Users must be at least 18 years old and hold a valid government-issued ID to use the service.',
                        ),
                        const _PolicySection(
                          title: '2. User Responsibilities',
                          body:
                              'You are responsible for maintaining the confidentiality of your account credentials. You agree to provide accurate information during registration and to keep your profile up to date. Any misuse of the platform may result in account suspension.',
                        ),
                        const _PolicySection(
                          title: '3. Ride Policies',
                          body:
                              'Drivers must hold a valid driving license and vehicle registration. Both parties should confirm ride details before departure. Cancellations within 30 minutes of the scheduled pickup may affect your reliability score.',
                        ),
                        const _PolicySection(
                          title: '4. Privacy Policy',
                          body:
                              'We collect personal information such as name, email, phone number, and location data to operate our services. Your data is encrypted and stored securely. We do not sell your personal information to third parties.',
                        ),
                        const _PolicySection(
                          title: '5. Data Usage',
                          body:
                              'Location data is used solely for ride matching and navigation. Usage analytics help us improve the app experience. You can request data deletion by contacting support@tale3.app.',
                        ),
                        const _PolicySection(
                          title: '6. Limitation of Liability',
                          body:
                              'Tale3 acts as a platform connecting drivers and passengers. We are not responsible for the conduct of users during rides. Users participate in rides at their own risk.',
                        ),
                        const _PolicySection(
                          title: '7. Contact',
                          body:
                              'For questions regarding these terms or your privacy, please contact us at legal@tale3.app or call +966 50 000 0000.',
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            'Last updated: April 2026',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
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
    final passwordController = TextEditingController();
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
                decoration: BoxDecoration(
                  color: context.colors.errorLightBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.warning_amber_rounded,
                    color: AppStyles.errorColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.deleteAccount,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This action is permanent and cannot be undone. All your data, ride history, and ratings will be permanently removed.',
                style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password to confirm',
                  labelStyle:
                      TextStyle(fontSize: 13, color: context.colors.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                context.l10n.cancel,
                style: TextStyle(
                    color: context.colors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final password = passwordController.text;
                Navigator.pop(ctx);
                final error = await context
                    .read<AuthProvider>()
                    .deleteAccount(password: password.isNotEmpty ? password : null);
                if (!mounted) return;
                if (error != null) {
                  _showSnackBar(error, isError: true);
                } else {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.errorColor,
                foregroundColor: AppStyles.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Text(context.l10n.delete,
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
        color: _expanded ? context.colors.highlightBackgroundColor : context.colors.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded ? context.colors.primaryColor : context.colors.borderColor,
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
                              ? context.colors.primaryColor
                              : context.colors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: _expanded
                            ? context.colors.primaryColor
                            : context.colors.textTertiary,
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
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textSecondary,
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
