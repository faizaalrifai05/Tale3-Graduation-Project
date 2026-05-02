import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/l10n/app_localizations.dart';
import 'package:testtale3/models/ride_model.dart';
import 'package:testtale3/providers/ride_provider.dart';
import 'package:testtale3/screens/passenger/ride_details_screen.dart';
import 'package:testtale3/theme/app_styles.dart';

enum _SortMode { newest, priceLow, priceHigh, time }

class RideResultsScreen extends StatefulWidget {
  final String? origin;
  final String? destination;
  final String? date;
  final int seats;

  const RideResultsScreen({
    super.key,
    this.origin,
    this.destination,
    this.date,
    this.seats = 1,
  });

  @override
  State<RideResultsScreen> createState() => _RideResultsScreenState();
}

class _RideResultsScreenState extends State<RideResultsScreen> {
  _SortMode _sort = _SortMode.newest;
  int _maxPrice = 200;
  int _minAvailableSeats = 1;
  bool _filterAc = false;
  bool _filterNoSmoking = false;
  bool _filterLuggage = false;
  bool _filterPets = false;

  bool get _hasActiveFilters =>
      _maxPrice < 200 ||
      _minAvailableSeats > 1 ||
      _filterAc ||
      _filterNoSmoking ||
      _filterLuggage ||
      _filterPets ||
      _sort != _SortMode.newest;

  List<RideModel> _applyFilters(List<RideModel> rides) {
    var result = rides.where((r) {
      if (widget.origin != null &&
          widget.origin!.isNotEmpty &&
          !r.origin.toLowerCase().contains(widget.origin!.toLowerCase())) {
        return false;
      }
      if (widget.destination != null &&
          widget.destination!.isNotEmpty &&
          !r.destination.toLowerCase().contains(widget.destination!.toLowerCase())) {
        return false;
      }
      if (widget.date != null && widget.date!.isNotEmpty && r.date != widget.date) {
        return false;
      }
      if (r.availableSeats < widget.seats) return false;
      if (r.pricePerSeat > _maxPrice) return false;
      if (r.availableSeats < _minAvailableSeats) return false;
      if (_filterAc && !r.acEnabled) return false;
      if (_filterNoSmoking && !r.noSmoking) return false;
      if (_filterLuggage && !r.luggageEnabled) return false;
      if (_filterPets && !r.petsAllowed) return false;
      return true;
    }).toList();

    switch (_sort) {
      case _SortMode.priceLow:
        result.sort((a, b) => a.pricePerSeat.compareTo(b.pricePerSeat));
      case _SortMode.priceHigh:
        result.sort((a, b) => b.pricePerSeat.compareTo(a.pricePerSeat));
      case _SortMode.time:
        result.sort((a, b) {
          final dateComp = a.date.compareTo(b.date);
          return dateComp != 0 ? dateComp : a.time.compareTo(b.time);
        });
      case _SortMode.newest:
        break;
    }
    return result;
  }

  void _showFilterSheet() {
    int tempMaxPrice = _maxPrice;
    int tempMinSeats = _minAvailableSeats;
    bool tempAc = _filterAc;
    bool tempNoSmoking = _filterNoSmoking;
    bool tempLuggage = _filterLuggage;
    bool tempPets = _filterPets;
    _SortMode tempSort = _sort;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          decoration: BoxDecoration(
            color: context.colors.surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.colors.borderColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Title row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.filterRides,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setSheet(() {
                            tempMaxPrice = 200;
                            tempMinSeats = 1;
                            tempAc = false;
                            tempNoSmoking = false;
                            tempLuggage = false;
                            tempPets = false;
                            tempSort = _SortMode.newest;
                          });
                        },
                        child: Text(
                          context.l10n.reset,
                          style: TextStyle(
                            color: AppStyles.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sort
                  Text(
                    context.l10n.sortBy,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _SortChip(
                        label: context.l10n.newest,
                        selected: tempSort == _SortMode.newest,
                        onTap: () => setSheet(() => tempSort = _SortMode.newest),
                      ),
                      _SortChip(
                        label: context.l10n.sortPriceLow,
                        selected: tempSort == _SortMode.priceLow,
                        onTap: () => setSheet(() => tempSort = _SortMode.priceLow),
                      ),
                      _SortChip(
                        label: context.l10n.sortPriceHigh,
                        selected: tempSort == _SortMode.priceHigh,
                        onTap: () => setSheet(() => tempSort = _SortMode.priceHigh),
                      ),
                      _SortChip(
                        label: context.l10n.sortByTime,
                        selected: tempSort == _SortMode.time,
                        onTap: () => setSheet(() => tempSort = _SortMode.time),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Max Price slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.priceRange,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Text(
                        '${context.l10n.pricePerSeat}: $tempMaxPrice JOD',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppStyles.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: tempMaxPrice.toDouble(),
                    min: 1,
                    max: 200,
                    divisions: 199,
                    activeColor: AppStyles.primaryColor,
                    inactiveColor: context.colors.borderColor,
                    onChanged: (v) => setSheet(() => tempMaxPrice = v.round()),
                  ),
                  const SizedBox(height: 16),

                  // Min seats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.minSeats,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textSecondary,
                        ),
                      ),
                      Row(
                        children: [
                          _CounterButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (tempMinSeats > 1) setSheet(() => tempMinSeats--);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '$tempMinSeats',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: context.colors.textPrimary,
                              ),
                            ),
                          ),
                          _CounterButton(
                            icon: Icons.add,
                            onTap: () {
                              if (tempMinSeats < 4) setSheet(() => tempMinSeats++);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Features
                  Text(
                    context.l10n.ridePreferences,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: context.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _FeatureToggle(
                    icon: Icons.ac_unit_rounded,
                    label: context.l10n.airConditioning,
                    value: tempAc,
                    onChanged: (v) => setSheet(() => tempAc = v),
                  ),
                  _FeatureToggle(
                    icon: Icons.smoke_free_rounded,
                    label: context.l10n.noSmoking,
                    value: tempNoSmoking,
                    onChanged: (v) => setSheet(() => tempNoSmoking = v),
                  ),
                  _FeatureToggle(
                    icon: Icons.luggage_rounded,
                    label: context.l10n.luggageSpaceAvailable,
                    value: tempLuggage,
                    onChanged: (v) => setSheet(() => tempLuggage = v),
                  ),
                  _FeatureToggle(
                    icon: Icons.pets_rounded,
                    label: context.l10n.petsAllowed,
                    value: tempPets,
                    onChanged: (v) => setSheet(() => tempPets = v),
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _maxPrice = tempMaxPrice;
                          _minAvailableSeats = tempMinSeats;
                          _filterAc = tempAc;
                          _filterNoSmoking = tempNoSmoking;
                          _filterLuggage = tempLuggage;
                          _filterPets = tempPets;
                          _sort = tempSort;
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.darkMaroon,
                        foregroundColor: AppStyles.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        context.l10n.apply,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSearch = (widget.origin?.isNotEmpty ?? false) ||
        (widget.destination?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: context.colors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                          hasSearch
                              ? '${widget.origin?.isNotEmpty == true ? widget.origin! : context.l10n.anywhere} → ${widget.destination?.isNotEmpty == true ? widget.destination! : context.l10n.anywhere}'
                              : context.l10n.availableRides,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: context.colors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.date != null && widget.date!.isNotEmpty
                              ? widget.date!
                              : context.l10n.tapToSeeDetails,
                          style: TextStyle(
                              fontSize: 12, color: context.colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Filter button
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.tune_rounded,
                            color: _hasActiveFilters
                                ? AppStyles.primaryColor
                                : context.colors.textSecondary),
                        onPressed: _showFilterSheet,
                      ),
                      if (_hasActiveFilters)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppStyles.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Results list
            Expanded(
              child: StreamBuilder<List<RideModel>>(
                stream: context.read<RideProvider>().availableRidesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                        child: CircularProgressIndicator(
                            color: AppStyles.primaryColor));
                  }
                  final all = snapshot.data ?? [];
                  final rides = _applyFilters(all);

                  if (rides.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car_outlined,
                              size: 56, color: context.colors.textTertiary),
                          const SizedBox(height: 16),
                          Text(
                            all.isEmpty
                                ? context.l10n.noRidesAvailable
                                : context.l10n.noRidesFound,
                            style: TextStyle(
                                color: context.colors.textSecondary,
                                fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    itemCount: rides.length,
                    itemBuilder: (context, index) =>
                        _RideCard(ride: rides[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Ride card
// ─────────────────────────────────────────────────────────────────────────────
class _RideCard extends StatelessWidget {
  final RideModel ride;
  const _RideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Driver row + price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: context.colors.highlightBackgroundColor,
                child: Text(
                  ride.driverName.isNotEmpty ? ride.driverName[0].toUpperCase() : 'D',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.driverName.isEmpty ? 'Driver' : ride.driverName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ride.carFullInfo,
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textTertiary),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ride.pricePerSeat} JOD',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppStyles.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ride.availableSeats <= 1
                          ? const Color(0xFFFFF3E0)
                          : context.colors.highlightBackgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${ride.availableSeats} ${context.l10n.seatsLeft}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: ride.availableSeats <= 1
                            ? const Color(0xFFE65100)
                            : AppStyles.primaryColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Feature chips
          if (ride.acEnabled || ride.noSmoking || ride.luggageEnabled || ride.petsAllowed)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (ride.acEnabled)
                  _FeatureChip(icon: Icons.ac_unit_rounded, label: 'AC'),
                if (ride.noSmoking)
                  _FeatureChip(icon: Icons.smoke_free_rounded, label: context.l10n.noSmoking),
                if (ride.luggageEnabled)
                  _FeatureChip(icon: Icons.luggage_rounded, label: context.l10n.luggageSpaceAvailable),
                if (ride.petsAllowed)
                  _FeatureChip(icon: Icons.pets_rounded, label: context.l10n.petsAllowed),
              ],
            ),
          if (ride.acEnabled || ride.noSmoking || ride.luggageEnabled || ride.petsAllowed)
            const SizedBox(height: 12),

          Divider(height: 1, color: context.colors.borderColor),
          const SizedBox(height: 12),

          // Route + time + book
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ride.origin} → ${ride.destination}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ride.date}  ·  ${ride.time}',
                      style: TextStyle(
                          fontSize: 12, color: context.colors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                width: 80,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => RideDetailsScreen(ride: ride)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.darkMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.book,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.highlightBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppStyles.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppStyles.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SortChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppStyles.primaryColor
              : context.colors.cardBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppStyles.primaryColor : context.colors.borderColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? AppStyles.onPrimary : context.colors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: context.colors.cardBackgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: context.colors.borderColor),
        ),
        child: Icon(icon, size: 16, color: context.colors.textPrimary),
      ),
    );
  }
}

class _FeatureToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _FeatureToggle(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.colors.highlightBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppStyles.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppStyles.primaryColor,
          ),
        ],
      ),
    );
  }
}
