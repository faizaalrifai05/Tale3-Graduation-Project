import 'package:flutter/material.dart';
import 'driver_ride_details_screen.dart';

class DriverCreateRideScreen extends StatefulWidget {
  const DriverCreateRideScreen({super.key});

  @override
  State<DriverCreateRideScreen> createState() => _DriverCreateRideScreenState();
}

class _DriverCreateRideScreenState extends State<DriverCreateRideScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  bool _acChecked = true;
  bool _luggageChecked = true;
  bool _petsChecked = false;
  bool _noSmokingChecked = true;
  int _seats = 3;
  int _price = 15;

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
          'Create Ride',
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
              // Route Settings
              const Text(
                'Route settings',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              
              // Origin/Destination block
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Origin (e.g. Downtown Dubai)',
                        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                        prefixIcon: Icon(Icons.radio_button_unchecked, color: _primaryColor, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    const Divider(height: 1, indent: 48),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Destination (e.g. Dubai Marina)',
                        hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                        prefixIcon: Icon(Icons.location_on, color: _primaryColor, size: 20),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: _buildInputBlock('Date', '15 Oct 2026', Icons.calendar_today),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputBlock('Time', '14:30', Icons.access_time),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Seats & Price
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Available Seats', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFF1A1A1A), size: 16),
                                onPressed: () {
                                  if (_seats > 1) setState(() => _seats--);
                                },
                              ),
                              Text('$_seats', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 16),
                                onPressed: () {
                                  setState(() => _seats++);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price per seat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 8),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Color(0xFF1A1A1A), size: 16),
                                onPressed: () {
                                  if (_price > 0) setState(() => _price--);
                                },
                              ),
                              Text('\$$_price', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              IconButton(
                                icon: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 16),
                                onPressed: () {
                                  setState(() => _price++);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Features
              const Text(
                'Features & Preferences',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: _acChecked,
                      onChanged: (v) => setState(() => _acChecked = v ?? false),
                      title: const Text('Air Conditioning', style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _primaryColor,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _luggageChecked,
                      onChanged: (v) => setState(() => _luggageChecked = v ?? false),
                      title: const Text('Luggage', style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _primaryColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      value: _petsChecked,
                      onChanged: (v) => setState(() => _petsChecked = v ?? false),
                      title: const Text('Pets Allowed', style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _primaryColor,
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      value: _noSmokingChecked,
                      onChanged: (v) => setState(() => _noSmokingChecked = v ?? false),
                      title: const Text('No Smoking', style: TextStyle(fontSize: 13)),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Additional Notes
              const Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add any specific details here...',
                  hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
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
                ),
              ),
              const SizedBox(height: 48),

              // Publish Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const DriverRideDetailsScreen(),
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
                  child: const Text(
                    'Publish Ride',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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

  Widget _buildInputBlock(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Row(
            children: [
              Icon(icon, color: _primaryColor, size: 20),
              const SizedBox(width: 12),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1A1A1A))),
            ],
          ),
        ),
      ],
    );
  }
}
