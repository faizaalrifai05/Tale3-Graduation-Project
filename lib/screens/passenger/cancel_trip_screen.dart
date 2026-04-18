import 'package:testtale3/theme/app_styles.dart';
import 'package:flutter/material.dart';

class CancelTripScreen extends StatefulWidget {
  const CancelTripScreen({super.key});

  @override
  State<CancelTripScreen> createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends State<CancelTripScreen> {
  
  int _selectedReasonIndex = 0;

  final List<String> _reasons = [
    'Changed my mind',
    'Found another ride',
    'Driver is running late',
    'Other reason'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Cancel Trip',
          style: TextStyle(
            color: context.colors.textPrimary,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.colors.highlightBackgroundColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(Icons.cancel, color: AppStyles.primaryColor, size: 40),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title
                    Text(
                      'Cancel Trip?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Are you sure you want to cancel this trip?\nPlease select a reason:',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Reasons List
                    Container(
                      decoration: BoxDecoration(
                        color: context.colors.surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colors.dividerColor, width: 1.5),
                      ),
                      child: Column(
                        children: List.generate(
                          _reasons.length,
                          (index) => Column(
                            children: [
                              RadioListTile<int>(
                                value: index,
                                groupValue: _selectedReasonIndex,
                                activeColor: AppStyles.primaryColor,
                                title: Text(
                                  _reasons[index],
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _selectedReasonIndex == index ? FontWeight.w700 : FontWeight.w500,
                                    color: _selectedReasonIndex == index ? context.colors.textPrimary : context.colors.textSecondary,
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    if (value != null) _selectedReasonIndex = value;
                                  });
                                },
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              ),
                              if (index < _reasons.length - 1)
                                Divider(height: 1, indent: 16, endIndent: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
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
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        // Pop until passenger home (first route)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyles.primaryColor,
                        foregroundColor: AppStyles.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Cancellation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: context.colors.textPrimary,
                    ),
                    child: Text(
                      'Keep Ride',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
}


