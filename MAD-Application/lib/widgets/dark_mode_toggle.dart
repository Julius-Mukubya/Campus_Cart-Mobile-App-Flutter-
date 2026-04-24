import 'package:flutter/material.dart';
import 'package:madpractical/services/app_settings.dart';
import 'package:madpractical/constants/app_colors.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings();
    final isDark = settings.isDark;
    return GestureDetector(
      onTap: () async {
        await settings.toggleTheme();
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.getSurface(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          color: isDark ? Colors.amber : Theme.of(context).iconTheme.color,
          size: 20,
        ),
      ),
    );
  }
}
