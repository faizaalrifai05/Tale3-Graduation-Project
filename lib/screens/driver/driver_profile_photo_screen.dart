import 'package:testtale3/theme/app_styles.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testtale3/screens/driver/driver_home_screen.dart';

class DriverProfilePhotoScreen extends StatefulWidget {
  const DriverProfilePhotoScreen({super.key});

  @override
  State<DriverProfilePhotoScreen> createState() => _DriverProfilePhotoScreenState();
}

class _DriverProfilePhotoScreenState extends State<DriverProfilePhotoScreen> {
  
  

  File? _photo;

  Future<void> _pickImage(ImageSource source) async {
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _photo = File(picked.path));
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DriverHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppStyles.primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Step indicator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Step 2 of 2',
                    style: TextStyle(fontSize: 12, color: context.colors.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    'SETTING UP YOUR PROFILE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: context.colors.inputHintColor,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 24),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // Avatar circle
                    GestureDetector(
                      onTap: () => _pickImage(ImageSource.gallery),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.colors.cardBackgroundColor,
                              border: Border.all(
                                color: _photo != null
                                    ? AppStyles.primaryColor
                                    : context.colors.borderColor,
                                width: 2,
                              ),
                            ),
                            child: _photo != null
                                ? ClipOval(
                                    child: Image.file(_photo!,
                                        fit: BoxFit.cover,
                                        width: 120,
                                        height: 120),
                                  )
                                : Icon(Icons.person,
                                    size: 60, color: context.colors.inputHintColor),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppStyles.primaryColor,
                              ),
                              child: Icon(Icons.camera_alt,
                                  size: 16, color: AppStyles.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    Text(
                      'Add a Profile Photo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add a clear photo of yourself to help\ndrivers identify you. This builds trust in\nthe community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: context.colors.textSecondary,
                          height: 1.5),
                    ),

                    const Spacer(flex: 2),

                    // Take Photo
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: Icon(Icons.camera_alt_outlined, size: 20),
                        label: Text('Take Photo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.darkMaroon,
                          foregroundColor: AppStyles.onPrimary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Upload from Gallery
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        icon: Icon(Icons.image_outlined, size: 20),
                        label: Text('Upload from Gallery',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.colors.textPrimary,
                          side: BorderSide(
                              color: context.colors.borderColor, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skip
                    TextButton(
                      onPressed: _goToHome,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                            fontSize: 14, color: context.colors.textTertiary),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Continue (only enabled if photo selected)
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _photo != null ? _goToHome : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.textPrimary,
                          foregroundColor: AppStyles.onPrimary,
                          disabledBackgroundColor: context.colors.borderColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: Text('Continue',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
