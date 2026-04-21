import 'package:testtale3/theme/app_styles.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/passenger/passenger_verification_screen.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';

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

  // Step 1 controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Step 2 controllers
  final _universityController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
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
    _universityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 1:
        return 'Account Details';
      case 2:
        return 'Profile Details';
      default:
        return '';
    }
  }

  Future<void> _goNext() async {
    if (_currentStep < _totalSteps) {
      // Validate step 1 before advancing
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill in all fields to continue'),
            backgroundColor: AppStyles.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
      if (!email.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a valid email address'),
            backgroundColor: AppStyles.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
      if (password.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password must be at least 8 characters'),
            backgroundColor: AppStyles.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        return;
      }
      setState(() => _currentStep++);
      return;
    }

    // Step 2 — submit registration
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please accept the Terms of Service to continue'),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppStyles.primaryColor,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PassengerVerificationScreen(
              email: _emailController.text.trim(),
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
          'Passenger Registration',
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
                    _stepTitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textTertiary,
                    ),
                  ),
                  Text(
                    'Step $_currentStep of $_totalSteps',
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
                    ? 'Create your account'
                    : 'Tell us about yourself',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? 'Fill in your details to join the Tale3 community.'
                    : 'Just a couple more details to personalise your experience.',
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
        label: 'Full Name',
        controller: _nameController,
        hintText: 'John Doe',
        icon: Icons.person_outline,
      ),
      const SizedBox(height: 16),
      _buildLabeledTextField(
        label: 'Email Address',
        controller: _emailController,
        hintText: 'name@example.com',
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 16),

      // Password field
      Text(
        'Password',
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
      const SizedBox(height: 32),

      _buildNextButton(label: 'Continue', onPressed: _goNext),
      const SizedBox(height: 20),
      _buildLoginLink(),
      const SizedBox(height: 24),
    ];
  }

  List<Widget> _buildStep2() {
    return [
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
                    boxShadow: [
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
      _buildLabeledTextField(
        label: 'Phone Number',
        controller: _phoneController,
        hintText: '+966 5X XXX XXXX',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
      const SizedBox(height: 16),
      _buildDropdownField(
        label: 'Gender',
        hintText: 'Select gender',
        icon: Icons.people_outline,
        items: const ['Male', 'Female', 'Prefer not to say'],
        value: _selectedGender,
        onChanged: (val) => setState(() => _selectedGender = val),
      ),
      const SizedBox(height: 16),

      // University optional
      Row(
        children: [
          Text(
            'University / Workplace',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'OPTIONAL',
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
          hintText: 'Where do you commute to?',
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

      // Terms checkbox
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
                  TextSpan(text: 'By joining, I agree to Tale3\'s '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: AppStyles.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        color: AppStyles.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 32),

      _buildNextButton(
        label: 'Join as Passenger',
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
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Already have an account? ',
            style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const PassengerLoginScreen()),
            ),
            child: Text(
              'Log In',
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

  Widget _buildDropdownField({
    required String label,
    required String hintText,
    required IconData icon,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
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
        DropdownButtonFormField<String>(
          initialValue: value,
          onChanged: onChanged,
          items: items
              .map((e) => DropdownMenuItem(
                  value: e,
                  child:
                      Text(e, style: TextStyle(fontSize: 14))))
              .toList(),
          icon: Icon(Icons.keyboard_arrow_down,
              color: context.colors.textTertiary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                TextStyle(color: context.colors.inputHintColor, fontSize: 14),
            prefixIcon:
                Icon(icon, color: context.colors.textTertiary, size: 20),
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
