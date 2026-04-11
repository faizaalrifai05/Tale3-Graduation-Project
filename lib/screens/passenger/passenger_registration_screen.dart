import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testtale3/screens/profile_photo_screen.dart';
import 'package:testtale3/screens/passenger/passenger_login_screen.dart';

class PassengerRegistrationScreen extends StatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  State<PassengerRegistrationScreen> createState() =>
      _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState
    extends State<PassengerRegistrationScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);

  // Step tracking
  int _currentStep = 1;
  static const int _totalSteps = 2;

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

  void _goNext() {
    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ProfilePhotoScreen()),
      );
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: _goBack,
        ),
        title: const Text(
          'Passenger Registration',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  Text(
                    'Step $_currentStep of $_totalSteps',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _currentStep / _totalSteps,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                _currentStep == 1
                    ? 'Create your account'
                    : 'Tell us about yourself',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? 'Fill in your details to join the Tale3 community.'
                    : 'Just a couple more details to personalise your experience.',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
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
      const Text(
        'Password',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A1A),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: '••••••••',
          hintStyle: const TextStyle(
            color: Color(0xFFBDBDBD),
            fontSize: 14,
            letterSpacing: 2,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF9E9E9E),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: const Color(0xFF9E9E9E),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
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
          const Text(
            'University / Workplace',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'OPTIONAL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
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
              const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
          prefixIcon: const Icon(Icons.school_outlined,
              color: Color(0xFF9E9E9E), size: 20),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primaryColor, width: 2),
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
              activeColor: _primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                    height: 1.5),
                children: [
                  TextSpan(text: 'By joining, I agree to Tale3\'s '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: _primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        color: _primaryColor,
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
        onPressed: _agreeToTerms ? _goNext : null,
      ),
      const SizedBox(height: 20),
      _buildLoginLink(),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildNextButton(
      {required String label, required VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C0A1A),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE0E0E0),
          disabledForegroundColor: const Color(0xFF9E9E9E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, size: 18),
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
          const Text(
            'Already have an account? ',
            style: TextStyle(fontSize: 13, color: Color(0xFF757575)),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (context) => const PassengerLoginScreen()),
            ),
            child: const Text(
              'Log In',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _primaryColor,
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
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
                const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: const Color(0xFF9E9E9E), size: 20)
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _primaryColor, width: 2),
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
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A),
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
                      Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Color(0xFF9E9E9E)),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle:
                const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
            prefixIcon:
                Icon(icon, color: const Color(0xFF9E9E9E), size: 20),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
