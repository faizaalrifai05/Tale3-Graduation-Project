import 'dart:io';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/models/user_model.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/driver/driver_credit_card_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

class DriverVehicleDetailsScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final File frontIdImage;
  final File backIdImage;

  const DriverVehicleDetailsScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.gender = '',
    required this.frontIdImage,
    required this.backIdImage,
  });

  @override
  State<DriverVehicleDetailsScreen> createState() =>
      _DriverVehicleDetailsScreenState();
}

class _DriverVehicleDetailsScreenState
    extends State<DriverVehicleDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<app_auth.AuthProvider>();

      // Step 1: Create the Firebase account
      final error = await authProvider.registerWithEmail(
        email: widget.email,
        password: widget.password,
        name: widget.name,
        role: UserRole.driver,
        phone: widget.phone,
        gender: widget.gender,
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
        return;
      }

      // Step 2: Save vehicle details now that the account exists
      await authProvider.saveVehicleDetails(
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim(),
        color: _colorController.text.trim(),
        plateNumber: _plateController.text.trim(),
      );
      if (!mounted) return;

      // Step 3: Submit verification — sets verificationStatus to 'pending'
      // in Firestore so admin can see the driver in the verification queue.
      // No Firebase Storage needed — photos are stored locally only.
      final verifyError = await authProvider.submitIdVerification(
        frontImage: widget.frontIdImage,
        backImage: widget.backIdImage,
      );
      if (!mounted) return;
      if (verifyError != null) {
        // Log the error but don't block navigation
        // Driver can retry verification from their profile
        debugPrint('Verification submission error: $verifyError');
      }

      // Navigate to credit card screen (step 4 of 5)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverCreditCardScreen(
            name: widget.name,
            email: widget.email,
            password: widget.password,
            phone: widget.phone,
            gender: widget.gender,
            frontIdImage: widget.frontIdImage,
            backIdImage: widget.backIdImage,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
          context.l10n.vehicleDetails,
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
                      context.l10n.onboardingProgress,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textTertiary,
                      ),
                    ),
                    Text(
                      '${context.l10n.step} 3 ${context.l10n.ofWord} 5',
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
                  value: 0.6,
                  backgroundColor: context.colors.neutralLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      AppStyles.primaryColor),
                  borderRadius: BorderRadius.circular(2),
                  minHeight: 4,
                ),
                const SizedBox(height: 32),

                Text(
                  context.l10n.tellUsAboutVehicle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.provideVehicleDetails,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // Car Make
                _buildLabel(context.l10n.carMake),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _makeController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.carMakeRequired
                      : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: context.l10n.carMakeHint,
                      icon: Icons.directions_car_outlined),
                ),
                const SizedBox(height: 16),

                // Car Model
                _buildLabel(context.l10n.carModel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _modelController,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? context.l10n.carModelRequired
                      : null,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: context.l10n.carModelHint, icon: Icons.car_repair),
                ),
                const SizedBox(height: 16),

                // Year + Color row
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context.l10n.year),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return context.l10n.required;
                              }
                              final y = int.tryParse(v);
                              if (y == null ||
                                  y < 1990 ||
                                  y > DateTime.now().year + 1) {
                                return context.l10n.invalidYear;
                              }
                              return null;
                            },
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration: _inputDecoration(hint: 'YYYY'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(context.l10n.colorLabel),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _colorController,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.required
                                : null,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            decoration:
                                _inputDecoration(hint: context.l10n.colorHint),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Plate Number
                _buildLabel(context.l10n.plateNumber),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _plateController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    // Allow digits and dot/dash separator only
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]')),
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return context.l10n.plateRequired;
                    }
                    final cleaned = v.trim();
                    // Jordanian plate: digits · dot or dash · digits
                    // e.g. 58-11772 or 12.34567 or 70-23456
                    final valid = RegExp(
                      r'^[0-9]{1,4}[.\-][0-9]{1,6}$',
                    ).hasMatch(cleaned);
                    if (!valid) {
                      return 'Enter a valid plate (e.g. 58-11772 or 12.34567)';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: _inputDecoration(
                      hint: '58-11772',
                      icon: Icons.credit_card_outlined),
                ),
                const SizedBox(height: 48),

                // Next Button
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
                              Text(context.l10n.nextStep,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 32),
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
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary),
      );

  InputDecoration _inputDecoration({required String hint, IconData? icon}) =>
      InputDecoration(
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