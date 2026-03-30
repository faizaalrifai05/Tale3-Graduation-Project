import 'package:flutter/material.dart';
import 'booking_status_screen.dart';

class SelectSeatScreen extends StatefulWidget {
  const SelectSeatScreen({super.key});

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  static const Color _primaryColor = Color(0xFF8B1A2B);
  static const Color _darkMaroon = Color(0xFF5C0A1A);

  // Seat state map (0: available, 1: selected, 2: occupied, 3: driver (non-selectable))
  final Map<int, int> _seatStates = {
    0: 3, // Driver
    1: 2, // Front passenger (Occupied in mockup)
    2: 0, // Back left (Available)
    3: 1, // Back middle (Selected)
    4: 0, // Back right (Available)
  };

  void _toggleSeat(int index) {
    if (_seatStates[index] == 0) {
      setState(() => _seatStates[index] = 1);
    } else if (_seatStates[index] == 1) {
      setState(() => _seatStates[index] = 0);
    }
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
          'Select your seat',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    // Vehicle Info
                    const Text(
                      'Toyota Camry',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Thursday 15 Oct • 14:30',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Car Layout Visual
                    Container(
                      width: 250,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: const Color(0xFFEEEEEE), width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Front row (Driver left, passenger right)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSeat(0), // Driver
                              _buildSeat(1), // Front Passenger
                            ],
                          ),
                          const SizedBox(height: 40),
                          // Back row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSeat(2),
                              _buildSeat(3),
                              _buildSeat(4),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Seat Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(const Color(0xFFE0E0E0), 'Available'),
                        const SizedBox(width: 16),
                        _buildLegendItem(_primaryColor, 'Selected', isSelected: true),
                        const SizedBox(width: 16),
                        _buildLegendItem(const Color(0xFFBDBDBD), 'Occupied', iconColor: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Summary & Action
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Seat(s)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _seatStates.values.where((v) => v == 1).length.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Total Price',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF757575),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_seatStates.values.where((v) => v == 1).length * 5} JOD', // Mock calculation
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: _primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BookingStatusScreen(),
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
                        'Confirm Seat Selection',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeat(int index) {
    int state = _seatStates[index] ?? 0;
    
    Color bgColor;
    Color iconColor;
    
    if (state == 3) {
      // Driver seat (steering wheel symbol)
      bgColor = const Color(0xFFE8EAF6);
      iconColor = const Color(0xFF9FA8DA);
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.drive_eta, color: iconColor, size: 24),
        ),
      );
    } 
    
    if (state == 1) {
      bgColor = _primaryColor;
      iconColor = Colors.white;
    } else if (state == 2) {
      bgColor = const Color(0xFFE0E0E0);
      iconColor = Colors.white; // Occupied has white person icon
    } else {
      bgColor = const Color(0xFFF5F5F5);
      iconColor = const Color(0xFFBDBDBD);
    }

    return GestureDetector(
      onTap: () => _toggleSeat(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: state == 0 ? Border.all(color: const Color(0xFFE0E0E0)) : null,
        ),
        child: Center(
          child: Icon(Icons.person, color: iconColor, size: 24),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isSelected = false, Color iconColor = Colors.transparent}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? null : Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: iconColor != Colors.transparent
              ? Icon(Icons.person, size: 10, color: iconColor)
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
