import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  /// Index of the chat tab inside [items]. The unread badge is rendered on
  /// whichever tab sits at this position. Defaults to 2 (the standard layout
  /// used by both driver and passenger home screens).
  final int chatTabIndex;

  /// Number of unread messages. Pass 0 (or null) to hide the badge entirely.
  final int unreadCount;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.chatTabIndex = 2,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surfaceColor,
        border: Border(top: BorderSide(color: context.colors.borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: context.colors.surfaceColor,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: context.colors.textTertiary,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        // Replace the chat tab's icon with a badged version when needed.
        items: List.generate(items.length, (i) {
          if (i != chatTabIndex || unreadCount <= 0) return items[i];

          // Build the badge once and reuse for both icon and activeIcon.
          Widget withBadge(Widget icon) => _ChatBadge(
                count: unreadCount,
                child: icon,
              );

          return BottomNavigationBarItem(
            label: items[i].label,
            tooltip: items[i].tooltip,
            backgroundColor: items[i].backgroundColor,
            icon: withBadge(items[i].icon),
            activeIcon: withBadge(items[i].activeIcon ?? items[i].icon),
          );
        }),
      ),
    );
  }
}

/// Wraps any widget with a small red circular badge showing [count].
/// Renders nothing extra when [count] is zero.
class _ChatBadge extends StatelessWidget {
  final Widget child;
  final int count;

  const _ChatBadge({required this.child, required this.count});

  @override
  Widget build(BuildContext context) {
    // Clamp display: show "99+" for very large counts.
    final label = count > 99 ? '99+' : '$count';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.colors.surfaceColor, width: 1.5),
            ),
            constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}