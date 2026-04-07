import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/booking_provider.dart';
import 'package:testtale3/screens/passenger/booking_status_screen.dart';

/// Screen for passengers to select their seat(s) before booking.
///
/// Uses [BookingProvider] for seat selection state instead of local setState.
/// Seat states: 0 = available, 1 = selected, 2 = occupied, 3 = driver.
class SelectSeatScreen extends StatelessWidget {
  const SelectSeatScreen({super.key});

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
        child: Consumer<BookingProvider>(
          builder: (context, bookingProvider, _) {
            return Column(
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
                                  _buildSeat(bookingProvider, 0),
                                  _buildSeat(bookingProvider, 1),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Back row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSeat(bookingProvider, 2),
                                  _buildSeat(bookingProvider, 3),
                                  _buildSeat(bookingProvider, 4),
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
                                bookingProvider.selectedCount.toString(),
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
                                '${bookingProvider.totalPrice} JOD',
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildSeat(BookingProvider provider, int index) {
    final state = provider.seatStates[index] ?? 0;

    // Driver seat (steering wheel symbol)
    if (state == 3) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EAF6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Icon(Icons.drive_eta, color: Color(0xFF9FA8DA), size: 24),
        ),
      );
    }

    Color bgColor;
    Color iconColor;

    if (state == 1) {
      bgColor = _primaryColor;
      iconColor = Colors.white;
    } else if (state == 2) {
      bgColor = const Color(0xFFE0E0E0);
      iconColor = Colors.white;
    } else {
      bgColor = const Color(0xFFF5F5F5);
      iconColor = const Color(0xFFBDBDBD);
    }

    return GestureDetector(
      onTap: () => provider.toggleSeat(index),
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
