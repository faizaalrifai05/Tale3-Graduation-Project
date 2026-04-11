import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/validators.dart';
import 'package:testtale3/screens/driver/driver_id_verification_screen.dart';

class DriverRegistrationScreen extends StatefulWidget {
  const DriverRegistrationScreen({super.key});

  @override
  State<DriverRegistrationScreen> createState() =>
      _DriverRegistrationScreenState();
}

class _DriverRegistrationScreenState extends State<DriverRegistrationScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

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
    _termsTap = TapGestureRecognizer()..onTap = () => _showDialog('Terms of Service', _termsContent);
    _privacyTap = TapGestureRecognizer()..onTap = () => _showDialog('Privacy Policy', _privacyContent);
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A))),
        content: SingleChildScrollView(
          child: Text(content,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF424242),
                  height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close',
                style: TextStyle(
                    color: _primaryColor, fontWeight: FontWeight.w600)),
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
    // Terms must be accepted
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please accept the Terms of Service to continue'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    // Validate all fields
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const DriverIdVerificationScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Driver Registration',
          style: TextStyle(
              color: Color(0xFF1A1A1A),
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
                    const Text('Account Details',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9E9E9E))),
                    const Text('Step 1 of 4',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.25,
                  backgroundColor: const Color(0xFFEEEEEE),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(_primaryColor),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 4,
                ),
                const SizedBox(height: 32),

                const Text('Join Tale3 as a Driver',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 8),
                const Text(
                  'Start your journey with us and maximize your\nearnings today.',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                      height: 1.5),
                ),
                const SizedBox(height: 32),

                // ── Full Name ────────────────────────────────────────────
                _buildLabel('Full Name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  validator: Validators.fullName,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration(
                      hint: 'John Doe', icon: Icons.person_outline),
                ),
                const SizedBox(height: 16),

                // ── Gender ──────────────────────────────────────────────
                _buildLabel('Gender'),
                const SizedBox(height: 8),
                Row(
                  children: ['Male', 'Female'].map((gender) {
                    final selected = _selectedGender == gender;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = gender),
                        child: Container(
                          margin: EdgeInsets.only(
                              right: gender == 'Male' ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? _primaryColor.withValues(alpha: 0.08)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? _primaryColor
                                  : const Color(0xFFE0E0E0),
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                gender == 'Male'
                                    ? Icons.male
                                    : Icons.female,
                                color: selected
                                    ? _primaryColor
                                    : const Color(0xFF9E9E9E),
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                gender,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? _primaryColor
                                      : const Color(0xFF757575),
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
                _buildLabel('Date of Birth'),
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
                          colorScheme: const ColorScheme.light(
                            primary: _primaryColor,
                            onPrimary: Colors.white,
                            surface: Colors.white,
                            onSurface: Color(0xFF1A1A1A),
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
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cake_outlined,
                            color: Color(0xFF9E9E9E), size: 20),
                        const SizedBox(width: 12),
                        Text(
                          _selectedBirthday == null
                              ? 'Select your date of birth'
                              : '${_selectedBirthday!.day.toString().padLeft(2, '0')}/${_selectedBirthday!.month.toString().padLeft(2, '0')}/${_selectedBirthday!.year}',
                          style: TextStyle(
                            fontSize: 14,
                            color: _selectedBirthday == null
                                ? const Color(0xFFBDBDBD)
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined,
                            color: Color(0xFF9E9E9E), size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Email ────────────────────────────────────────────────
                _buildLabel('Email Address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: 'name@example.com', icon: Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // ── National ID ──────────────────────────────────────────
                _buildLabel('National ID Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nationalIdController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: Validators.nationalId,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: 'Enter ID number', icon: Icons.badge_outlined),
                ),
                const SizedBox(height: 16),

                // ── Phone Number ─────────────────────────────────────────
                _buildLabel('Phone Number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Phone number is required';
                    if (v.length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                  decoration: _inputDecoration(
                      hint: '07XXXXXXXX', icon: Icons.phone_outlined),
                ),
                const SizedBox(height: 16),


                // ── Password ─────────────────────────────────────────────
                _buildLabel('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: Validators.registrationPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 14,
                        letterSpacing: 2),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF9E9E9E), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9E9E9E),
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: _primaryColor, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.red, width: 1.5)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                  ),
                ),

                // Password hint
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Min. 8 characters, one uppercase letter and one number',
                    style: TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Confirm Password ──────────────────────────────────────
                _buildLabel('Confirm Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm your password';
                    if (v != _passwordController.text) return 'Passwords do not match';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(
                        color: Color(0xFFBDBDBD),
                        fontSize: 14,
                        letterSpacing: 2),
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: Color(0xFF9E9E9E), size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: const Color(0xFF9E9E9E),
                        size: 20,
                      ),
                      onPressed: () => setState(
                          () => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE0E0E0))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: _primaryColor, width: 2)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Colors.red)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
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
                        activeColor: _primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                              height: 1.5),
                          children: [
                            const TextSpan(text: 'By joining, I agree to Tale3\'s '),
                            TextSpan(
                              text: 'Terms of Service',
                              recognizer: _termsTap,
                              style: const TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            const TextSpan(text: ' and '),
                            TextSpan(
                              text: 'Privacy Policy',
                              recognizer: _privacyTap,
                              style: const TextStyle(
                                  color: _primaryColor,
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
                      backgroundColor: _darkMaroon,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('Join as Driver',
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
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A)),
    );
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
      prefixIcon: icon != null
          ? Icon(icon, color: const Color(0xFF9E9E9E), size: 20)
          : null,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}