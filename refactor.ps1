$passenger = "c:\Users\Lenovo\Desktop\testtale3\testtale3\lib\screens\passenger_home_screen.dart"
$driver = "c:\Users\Lenovo\Desktop\testtale3\testtale3\lib\screens\driver_home_screen.dart"

# Fix passenger colors
(Get-Content $passenger -Raw) -replace "_primaryColor", "AppStyles.primaryColor" -replace "_darkMaroon", "AppStyles.darkMaroon" | Set-Content $passenger

# Load driver file
$content = Get-Content $driver -Raw

# 1. Add imports to driver
$content = $content -replace "import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';`nimport '../theme/app_styles.dart';`nimport '../widgets/app_bottom_nav_bar.dart';"

# 2. Remove static colors
$content = $content -replace "\s*static const Color _primaryColor = Color\(0xFF8B1A2B\);", ""
$content = $content -replace "\s*static const Color _darkMaroon = Color\(0xFF5C0A1A\);", ""

# 3. Replace colors globally
$content = $content -replace "_primaryColor", "AppStyles.primaryColor"
$content = $content -replace "_darkMaroon", "AppStyles.darkMaroon"

# Save driver content back temporarily to do bottom nav replacement
$content | Set-Content $driver
