import 'package:flutter/material.dart';
import 'package:testtale3/screens/driver/driver_verification_status_screen.dart';

class DriverVehicleDetailsScreen extends StatelessWidget {
  const DriverVehicleDetailsScreen({super.key});

  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

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
          'Vehicle Details',
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
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Onboarding Progress',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                  const Text(
                    'Step 3 of 4',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: const Color(0xFFEEEEEE),
                valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
                borderRadius: BorderRadius.circular(2),
                minHeight: 4,
              ),
              const SizedBox(height: 32),

              // Title Section
              const Text(
                'Tell us about your vehicle',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Provide the details of the vehicle you\'ll be driving.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              _buildDropdownField('Car Make', 'Select Car Make'),
              const SizedBox(height: 16),
              _buildDropdownField('Car Model', 'Select Car Model'),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Year', 'YYYY', TextInputType.number),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField('Color', 'e.g. White'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField('Plate Number', 'ABC 1234'),
              const SizedBox(height: 32),

              // Car Photos
              const Text(
                'Car Photos',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildPhotoUploadCard('Front View', Icons.camera_alt_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPhotoUploadCard('Back View', Icons.camera_alt_outlined)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildPhotoUploadCard('Inside', Icons.camera_alt_outlined)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildPhotoUploadCard('License Plate', Icons.credit_card)),
                ],
              ),
              const SizedBox(height: 48),

              // Next Step Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DriverVerificationStatusScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next Step',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, [TextInputType? keyboardType]) {
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
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFFBDBDBD),
              fontSize: 14,
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
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(
                  color: Color(0xFFBDBDBD),
                  fontSize: 14,
                ),
              ),
              items: const [],
              onChanged: (value) {},
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoUploadCard(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFDF2F4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}


