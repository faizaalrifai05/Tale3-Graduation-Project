import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:testtale3/screens/passenger/ride_details_screen.dart';

class RideResultsScreen extends StatelessWidget {
  const RideResultsScreen({super.key});

  
  

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back, Title, and Filter
            Container(
              color: context.colors.surfaceColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Irbid to Amman',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Today • 2 Passengers',
                          style: TextStyle(
                            fontSize: 12,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune, color: context.colors.textPrimary),
                    onPressed: () => _showFilterSheet(context),
                  ),
                ],
              ),
            ),

            // Filter Chips
            Container(
              color: context.colors.surfaceColor,
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Row(
                children: [
                  _buildFilterChip(context, 'Price', true),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Time', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Rating', false),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Vehicle', false),
                ],
              ),
            ),

            // Results List
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  _buildResultCard(
                    context,
                    driverName: 'Ahmed M.',
                    rating: '4.8',
                    carInfo: 'Toyota Camry • White',
                    departureTime: '14:00',
                    arrivalTime: '15:15',
                    departureLocation: 'Irbid City Center',
                    arrivalLocation: '7th Circle, Amman',
                    price: '5 JOD',
                    seatsLeft: '3 SEATS LEFT',
                    isFull: false,
                  ),
                  _buildResultCard(
                    context,
                    driverName: 'Sara T.',
                    rating: '4.7',
                    carInfo: 'Hyundai Elantra • Silver',
                    departureTime: '15:30',
                    arrivalTime: '16:45',
                    departureLocation: 'Yarmouk University Gate',
                    arrivalLocation: 'Tabarbour Bus Station',
                    price: '4 JOD',
                    seatsLeft: '1 SEAT LEFT',
                    isFull: false,
                  ),
                  _buildResultCard(
                    context,
                    driverName: 'Omar K.',
                    rating: '5.0',
                    carInfo: 'Kia Sportage • Black',
                    departureTime: '16:15',
                    arrivalTime: '17:30',
                    departureLocation: 'Irbid North Station',
                    arrivalLocation: 'Abdali Boulevard',
                    price: '6 JOD',
                    seatsLeft: 'FULL',
                    isFull: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: context.colors.surfaceColor,
          border: Border(top: BorderSide(color: context.colors.borderColor, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.surfaceColor,
          selectedItemColor: AppStyles.primaryColor,
          unselectedItemColor: context.colors.textTertiary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car),
              label: 'My Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Inbox',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppStyles.primaryColor : context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppStyles.primaryColor : context.colors.borderColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? AppStyles.onPrimary : context.colors.textSecondary,
            ),
          ),
          if (isSelected) const SizedBox(width: 4),
          if (isSelected)
            Icon(Icons.keyboard_arrow_down, color: AppStyles.onPrimary, size: 16),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String driverName,
    required String rating,
    required String carInfo,
    required String departureTime,
    required String arrivalTime,
    required String departureLocation,
    required String arrivalLocation,
    required String price,
    required String seatsLeft,
    required bool isFull,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000), // Colors.black.withOpacity(0.04)
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver info and Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.borderColor,
                child: Icon(Icons.person, color: AppStyles.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          driverName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.star, color: AppStyles.starRatingColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      carInfo,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isFull ? context.colors.textTertiary : AppStyles.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    seatsLeft,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isFull ? context.colors.textTertiary : AppStyles.deepOrange,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: context.colors.dividerColor),
          const SizedBox(height: 16),

          // Timeline
          Row(
            children: [
              // Timeline visual
              Column(
                children: [
                  Text(
                    departureTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppStyles.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surfaceColor, width: 2),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 24,
                    color: context.colors.borderColor,
                  ),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: context.colors.textPrimary,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.surfaceColor, width: 2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arrivalTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Locations and Book button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      departureLocation,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            arrivalLocation,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: context.colors.textPrimary,
                            ),
                          ),
                        ),
                        // Book button
                        SizedBox(
                          height: 36,
                          width: 80,
                          child: ElevatedButton(
                            onPressed: isFull
                                ? null
                                : () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const RideDetailsScreen(),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppStyles.darkMaroon,
                              foregroundColor: AppStyles.onPrimary,
                              disabledBackgroundColor: context.colors.borderColor,
                              disabledForegroundColor: context.colors.textTertiary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            child: Text(
                              isFull ? 'FULL' : 'Book',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Filter Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String _sortBy = 'Price';
  RangeValues _priceRange = const RangeValues(0, 20);
  bool _acOnly = false;
  bool _luggageOnly = false;
  bool _noSmokingOnly = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: context.colors.borderColor, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filter & Sort', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: context.colors.textPrimary)),
              TextButton(
                onPressed: () => setState(() {
                  _sortBy = 'Price';
                  _priceRange = const RangeValues(0, 20);
                  _acOnly = false;
                  _luggageOnly = false;
                  _noSmokingOnly = false;
                }),
                child: Text('Reset', style: TextStyle(color: AppStyles.primaryColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort by
          Text('Sort by', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: ['Price', 'Time', 'Rating'].map((label) {
              final selected = _sortBy == label;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _sortBy = label),
                selectedColor: AppStyles.primaryColor,
                labelStyle: TextStyle(
                  color: selected ? AppStyles.onPrimary : context.colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                backgroundColor: context.colors.cardBackgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: selected ? AppStyles.primaryColor : context.colors.borderColor)),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Price range
          Text('Max Price: ${_priceRange.end.toInt()} JOD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: AppStyles.primaryColor,
            inactiveColor: AppStyles.primaryColor.withValues(alpha: 0.2),
            onChanged: (v) => setState(() => _priceRange = v),
          ),
          const SizedBox(height: 8),

          // Features
          Text('Features', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.colors.textPrimary)),
          const SizedBox(height: 8),
          _filterToggle(Icons.ac_unit, 'Air Conditioning', _acOnly, (v) => setState(() => _acOnly = v)),
          _filterToggle(Icons.luggage, 'Luggage Space', _luggageOnly, (v) => setState(() => _luggageOnly = v)),
          _filterToggle(Icons.smoke_free, 'No Smoking', _noSmokingOnly, (v) => setState(() => _noSmokingOnly = v)),
          const SizedBox(height: 20),

          // Apply
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.darkMaroon,
                foregroundColor: AppStyles.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterToggle(IconData icon, String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppStyles.primaryColor),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: context.colors.textPrimary))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppStyles.primaryColor,
            activeTrackColor: AppStyles.primaryColor.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

