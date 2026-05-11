import 'package:testtale3/theme/app_styles.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/utils/validators.dart';
import 'package:testtale3/screens/shared/email_verification_screen.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class PassengerRegistrationScreen extends StatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  State<PassengerRegistrationScreen> createState() =>
      _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState
    extends State<PassengerRegistrationScreen> {

  // Step tracking
  int _currentStep = 1;
  static const int _totalSteps = 2;
  bool _isLoading = false;
  String? _errorMessage;

  // Step 1 controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 2 controllers
  final _universityController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedBirthday;
  bool _agreeToTerms = false;
  File? _profilePhoto;

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _profilePhoto = File(picked.path));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _universityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _stepTitle(BuildContext context) {
    switch (_currentStep) {
      case 1:
        return context.l10n.accountDetails;
      case 2:
        return context.l10n.profileDetails;
      default:
        return '';
    }
  }

  Future<void> _goNext() async {
    setState(() => _errorMessage = null);

    if (_currentStep < _totalSteps) {
      // ── Step 1 validation ───────────────────────────────────────────
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        setState(() => _errorMessage = context.l10n.fillAllFields);
        return;
      }
      if (!email.contains('@')) {
        setState(() => _errorMessage = context.l10n.enterValidEmail);
        return;
      }
      final passwordError = Validators.registrationPassword(password);
      if (passwordError != null) {
        setState(() => _errorMessage = passwordError);
        return;
      }
      if (_confirmPasswordController.text != password) {
        setState(() => _errorMessage = context.l10n.passwordsDoNotMatch);
        return;
      }
      setState(() => _currentStep++);
      return;
    }

    // ── Step 2 validation ─────────────────────────────────────────────
    if (!_agreeToTerms) {
      setState(() => _errorMessage = context.l10n.acceptTerms);
      return;
    }

    // Phone validation
    final phoneError = Validators.phone(_phoneController.text.trim());
    if (phoneError != null) {
      setState(() => _errorMessage = phoneError);
      return;
    }

    // Birthday validation (18+)
    final birthdayError = Validators.birthday(_selectedBirthday);
    if (birthdayError != null) {
      setState(() => _errorMessage = birthdayError);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final error = await context
          .read<app_auth.AuthProvider>()
          .registerWithEmail(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            name: _nameController.text.trim(),
            role: UserRole.passenger,
            phone: _phoneController.text.trim(),
          );
      if (!mounted) return;
      if (error != null) {
        setState(() => _errorMessage = error);
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: _emailController.text.trim(),
              role: UserRole.passenger,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goBack() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
          onPressed: _goBack,
        ),
        title: Text(
          context.l10n.passengerRegistration,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _stepTitle(context),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textTertiary,
                    ),
                  ),
                  Text(
                    '${context.l10n.step} $_currentStep / $_totalSteps',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                backgroundColor: context.colors.dividerColor,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                _currentStep == 1
                    ? context.l10n.createYourAccount
                    : context.l10n.tellUsAboutYourself,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? context.l10n.fillInDetails
                    : context.l10n.fewMoreDetails,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form content per step
              if (_currentStep == 1) ..._buildStep1() else ..._buildStep2(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep1() {
    return [
      _buildLabeledTextField(
        label: context.l10n.fullName,
        controller: _nameController,
        hintText: context.l10n.fullNameHint,
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: context.l10n.emailAddress,
        controller: _emailController,
        hintText: context.l10n.emailHint,
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),

      // Password field
      Text(
        context.l10n.passwordLabel,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: context.colors.inputHintColor,
            fontSize: 14,
            letterSpacing: 2,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: context.colors.textTertiary,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: context.colors.textTertiary,
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: context.colors.cardBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 6, left: 4),
        child: Text(
          context.l10n.passwordMinHint,
          style: TextStyle(fontSize: 11, color: context.colors.textTertiary),
        ),
      ),
      const SizedBox(height: 16),

      // Confirm password field
      Text(
        context.l10n.confirmPassword,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: TextStyle(
            color: context.colors.inputHintColor,
            fontSize: 14,
            letterSpacing: 2,
          ),
          prefixIcon: Icon(
            Icons.lock_outline,
            color: context.colors.textTertiary,
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
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
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      if (_errorMessage != null) ...[
        const SizedBox(height: 8),
        _buildErrorBanner(_errorMessage!),
      ],
      const SizedBox(height: 16),

      _buildNextButton(label: context.l10n.continueBtn, onPressed: _goNext),
      const SizedBox(height: 20),
      _buildLoginLink(),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep2() {
    return [
      // Profile photo
      Center(
        child: GestureDetector(
          onTap: () => _pickImage(ImageSource.gallery),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.cardBackgroundColor,
                  border: Border.all(
                    color: _profilePhoto != null
                        ? AppStyles.primaryColor
                        : context.colors.borderColor,
                    width: 2,
                  ),
                ),
                child: _profilePhoto != null
                    ? ClipOval(
                        child: Image.file(_profilePhoto!,
                            fit: BoxFit.cover, width: 100, height: 100),
                      )
                    : Icon(Icons.person,
                        size: 50, color: context.colors.inputHintColor),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppStyles.primaryColor,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Icon(Icons.camera_alt,
                      size: 16, color: AppStyles.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),

      // ── Phone Number ─────────────────────────────────────────────────
      Text(
        context.l10n.phoneNumber,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          hintText: '07XXXXXXXX',
          hintStyle:
              TextStyle(color: context.colors.inputHintColor, fontSize: 13),
          prefixIcon: Icon(Icons.phone_outlined,
              color: context.colors.textTertiary, size: 20),
          filled: true,
          fillColor: context.colors.cardBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 16),

      // ── Gender selector ───────────────────────────────────────────────
      Text(
        context.l10n.gender,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
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

      // ── Date of Birth (18+) ───────────────────────────────────────────
      Text(
        context.l10n.dateOfBirth,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.textPrimary,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        onTap: () async {
          final today = DateTime.now();
          final picked = await showDatePicker(
            context: context,
            initialDate: _selectedBirthday ??
                DateTime(today.year - 20, today.month, today.day),
            firstDate: DateTime(1950),
            // lastDate = exactly 18 years ago today → enforces 18+
            lastDate: DateTime(today.year - 18, today.month, today.day),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: context.colors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              // Highlight red border if tried to submit without picking
              color: (_errorMessage != null && _selectedBirthday == null)
                  ? Colors.red
                  : context.colors.borderColor,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.cake_outlined,
                  color: context.colors.textTertiary, size: 20),
              const SizedBox(width: 12),
              Text(
                _selectedBirthday == null
                    ? context.l10n.selectDateOfBirth
                    : '${_selectedBirthday!.day.toString().padLeft(2, '0')}/'
                        '${_selectedBirthday!.month.toString().padLeft(2, '0')}/'
                        '${_selectedBirthday!.year}',
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

      // ── University (optional) ─────────────────────────────────────────
      Row(
        children: [
          Text(
            context.l10n.universityWorkplace,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            context.l10n.optional.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: context.colors.textTertiary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _universityController,
        decoration: InputDecoration(
          hintText: context.l10n.universityHint,
          hintStyle:
              TextStyle(color: context.colors.inputHintColor, fontSize: 14),
          prefixIcon: Icon(Icons.school_outlined,
              color: context.colors.textTertiary, size: 20),
          filled: true,
          fillColor: context.colors.cardBackgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: context.colors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      const SizedBox(height: 24),

      // ── Terms checkbox ────────────────────────────────────────────────
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
                    style: const TextStyle(
                        color: AppStyles.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: context.l10n.and),
                  TextSpan(
                    text: context.l10n.privacyPolicy,
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
      if (_errorMessage != null) ...[
        const SizedBox(height: 8),
        _buildErrorBanner(_errorMessage!),
      ],
      const SizedBox(height: 16),

      _buildNextButton(
        label: context.l10n.joinAsPassenger,
        onPressed: (_agreeToTerms && !_isLoading) ? _goNext : null,
        isLoading: _isLoading,
      ),
      const SizedBox(height: 20),
      _buildLoginLink(),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildNextButton(
      {required String label,
      required VoidCallback? onPressed,
      bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppStyles.darkMaroon,
          foregroundColor: AppStyles.onPrimary,
          disabledBackgroundColor: context.colors.borderColor,
          disabledForegroundColor: context.colors.textTertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: AppStyles.onPrimary, strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFB71C1C), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFB71C1C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${context.l10n.alreadyHaveAccountQ} ',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const PassengerLoginScreen()),
            ),
            child: Text(
              context.l10n.logIn,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppStyles.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                TextStyle(color: context.colors.inputHintColor, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: context.colors.textTertiary, size: 20)
                : null,
            filled: true,
            fillColor: context.colors.cardBackgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.colors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppStyles.primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}