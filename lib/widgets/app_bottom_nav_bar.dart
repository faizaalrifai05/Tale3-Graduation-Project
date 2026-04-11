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
      decoration: const BoxDecoration(
        color: AppStyles.surfaceColor,
        border: Border(top: BorderSide(color: AppStyles.borderColor, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppStyles.surfaceColor,
        selectedItemColor: AppStyles.primaryColor,
        unselectedItemColor: AppStyles.textTertiary,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        elevation: 0,
        items: items,
      ),
    );
  }
}

