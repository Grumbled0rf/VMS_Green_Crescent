// lib/shared/widgets/booking_options_dialog.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/vehicle.dart';
import '../../features/insurance/screens/insurance_booking_screen.dart';
import '../../features/booking/screens/create_booking_screen.dart';

class BookingOptionsDialog extends StatelessWidget {
  final Vehicle? vehicle;
  final List<Vehicle> vehicles;

  const BookingOptionsDialog({super.key, this.vehicle, required this.vehicles});

  static Future<void> show(BuildContext context, {Vehicle? vehicle, required List<Vehicle> vehicles}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingOptionsDialog(vehicle: vehicle, vehicles: vehicles),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;

    return Container(
      decoration: BoxDecoration(color: cardColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What would you like to book?', style: AppTheme.headingSm.copyWith(color: textPrimary)),
                const SizedBox(height: 8),
                Text('Choose a service', style: AppTheme.bodyMd.copyWith(color: textSecondary)),
                const SizedBox(height: 24),
                _buildOption(context, Icons.speed, AppColors.success, 'Emission Test', 'From AED 100', () {
                  Navigator.pop(context);
                  if (vehicles.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CreateBookingScreen(vehicles: vehicles)));
                  }
                }, isDark),
                const SizedBox(height: 16),
                _buildOption(context, Icons.shield, AppColors.primary, 'Vehicle Insurance', 'From AED 750/year', () {
                  Navigator.pop(context);
                  if (vehicle != null) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InsuranceBookingScreen(vehicle: vehicle!)));
                  } else if (vehicles.isNotEmpty) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InsuranceBookingScreen(vehicle: vehicles.first)));
                  }
                }, isDark, isNew: true),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, Color color, String title, String price, VoidCallback onTap, bool isDark, {bool isNew = false}) {
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
        child: Row(
          children: [
            Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(title, style: AppTheme.titleMd.copyWith(color: textPrimary)),
                    if (isNew) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(4)), child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))],
                  ]),
                  const SizedBox(height: 4),
                  Text(price, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: textSecondary, size: 16),
          ],
        ),
      ),
    );
  }
}