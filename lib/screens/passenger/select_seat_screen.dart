import 'package:testtale3/theme/app_styles.dart';
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
          'Select your seat',
          style: TextStyle(
            color: context.colors.textPrimary,
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
                        Text(
                          'Toyota Camry',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thursday 15 Oct • 14:30',
                          style: TextStyle(
                            fontSize: 14,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Car Layout Visual
                        Container(
                          width: 250,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: context.colors.surfaceColor,
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(color: context.colors.dividerColor, width: 3),
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
                                  _buildSeat(context, bookingProvider,0),
                                  _buildSeat(context, bookingProvider,1),
                                ],
                              ),
                              const SizedBox(height: 40),
                              // Back row
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSeat(context, bookingProvider,2),
                                  _buildSeat(context, bookingProvider,3),
                                  _buildSeat(context, bookingProvider,4),
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
                            _buildLegendItem(context, context.colors.borderColor, 'Available'),
                            const SizedBox(width: 16),
                            _buildLegendItem(context, AppStyles.primaryColor, 'Selected', isSelected: true),
                            const SizedBox(width: 16),
                            _buildLegendItem(context, context.colors.inputHintColor, 'Occupied', iconColor: AppStyles.onPrimary),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Summary & Action
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
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
                              Text(
                                'Selected Seat(s)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bookingProvider.selectedCount.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Total Price',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${bookingProvider.totalPrice} JOD',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: AppStyles.primaryColor,
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
                            backgroundColor: AppStyles.darkMaroon,
                            foregroundColor: AppStyles.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
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

  Widget _buildSeat(BuildContext context, BookingProvider provider, int index) {
    final state = provider.seatStates[index] ?? 0;

    // Driver seat (steering wheel symbol)
    if (state == 3) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: context.colors.neutralLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(Icons.drive_eta, color: AppStyles.primaryColor, size: 24),
        ),
      );
    }

    Color bgColor;
    Color iconColor;

    if (state == 1) {
      bgColor = AppStyles.primaryColor;
      iconColor = AppStyles.onPrimary;
    } else if (state == 2) {
      bgColor = context.colors.borderColor;
      iconColor = AppStyles.onPrimary;
    } else {
      bgColor = context.colors.cardBackgroundColor;
      iconColor = context.colors.inputHintColor;
    }

    return GestureDetector(
      onTap: () => provider.toggleSeat(index),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: state == 0 ? Border.all(color: context.colors.borderColor) : null,
        ),
        child: Center(
          child: Icon(Icons.person, color: iconColor, size: 24),
        ),
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label, {bool isSelected = false, Color iconColor = Colors.transparent}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: isSelected ? null : Border.all(color: context.colors.borderColor),
          ),
          child: iconColor != Colors.transparent
              ? Icon(Icons.person, size: 10, color: iconColor)
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
