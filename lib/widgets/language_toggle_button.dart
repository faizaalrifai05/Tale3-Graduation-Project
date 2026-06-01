import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testtale3/providers/settings_provider.dart';
import 'package:testtale3/theme/app_styles.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final isArabic = settings.isArabic;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => settings.setLocale(
          isArabic ? const Locale('en') : const Locale('ar'),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: AppStyles.primaryColor),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            isArabic ? 'EN' : 'AR',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppStyles.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
