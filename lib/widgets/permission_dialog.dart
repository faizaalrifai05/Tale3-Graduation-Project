import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/theme/app_styles.dart';
import 'package:testtale3/providers/settings_provider.dart';

enum PermissionType { notifications, location }

/// Call from the home screen's initState (via addPostFrameCallback).
/// Shows branded permission dialogs once — the first time the user reaches home.
Future<void> requestFirstTimePermissionsIfNeeded(BuildContext context) async {
  final settings = context.read<SettingsProvider>();
  if (!await settings.isFirstTimePermissions()) return;
  await settings.markPermissionsAsked();

  if (!context.mounted) return;
  final notifAllowed = await showPermissionDialog(context, PermissionType.notifications);
  if (notifAllowed && context.mounted) await settings.requestNotifications();

  if (!context.mounted) return;
  final locAllowed = await showPermissionDialog(context, PermissionType.location);
  if (locAllowed && context.mounted) await settings.requestLocation();
}

/// Shown when location is denied and the user tries to book/create a ride.
/// Only informs — no button auto-opens Settings.
Future<void> showLocationSettingsReminder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppStyles.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppStyles.primaryColor,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Location Required',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Location access is disabled for Tale3.\n\nTo use this feature, open your phone\'s Settings → Apps → Tale3 → Permissions → Location, and enable it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyles.primaryColor,
                  foregroundColor: AppStyles.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('OK',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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
