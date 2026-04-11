import 'package:flutter/material.dart';
import '../theme/app_styles.dart';

class SavedPlacesScreen extends StatelessWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Saved Places',
          style: TextStyle(
            color: AppStyles.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppStyles.textPrimary),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSavedPlaceTile(
            context,
            icon: Icons.home_rounded,
            title: 'Home',
            subtitle: 'Al-Jubeiha, Amman',
          ),
          const SizedBox(height: 12),
          _buildSavedPlaceTile(
            context,
            icon: Icons.work_rounded,
            title: 'Work',
            subtitle: 'King Hussein Business Park',
          ),
          const SizedBox(height: 12),
          _buildSavedPlaceTile(
            context,
            icon: Icons.favorite,
            title: 'Irbid University',
            subtitle: 'Yarmouk University Rd',
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add place functionality coming soon!')),
                );
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New Place',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlaceTile(BuildContext context, {required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppStyles.highlightBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppStyles.primaryColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppStyles.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppStyles.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppStyles.textTertiary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Manage $title')),
              );
            },
          ),
        ],
      ),
    );
  }
}
