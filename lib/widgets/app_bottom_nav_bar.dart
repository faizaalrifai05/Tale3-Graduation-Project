import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
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
        items: items,
      ),
    );
  }
}

