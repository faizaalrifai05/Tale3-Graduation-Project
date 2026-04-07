import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/screens/driver/ride_posted_screen.dart';

/// Screen for drivers to create a new ride.
///
/// Uses [RideProvider] for all form state (seats, price, features)
/// instead of local setState. Text input fields remain uncontrolled
/// since they don't need to be shared across screens.
class DriverCreateRideScreen extends StatelessWidget {
  const DriverCreateRideScreen({super.key});

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
          // Consumer rebuilds only the form body when RideProvider changes.
          child: Consumer<RideProvider>(
            builder: (context, rideProvider, _) {
              return Column(
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
                          onChanged: rideProvider.setOrigin,
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
                          onChanged: rideProvider.setDestination,
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

                  // Seats & Price – driven by RideProvider
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
                                    onPressed: rideProvider.decrementSeats,
                                  ),
                                  Text('${rideProvider.seats}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 16),
                                    onPressed: rideProvider.incrementSeats,
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
                                    onPressed: rideProvider.decrementPrice,
                                  ),
                                  Text('\$${rideProvider.price}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    icon: const Icon(Icons.add, color: Color(0xFF1A1A1A), size: 16),
                                    onPressed: rideProvider.incrementPrice,
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

                  // Features – driven by RideProvider
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
                          value: rideProvider.acChecked,
                          onChanged: (v) => rideProvider.toggleAc(v ?? false),
                          title: const Text('Air Conditioning', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: _primaryColor,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: rideProvider.luggageChecked,
                          onChanged: (v) => rideProvider.toggleLuggage(v ?? false),
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
                          value: rideProvider.petsChecked,
                          onChanged: (v) => rideProvider.togglePets(v ?? false),
                          title: const Text('Pets Allowed', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: _primaryColor,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: rideProvider.noSmokingChecked,
                          onChanged: (v) => rideProvider.toggleNoSmoking(v ?? false),
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
                    onChanged: rideProvider.setAdditionalNotes,
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
                        rideProvider.publishRide();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RidePostedScreen(),
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
              );
            },
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
