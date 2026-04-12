import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:testtale3/screens/driver/driver_vehicle_details_screen.dart';

class DriverIdVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phone;

  const DriverIdVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  State<DriverIdVerificationScreen> createState() =>
      _DriverIdVerificationScreenState();
}

class _DriverIdVerificationScreenState
    extends State<DriverIdVerificationScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  File? _frontImage;
  File? _backImage;

  Future<void> _pickImage(bool isFront) async {
    final source = await _showSourceDialog();
    if (source == null) return;
    final picked =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() {
        if (isFront) {
          _frontImage = File(picked.path);
        } else {
          _backImage = File(picked.path);
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
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined,
                  color: _primaryColor),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library_outlined, color: _primaryColor),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please upload both front and back of your ID to continue'),
          backgroundColor: _primaryColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DriverVehicleDetailsScreen(
          name: widget.name,
          email: widget.email,
          password: widget.password,
          phone: widget.phone,
        ),
      ),
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
          'Tale3',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Step 2 of 4',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                  Text('50%',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(_primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              const Text(
                'Identity Verification',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please upload a clear photo of your National\nID or Passport to verify your identity.',
                style: TextStyle(
                    fontSize: 14, color: Color(0xFF757575), height: 1.5),
              ),
              const SizedBox(height: 32),

              const Text('FRONT OF ID',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              _buildUploadCard(
                isFront: true,
                image: _frontImage,
                title: 'Upload front side',
                subtitle: 'JPG, PNG or PDF (max. 5MB)',
              ),
              const SizedBox(height: 24),

              const Text('BACK OF ID',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              _buildUploadCard(
                isFront: false,
                image: _backImage,
                title: 'Upload back side',
                subtitle: 'JPG, PNG or PDF (max. 5MB)',
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF2F4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Requirements for photo:',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _primaryColor)),
                    const SizedBox(height: 12),
                    _buildRequirementItem(
                        'All four corners of the document are visible'),
                    _buildRequirementItem('Text is clear and easy to read'),
                    _buildRequirementItem(
                        'No glare or reflections from flash'),
                  ],
                ),
              ),
              const SizedBox(height: 48),

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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Submit for Verification',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.check_circle_outline, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'SECURE 256-BIT SSL ENCRYPTED VERIFICATION',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBDBDBD),
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
  }) {
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          border: Border.all(
            color: image != null ? _primaryColor : const Color(0xFFE0E0E0),
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
                        decoration: const BoxDecoration(
                          color: _primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 14),
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
                        child: const Center(
                          child: Text('Tap to change',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
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
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFDF2F4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: _primaryColor, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF9E9E9E))),
                ],
              ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child:
                Icon(Icons.check_circle, color: _primaryColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A1A1A))),
          ),
        ],
      ),
    );
  }
}
