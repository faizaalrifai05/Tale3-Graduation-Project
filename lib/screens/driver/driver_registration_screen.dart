import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';
import 'package:testtale3/screens/driver/driver_id_verification_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  
  

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureConfirmPassword = true;

  bool _obscurePassword = true;
  bool _agreeToTerms = false;
  String? _selectedGender;
  DateTime? _selectedBirthday;

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = () => _showDialog(context.l10n.termsOfService, _termsContent);
    _privacyTap = TapGestureRecognizer()..onTap = () => _showDialog(context.l10n.privacyPolicy, _privacyContent);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary)),
        content: SingleChildScrollView(
          child: Text(content,
              style: TextStyle(
                  fontSize: 13,
                  color: context.colors.textDeep,
                  height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.close,
                style: TextStyle(
                    color: AppStyles.primaryColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  static const String _termsContent = '''
1. Acceptance of Terms
By registering as a driver on Tale3, you agree to be bound by these Terms of Service. If you do not agree, please do not use our platform.

2. Driver Responsibilities
As a driver, you are responsible for maintaining a valid driver's license, vehicle registration, and insurance. You must ensure your vehicle is in safe, roadworthy condition at all times.

3. Carpool Community Rules
Tale3 is a shared carpool community. You agree to treat all passengers with respect and courtesy. Discrimination, harassment, or inappropriate behavior of any kind is strictly prohibited.

4. Cost Sharing
Drivers may share trip costs with passengers at a fair and reasonable rate. Tale3 does not allow drivers to profit from rides — cost sharing must reflect actual fuel and trip expenses only.

5. Cancellations
Drivers are expected to honor confirmed bookings. Repeated cancellations without valid reason may result in account suspension.

6. Account Suspension
Tale3 reserves the right to suspend or permanently deactivate accounts that violate these terms, endanger safety, or engage in fraudulent activity.

7. Changes to Terms
We may update these terms from time to time. Continued use of the platform constitutes acceptance of any revised terms.''';

  static const String _privacyContent = '''
1. Information We Collect
We collect information you provide during registration (name, email, national ID, car details), as well as trip data, location information during active rides, and device information.

2. How We Use Your Information
Your information is used to operate the platform, match drivers with passengers, process trips, communicate important updates, and improve our services.

3. Location Data
We collect your location during active trips to facilitate ride matching and ensure safety. Location tracking is only active when you are using the app for a trip.

4. Data Sharing
We do not sell your personal data. We may share information with passengers for trip coordination purposes, and with authorities if required by law or to protect user safety.

5. Data Security
We implement industry-standard security measures to protect your personal information. However, no method of transmission over the internet is 100% secure.

6. Data Retention
We retain your data for as long as your account is active or as needed to provide services. You may request deletion of your account and associated data at any time.

7. Your Rights
You have the right to access, correct, or delete your personal information. To exercise these rights, contact our support team through the app.

8. Contact
If you have any questions about this Privacy Policy, please contact us through the in-app support feature.''';


  void _handleSubmit() {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.acceptTerms),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.selectGenderMsg),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverIdVerificationScreen(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.driverRegistration,
          style: TextStyle(
              color: context.colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(context.l10n.accountDetails,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textTertiary)),
                    Text('${context.l10n.step} 1 / 4',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppStyles.primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: context.colors.neutralLight,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 4,
                ),
                const SizedBox(height: 32),

                Text(context.l10n.joinTale3AsDriver,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  context.l10n.driverJoinDesc,
                  style: TextStyle(
                      fontSize: 14,
                      color: context.colors.textSecondary,
                      height: 1.5),
                ),
                const SizedBox(height: 32),

                // ── Full Name ────────────────────────────────────────────
                _buildLabel(context.l10n.fullName),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: Validators.fullName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                      hint: context.l10n.fullNameHint, icon: Icons.person_outline),
                ),
                const SizedBox(height: 16),

                // ── Gender ──────────────────────────────────────────────
                _buildLabel(context.l10n.gender),
                const SizedBox(height: 8),
                Row(
                  children: [context.l10n.genderMale, context.l10n.genderFemale].map((gender) {
                    final selected = _selectedGender == gender;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = gender),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: gender == context.l10n.genderMale ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppStyles.primaryColor.withValues(alpha: 0.08)
                                : context.colors.cardBackgroundColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppStyles.primaryColor
                                  : context.colors.borderColor,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                gender == context.l10n.genderMale
                                    ? Icons.male
                                    : Icons.female,
                                color: selected
                                    ? AppStyles.primaryColor
                                    : context.colors.textTertiary,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                gender,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppStyles.primaryColor
                                      : context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // ── Birthday ─────────────────────────────────────────────
                _buildLabel(context.l10n.dateOfBirth),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedBirthday ??
                          DateTime(DateTime.now().year - 20),
                      firstDate: DateTime(1950),
                      lastDate: DateTime(
                          DateTime.now().year - 18,
                          DateTime.now().month,
                          DateTime.now().day),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: AppStyles.primaryColor,
                            onPrimary: AppStyles.onPrimary,
                            surface: AppStyles.onPrimary,
                            onSurface: context.colors.textPrimary,
                          ),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setState(() => _selectedBirthday = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: context.colors.cardBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.cake_outlined,
                            color: context.colors.textTertiary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedBirthday == null
                              ? context.l10n.selectDateOfBirth
                              : '${_selectedBirthday!.day.toString().padLeft(2, '0')}/${_selectedBirthday!.month.toString().padLeft(2, '0')}/${_selectedBirthday!.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedBirthday == null
                                ? context.colors.inputHintColor
                                : context.colors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_outlined,
                            color: context.colors.textTertiary, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email ────────────────────────────────────────────────
                _buildLabel(context.l10n.emailAddress),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: context.l10n.emailHint, icon: Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // ── National ID ──────────────────────────────────────────
                _buildLabel(context.l10n.nationalId),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validators.nationalId,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: context.l10n.nationalIdHint, icon: Icons.badge_outlined),
                ),
                const SizedBox(height: 16),

                // ── Phone Number ─────────────────────────────────────────
                _buildLabel(context.l10n.phoneNumber),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.l10n.phoneRequired;
                    if (v.length < 10) return context.l10n.enterValidPhone;
                    return null;
                  },
                  decoration: _inputDecoration(
                      hint: '07XXXXXXXX', icon: Icons.phone_outlined),
                ),
                const SizedBox(height: 16),


                // ── Password ─────────────────────────────────────────────
                _buildLabel(context.l10n.passwordLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.registrationPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                        color: context.colors.inputHintColor,
                        fontSize: 14,
                        letterSpacing: 2),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: context.colors.textTertiary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: context.colors.cardBackgroundColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.colors.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.colors.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppStyles.primaryColor, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),

                // Password hint
                Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    context.l10n.passwordMinHint,
                    style: TextStyle(fontSize: 11, color: context.colors.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ──────────────────────────────────────
                _buildLabel(context.l10n.confirmPassword),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) return context.l10n.pleaseConfirmPassword;
                    if (v != _passwordController.text) return context.l10n.passwordsDoNotMatch;
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(
                        color: context.colors.inputHintColor,
                        fontSize: 14,
                        letterSpacing: 2),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: context.colors.textTertiary, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor: context.colors.cardBackgroundColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.colors.borderColor)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: context.colors.borderColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppStyles.primaryColor, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: Colors.red, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Terms ────────────────────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: (v) =>
                            setState(() => _agreeToTerms = v ?? false),
                        activeColor: AppStyles.primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 12,
                              color: context.colors.textSecondary,
                              height: 1.5),
                          children: [
                            TextSpan(text: context.l10n.termsAgreement),
                            TextSpan(
                              text: context.l10n.termsOfService,
                              recognizer: _termsTap,
                              style: const TextStyle(
                                  color: AppStyles.primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            TextSpan(text: context.l10n.and),
                            TextSpan(
                              text: context.l10n.privacyPolicy,
                              recognizer: _privacyTap,
                              style: const TextStyle(
                                  color: AppStyles.primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ── Submit Button ─────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.darkMaroon,
                      foregroundColor: AppStyles.onPrimary,
                      disabledBackgroundColor: context.colors.borderColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(context.l10n.joinAsDriver,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 32),

                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: context.colors.inputHintColor, fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: context.colors.textTertiary, size: 20)
          : null,
      filled: true,
      fillColor: context.colors.cardBackgroundColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.borderColor)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.borderColor)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppStyles.primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 1.5)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}