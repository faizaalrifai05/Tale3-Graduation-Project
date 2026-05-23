import 'dart:io';
import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/auth_provider.dart' as app_auth;
import 'package:testtale3/screens/driver/driver_credit_card_screen.dart';
import 'package:testtale3/l10n/app_localizations.dart';

// ignore_for_file: use_build_context_synchronously

class DriverCarPhotosScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;
  final String gender;
  final File? frontIdImage;
  final File? backIdImage;

  const DriverCarPhotosScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.gender = '',
    this.frontIdImage,
    this.backIdImage,
  });

  @override
  State<DriverCarPhotosScreen> createState() => _DriverCarPhotosScreenState();
}

class _DriverCarPhotosScreenState extends State<DriverCarPhotosScreen> {
  File? _frontCarImage;
  File? _backCarImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isFront) async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 25, maxWidth: 800);
    if (picked != null && mounted) {
      setState(() {
        if (isFront) {
          _frontCarImage = File(picked.path);
        } else {
          _backCarImage = File(picked.path);
        }
      });
    }
  }

  Future<ImageSource?> _showSourceDialog() async {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: context.colors.borderColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppStyles.primaryColor),
              title: Text(context.l10n.takePhoto),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppStyles.primaryColor),
              title: Text(context.l10n.chooseFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_frontCarImage == null || _backCarImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please upload both car photos to continue.'),
          backgroundColor: AppStyles.primaryColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = context.read<app_auth.AuthProvider>();

      // ── Step 1: Attempt car photo upload (best-effort) ──────────────────
      // Firebase Storage may be disabled. We log the error but never return
      // early — the driver must always reach the "pending" status write below.
      if (_frontCarImage != null && _backCarImage != null) {
        final carError = await auth.submitCarPhotos(
          frontImage: _frontCarImage!,
          backImage: _backCarImage!,
        );
        if (!mounted) return;
        if (carError != null) {
          debugPrint('⚠️ Car photo upload skipped (Storage may be disabled): $carError');
        }
      }

      // ── Step 2: Attempt ID photo upload OR just mark pending ─────────────
      // Either way, verificationStatus MUST be written as 'pending' so the
      // driver appears in the admin verification queue.
      if (widget.frontIdImage != null && widget.backIdImage != null) {
        final verifyError = await auth.submitIdVerification(
          frontImage: widget.frontIdImage!,
          backImage: widget.backIdImage!,
        );
        if (!mounted) return;
        if (verifyError != null) {
          // submitIdVerification already calls setVerificationPending internally
          // on Firestore — log only, do not block navigation.
          debugPrint('⚠️ ID verification upload skipped: $verifyError');
        }
      } else {
        // ID images are no longer in memory (e.g. resumed flow) — write pending directly.
        await auth.setVerificationPending();
        if (!mounted) return;
      }

      // ── Step 3: Navigate to credit card screen ───────────────────────────
      final authUser = context.read<app_auth.AuthProvider>().currentUser;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DriverCreditCardScreen(
            name: widget.name.isNotEmpty ? widget.name : (authUser?.name ?? ''),
            email: widget.email.isNotEmpty ? widget.email : (authUser?.email ?? ''),
            password: widget.password,
            phone: widget.phone.isNotEmpty ? widget.phone : (authUser?.phone ?? ''),
            gender: widget.gender.isNotEmpty ? widget.gender : (authUser?.gender ?? ''),
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
          'Car Photos',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Car Verification',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textTertiary),
                  ),
                  Text(
                    '${context.l10n.step} 4 ${context.l10n.ofWord} 5',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppStyles.primaryColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.8,
                backgroundColor: context.colors.neutralLight,
                valueColor: const AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              Text(
                'Verify Your Vehicle',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload clear photos of the front and back of your car so we can verify your vehicle.',
                style: TextStyle(
                    fontSize: 14, color: context.colors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),

              // Front of car
              Text(
                'FRONT OF CAR',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              _buildUploadCard(
                isFront: true,
                image: _frontCarImage,
                title: 'Upload Front Photo',
                subtitle: 'JPG or PNG, clear and well-lit',
                icon: Icons.directions_car_rounded,
              ),
              const SizedBox(height: 24),

              // Back of car
              Text(
                'BACK OF CAR',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                    letterSpacing: 1),
              ),
              const SizedBox(height: 12),
              _buildUploadCard(
                isFront: false,
                image: _backCarImage,
                title: 'Upload Back Photo',
                subtitle: 'JPG or PNG, plate must be visible',
                icon: Icons.directions_car_filled_rounded,
              ),
              const SizedBox(height: 32),

              // Tips box
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.colors.highlightBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo Tips',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryColor),
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Park on a flat, well-lit surface'),
                    _buildTip('Make sure the license plate is clearly visible'),
                    _buildTip('Include the full car in the frame'),
                    _buildTip('Avoid shadows and glare on the car'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

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
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  context.l10n.sslEncrypted,
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: context.colors.inputHintColor,
                      letterSpacing: 1),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadCard({
    required bool isFront,
    required File? image,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          color: context.colors.inputFillColor,
          border: Border.all(
            color: image != null ? AppStyles.primaryColor : context.colors.borderColor,
            width: image != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image, fit: BoxFit.cover),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppStyles.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.check, color: AppStyles.onPrimary, size: 14),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            context.l10n.tapToChange,
                            style: TextStyle(
                                color: AppStyles.onPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: AppStyles.primaryColor, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11, color: context.colors.textTertiary)),
                ],
              ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle, color: AppStyles.primaryColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: context.colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}