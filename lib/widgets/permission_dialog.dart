import 'package:flutter/material.dart';
import 'package:testtale3/theme/app_styles.dart';

enum PermissionType { notifications, location }

/// Shows a branded permission explanation dialog before triggering the system prompt.
/// Returns true if the user pressed "Allow", false if they pressed "Not Now".
Future<bool> showPermissionDialog(
  BuildContext context,
  PermissionType type,
) async {
  final isNotif = type == PermissionType.notifications;

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: context.colors.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isNotif ? Icons.notifications_active_outlined : Icons.location_on_outlined,
                color: AppStyles.primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isNotif ? 'Enable Notifications' : 'Enable Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isNotif
                  ? 'Stay updated on your ride status, messages from drivers, and important alerts.'
                  : 'Tale3 uses your location to find nearby rides and calculate accurate pickup points.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            // Allow button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: AppStyles.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Allow',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Not now button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Not Now',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  return result ?? false;
}
