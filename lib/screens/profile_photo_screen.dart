import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testtale3/screens/passenger/passenger_home_screen.dart';

class ProfilePhotoScreen extends StatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  State<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends State<ProfilePhotoScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

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
      MaterialPageRoute(builder: (_) => const PassengerHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: _primaryColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Profile Photo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
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
                  const Text(
                    'Step 2 of 2',
                    style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                  ),
                  const Spacer(),
                  Text(
                    'SETTING UP YOUR PROFILE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[400],
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 24),

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
                              color: const Color(0xFFF5F5F5),
                              border: Border.all(
                                color: _photo != null
                                    ? _primaryColor
                                    : const Color(0xFFE0E0E0),
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
                                : const Icon(Icons.person,
                                    size: 60, color: Color(0xFFBDBDBD)),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _primaryColor,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    const Text(
                      'Add a Profile Photo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Add a clear photo of yourself to help\ndrivers identify you. This builds trust in\nthe community.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF757575),
                          height: 1.5),
                    ),

                    const Spacer(flex: 2),

                    // Take Photo
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt_outlined, size: 20),
                        label: const Text('Take Photo',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkMaroon,
                          foregroundColor: Colors.white,
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
                        icon: const Icon(Icons.image_outlined, size: 20),
                        label: const Text('Upload from Gallery',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1A1A1A),
                          side: const BorderSide(
                              color: Color(0xFFE0E0E0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skip
                    TextButton(
                      onPressed: _goToHome,
                      child: const Text(
                        'Skip for now',
                        style: TextStyle(
                            fontSize: 14, color: Color(0xFF9E9E9E)),
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
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE0E0E0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Continue',
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
