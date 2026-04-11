import os
import re

lib_dir = r"c:\Users\Lenovo\Desktop\testtale3\testtale3\lib\screens"

files_to_update = [
    os.path.join(lib_dir, "passenger_home_screen.dart"),
    os.path.join(lib_dir, "driver_home_screen.dart")
]

for file_path in files_to_update:
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # Add imports if not present
    if "import '../theme/app_styles.dart';" not in content:
        content = content.replace(
            "import 'package:flutter/material.dart';",
            "import 'package:flutter/material.dart';\nimport '../theme/app_styles.dart';\nimport '../widgets/app_bottom_nav_bar.dart';"
        )

    # Remove static color definitions
    content = re.sub(r"\s*static const Color _primaryColor = Color\(0xFF8B1A2B\);", "", content)
    content = re.sub(r"\s*static const Color _darkMaroon = Color\(0xFF5C0A1A\);", "", content)

    # Replace _primaryColor and _darkMaroon
    content = content.replace("_primaryColor", "AppStyles.primaryColor")
    content = content.replace("_darkMaroon", "AppStyles.darkMaroon")

    # Replace bottom bar passenger
    if "passenger_home_screen" in file_path:
        bottom_bar_pattern = re.compile(r"bottomNavigationBar: Container\([\s\S]*?items: const \[\s*BottomNavigationBarItem\([\s\S]*?\](?:|\s*),\s*\)(?:|\s*),\s*\),", re.MULTILINE)
        replacement = """bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'MY TRIPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'CHAT',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),"""
        content = bottom_bar_pattern.sub(replacement, content)
        
    elif "driver_home_screen" in file_path:
        bottom_bar_pattern = re.compile(r"bottomNavigationBar: Container\([\s\S]*?items: const \[\s*BottomNavigationBarItem\([\s\S]*?\](?:|\s*),\s*\)(?:|\s*),\s*\),", re.MULTILINE)
        replacement = """bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PickupScheduleScreen()),
            );
          } else if (index == 3) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DriverProfileScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_car_outlined),
            activeIcon: Icon(Icons.directions_car),
            label: 'MY RIDES',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'WALLET',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),"""
        content = bottom_bar_pattern.sub(replacement, content)

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(content)

print("Refactored screens.")
