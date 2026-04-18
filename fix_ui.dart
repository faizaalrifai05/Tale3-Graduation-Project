import 'dart:io';

void main() async {
  final file1 = File('c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\settings_screen.dart');
  var content = await file1.readAsString();

  content = content.replaceAll(RegExp(
    r"_buildSettingsTile\(\s*Icons\.dark_mode_outlined,\s*'Dark Mode',\s*trailingText:\s*settings\.themeMode,\s*onTap:\s*\(\)\s*=>\s*_showThemeModePicker\(settings\),\s*\),",
    dotAll: true,
  ), '');

  content = content.replaceAll(RegExp(
    r"// ═══════════════════════════════════════════════════════════\s*//\s*4\. THEME MODE PICKER\s*// ═══════════════════════════════════════════════════════════\s*void _showThemeModePicker\(SettingsProvider settings\) \{.*?\}(?=\s*// ═══════════════════════════════════════════════════════════\s*//\s*5\. HELP CENTER)",
    dotAll: true,
  ), '');

  await file1.writeAsString(content);
  print('Fixed settings_screen.dart');

  final file2 = File('c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\passenger\\passenger_saved_places_screen.dart');
  var content2 = await file2.readAsString();
  content2 = content2.replaceAll('.withOpacity(', '.withValues(alpha: ');
  await file2.writeAsString(content2);
  print('Fixed passenger_saved_places_screen.dart');

  final file3 = File('c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\password_reset_screen.dart');
  var content3 = await file3.readAsString();
  content3 = content3.replaceAll('.withOpacity(', '.withValues(alpha: ');
  await file3.writeAsString(content3);
  print('Fixed password_reset_screen.dart');

  final file4 = File('c:\\Users\\Lenovo\\Desktop\\testtale3\\lib\\screens\\splash_screen.dart');
  var content4 = await file4.readAsString();
  content4 = content4.replaceAll(RegExp(r"Container\(\s*child:\s*const Text\("), "const Text(");
  // remove trailing ) for the container
  await file4.writeAsString(content4);
}
