import 'package:testtale3/theme/app_styles.dart';
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
                  color: context.colors.borderColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined,
                  color: AppStyles.primaryColor),
              title: Text('Take a photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading:
                  Icon(Icons.photo_library_outlined, color: AppStyles.primaryColor),
              title: Text('Choose from gallery'),
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
          content: Text(
              'Please upload both front and back of your ID to continue'),
          backgroundColor: AppStyles.primaryColor,
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
          frontIdImage: _frontImage!,
          backIdImage: _backImage!,
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
          'Tale3',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Step 2 of 4',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: context.colors.textPrimary)),
                  Text('50%',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryColor)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: context.colors.neutralLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              Text(
                'Identity Verification',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: context.colors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Please upload a clear photo of your National\nID or Passport to verify your identity.',
                style: TextStyle(
                    fontSize: 14, color: context.colors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 32),

              Text('FRONT OF ID',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                      letterSpacing: 1)),
              const SizedBox(height: 12),
              _buildUploadCard(
                isFront: true,
                image: _frontImage,
                title: 'Upload front side',
                subtitle: 'JPG, PNG or PDF (max. 5MB)',
              ),
              const SizedBox(height: 24),

              Text('BACK OF ID',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
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
                  color: context.colors.highlightBackgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Requirements for photo:',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppStyles.primaryColor)),
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
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: AppStyles.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
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
              Center(
                child: Text(
                  'SECURE 256-BIT SSL ENCRYPTED VERIFICATION',
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
  }) {
    return GestureDetector(
      onTap: () => _pickImage(isFront),
      child: Container(
        width: double.infinity,
        height: 140,
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
                        child: Icon(Icons.check,
                            color: AppStyles.onPrimary, size: 14),
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
                          child: Text('Tap to change',
                              style: TextStyle(
                                  color: AppStyles.onPrimary,
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
                    decoration: BoxDecoration(
                      color: context.colors.highlightBackgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: AppStyles.primaryColor, size: 24),
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

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 4),
            child:
                Icon(Icons.check_circle, color: AppStyles.primaryColor, size: 14),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: context.colors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
