import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/screens/driver/ride_confirmation_screen.dart';

/// Screen for drivers to create a new ride.
///
/// Uses [RideProvider] for all form state (seats, price, features)
/// instead of local setState. Text input fields remain uncontrolled
/// since they don't need to be shared across screens.
class DriverCreateRideScreen extends StatelessWidget {
  const DriverCreateRideScreen({super.key});

  
  

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
          'Create Ride',
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
          // Consumer rebuilds only the form body when RideProvider changes.
          child: Consumer<RideProvider>(
            builder: (context, rideProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route Settings
                  Text(
                    'Route settings',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Origin/Destination block
                  Container(
                    decoration: BoxDecoration(
                      color: context.colors.inputFillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: context.colors.borderColor),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: rideProvider.setOrigin,
                          decoration: InputDecoration(
                            hintText: 'Origin (e.g. Downtown Dubai)',
                            hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
                            prefixIcon: Icon(Icons.radio_button_unchecked, color: AppStyles.primaryColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                        Divider(height: 1, indent: 48),
                        TextField(
                          onChanged: rideProvider.setDestination,
                          decoration: InputDecoration(
                            hintText: 'Destination (e.g. Dubai Marina)',
                            hintStyle: TextStyle(color: context.colors.textTertiary, fontSize: 14),
                            prefixIcon: Icon(Icons.location_on, color: AppStyles.primaryColor, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Date & Time — tappable pickers
                  Row(
                    children: [
                      Expanded(
                        child: _buildPickerBlock(
                          context: context,
                          label: 'Date',
                          value: rideProvider.dateLabel,
                          icon: Icons.calendar_today,
                          isEmpty: rideProvider.selectedDate == null,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: rideProvider.selectedDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) rideProvider.setDate(picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPickerBlock(
                          context: context,
                          label: 'Time',
                          value: rideProvider.timeLabel,
                          icon: Icons.access_time,
                          isEmpty: rideProvider.selectedTime == null,
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: rideProvider.selectedTime ?? TimeOfDay.now(),
                            );
                            if (picked != null) rideProvider.setTime(picked);
                          },
                        ),
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
                            Text('Available Seats', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                            const SizedBox(height: 8),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: context.colors.inputFillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.colors.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: context.colors.textPrimary, size: 16),
                                    onPressed: rideProvider.decrementSeats,
                                  ),
                                  Text('${rideProvider.seats}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    icon: Icon(Icons.add, color: context.colors.textPrimary, size: 16),
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
                            Text('Price per seat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.colors.textPrimary)),
                            const SizedBox(height: 8),
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                color: context.colors.inputFillColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: context.colors.borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove, color: context.colors.textPrimary, size: 16),
                                    onPressed: rideProvider.decrementPrice,
                                  ),
                                  Text('\$${rideProvider.price}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                  IconButton(
                                    icon: Icon(Icons.add, color: context.colors.textPrimary, size: 16),
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
                  Text(
                    'Features & Preferences',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          value: rideProvider.acChecked,
                          onChanged: (v) => rideProvider.toggleAc(v ?? false),
                          title: Text('Air Conditioning', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppStyles.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: rideProvider.luggageChecked,
                          onChanged: (v) => rideProvider.toggleLuggage(v ?? false),
                          title: Text('Luggage', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppStyles.primaryColor,
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
                          title: Text('Pets Allowed', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppStyles.primaryColor,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          value: rideProvider.noSmokingChecked,
                          onChanged: (v) => rideProvider.toggleNoSmoking(v ?? false),
                          title: Text('No Smoking', style: TextStyle(fontSize: 13)),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppStyles.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Additional Notes
                  Text(
                    'Additional Notes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    maxLines: 4,
                    onChanged: rideProvider.setAdditionalNotes,
                    decoration: InputDecoration(
                      hintText: 'Add any specific details here...',
                      hintStyle: TextStyle(color: context.colors.inputHintColor, fontSize: 14),
                      filled: true,
                      fillColor: context.colors.inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.colors.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.colors.borderColor),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(color: AppStyles.primaryColor, width: 2),
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
                            builder: (context) => const RideConfirmationScreen(),
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

  Widget _buildPickerBlock({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required bool isEmpty,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.colors.inputFillColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEmpty ? context.colors.borderColor : AppStyles.primaryColor,
                width: isEmpty ? 1 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppStyles.primaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isEmpty
                          ? context.colors.inputHintColor
                          : context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
