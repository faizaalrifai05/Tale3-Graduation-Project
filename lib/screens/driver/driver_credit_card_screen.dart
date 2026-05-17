import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/shared/email_verification_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverCreditCardScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String gender;

  const DriverCreditCardScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.gender = '',
  });

  @override
  State<DriverCreditCardScreen> createState() => _DriverCreditCardScreenState();
}

class _DriverCreditCardScreenState extends State<DriverCreditCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  bool _isLoading = false;
  bool _obscureNumber = true;
  bool _obscureCvc = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<app_auth.AuthProvider>();

      // Save credit card to Firestore
      await auth.saveCreditCard(
        cardNumber: _cardNumberController.text.trim(),
        cardHolder: _cardHolderController.text.trim(),
        expiry: _expiryController.text.trim(),
        cvc: _cvcController.text.trim(),
      );
      if (!mounted) return;

      // Navigate to email verification
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: widget.email,
            role: UserRole.driver,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _skipForNow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmailVerificationScreen(
          email: widget.email,
          role: UserRole.driver,
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
          'Payment Details',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
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
                    Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    Text(
                      '${context.l10n.step} 5 ${context.l10n.ofWord} 5',
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
                  value: 1.0,
                  backgroundColor: context.colors.neutralLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppStyles.primaryColor),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 4,
                ),
                const SizedBox(height: 32),

                Text(
                  'Add Your Credit Card',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tale3 collects a small monthly percentage from driver earnings. Your card is stored securely for this purpose only.',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Info banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppStyles.primaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppStyles.primaryColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppStyles.primaryColor, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The app is cash-only between drivers and passengers. This card is only used for our platform fee.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppStyles.primaryColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Visual card preview
                _CardPreview(
                  number: _cardNumberController.text,
                  holder: _cardHolderController.text,
                  expiry: _expiryController.text,
                  cvc: _cvcController.text,
                  obscure: _obscureNumber,
                ),
                const SizedBox(height: 32),

                // Card Number
                _buildLabel('CARD NUMBER'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  obscureText: _obscureNumber,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(16),
                    _CardNumberFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Card number is required';
                    final digits = v.replaceAll(' ', '');
                    if (digits.length != 16) return 'Enter a valid 16-digit card number';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    hint: '•••• •••• •••• ••••',
                    icon: Icons.credit_card_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureNumber
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNumber = !_obscureNumber),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cardholder Name
                _buildLabel('CARDHOLDER NAME'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cardHolderController,
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Cardholder name is required';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    hint: 'NAME AS ON CARD',
                    icon: Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 16),

                // Expiry
                _buildLabel('EXPIRY DATE'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _expiryController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Expiry date is required';
                    final parts = v.split('/');
                    if (parts.length != 2) return 'Enter MM/YY format';
                    final month = int.tryParse(parts[0]);
                    if (month == null || month < 1 || month > 12) return 'Invalid month';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    hint: 'MM/YY',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(height: 16),

                // CVC
                _buildLabel('CVC / CVV'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _cvcController,
                  keyboardType: TextInputType.number,
                  obscureText: _obscureCvc,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'CVC is required';
                    if (v.length < 3) return 'Enter a valid 3 or 4-digit CVC';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                    hint: '•••',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      icon: Icon(
                        _obscureCvc
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: context.colors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCvc = !_obscureCvc),
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Save & Continue button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.darkMaroon,
                      foregroundColor: AppStyles.onPrimary,
                      disabledBackgroundColor: context.colors.borderColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: AppStyles.onPrimary, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.lock_outline, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Save & Continue',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip for now
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    onPressed: _skipForNow,
                    child: Text(
                      'Skip for now — add later in settings',
                      style: TextStyle(
                        fontSize: 13,
                        color: context.colors.textTertiary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: context.colors.textTertiary,
            letterSpacing: 1),
      );

  InputDecoration _inputDecoration(
      {required String hint, IconData? icon, Widget? suffix}) =>
      InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: context.colors.inputHintColor, fontSize: 14),
        prefixIcon: icon != null
            ? Icon(icon, color: context.colors.textTertiary, size: 20)
            : null,
        suffixIcon: suffix,
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
            borderSide:
                const BorderSide(color: AppStyles.primaryColor, width: 2)),
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

// ── Visual Card Preview ──────────────────────────────────────────────────────
class _CardPreview extends StatelessWidget {
  final String number;
  final String holder;
  final String expiry;
  final String cvc;
  final bool obscure;

  const _CardPreview({
    required this.number,
    required this.holder,
    required this.expiry,
    required this.cvc,
    required this.obscure,
  });

  @override
  Widget build(BuildContext context) {
    final displayNumber = obscure
        ? '•••• •••• •••• ${number.replaceAll(' ', '').length >= 4 ? number.replaceAll(' ', '').substring(number.replaceAll(' ', '').length - 4) : '••••'}'
        : (number.isEmpty ? '•••• •••• •••• ••••' : number);
    final displayHolder =
        holder.isEmpty ? 'YOUR NAME' : holder.toUpperCase();
    final displayExpiry = expiry.isEmpty ? 'MM/YY' : expiry;

    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppStyles.primaryColor, AppStyles.darkMaroon],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppStyles.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TALE3',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              Icon(Icons.credit_card_rounded,
                  color: Colors.white.withValues(alpha: 0.7), size: 32),
            ],
          ),
          const Spacer(),
          Text(
            displayNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 9,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    displayHolder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'EXPIRES',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        displayExpiry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'CVC',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        cvc.isEmpty ? '•••' : '•' * cvc.length,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Input formatters ─────────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(RegExp(r'\D'), '');
    String str = digits;
    if (digits.length >= 2) {
      str = '${digits.substring(0, 2)}/${digits.substring(2)}';
    }
    return newVal.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}