import re
import sys

file_path = "c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\settings_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# Remove the Dark Mode tile
content = re.sub(
    r"_buildSettingsTile\(\s*Icons\.dark_mode_outlined,\s*'Dark Mode',\s*trailingText:\s*settings\.themeMode,\s*onTap:\s*\(\)\s*=>\s*_showThemeModePicker\(settings\),\s*\),",
    "",
    content,
    flags=re.DOTALL
)

# Remove the _showThemeModePicker function
content = re.sub(
    r"// ═══════════════════════════════════════════════════════════\s*//\s*4\. THEME MODE PICKER\s*// ═══════════════════════════════════════════════════════════\s*void _showThemeModePicker\(SettingsProvider settings\) \{.*?\}\s*(?=(// ═══════════════════════════════════════════════════════════\s*//\s*5\. HELP CENTER))",
    "",
    content,
    flags=re.DOTALL
)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Fixed settings_screen.dart")

file2 = "c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\passenger\\passenger_saved_places_screen.dart"
with open(file2, "r", encoding="utf-8") as f:
    content2 = f.read()
content2 = content2.replace(".withOpacity(", ".withValues(alpha: ")
with open(file2, "w", encoding="utf-8") as f:
    f.write(content2)

print("Fixed passenger_saved_places_screen.dart")

file3 = "c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\splash_screen.dart"
with open(file3, "r", encoding="utf-8") as f:
    content3 = f.read()

content3 = content3.replace("Container(\n                child: const Text(", "const Text(")
content3 = content3.replace("Container(\n              child: const Text(", "const Text(")
content3 = content3.replace("Container(\n            child: const Text(", "const Text(")

with open(file3, "w", encoding="utf-8") as f:
    f.write(content3)
print("Fixed splash_screen.dart container warning")
