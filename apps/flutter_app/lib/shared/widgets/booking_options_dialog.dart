import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../insurance/screens/insurance_booking_screen.dart';
import '../../booking/screens/create_booking_screen.dart';

/// Dialog to choose between Insurance booking and Emission Test booking
class BookingOptionsDialog extends StatelessWidget {
  final Vehicle? vehicle;
  final List<Vehicle> vehicles;

  const BookingOptionsDialog({
    super.key,
    this.vehicle,
    required this.vehicles,
  });

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
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'What would you like to book?',
                  style: AppTheme.headingSm.copyWith(color: textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a service for your vehicle',
                  style: AppTheme.bodyMd.copyWith(color: textSecondary),
                ),
                const SizedBox(height: 24),

                // Option 1: Emission Test
                _buildOptionCard(
                  context: context,
                  icon: Icons.speed,
                  iconColor: AppColors.success,
                  title: 'Emission Test',
                  subtitle: 'Book annual vehicle emission test',
                  price: 'From AED 100',
                  features: ['15-30 minutes', 'Multiple centers', 'Required annually'],
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToEmissionBooking(context);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Option 2: Vehicle Insurance
                _buildOptionCard(
                  context: context,
                  icon: Icons.shield,
                  iconColor: primaryColor,
                  title: 'Vehicle Insurance',
                  subtitle: 'Get insurance from our partner companies',
                  price: 'From AED 750/year',
                  features: ['3 partner companies', 'Instant quotes', 'Easy renewal'],
                  isNew: true,
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToInsuranceBooking(context);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 16),

                // Option 3: Both Services
                _buildBundleCard(
                  context: context,
                  isDark: isDark,
                ),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required VoidCallback onTap,
    required bool isDark,
    bool isNew = false,
  }) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppTheme.titleMd.copyWith(color: textPrimary)),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTheme.bodySm.copyWith(color: textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: features.map((f) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(f, style: TextStyle(color: textSecondary, fontSize: 11)),
                    )).toList(),
                  ),
                ],
              ),
            ),
            
            // Price & Arrow
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(price, style: TextStyle(color: iconColor, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 8),
                Icon(Icons.arrow_forward_ios, color: textSecondary, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleCard({
    required BuildContext context,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            AppColors.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Bundle & Save', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('10% OFF', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Text('Book both services together', style: TextStyle(color: textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('Coming Soon', style: TextStyle(color: textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  void _navigateToEmissionBooking(BuildContext context) {
    if (vehicle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateBookingScreen(vehicle: vehicle!, vehicles: vehicles),
        ),
      );
    } else if (vehicles.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CreateBookingScreen(vehicle: vehicles.first, vehicles: vehicles),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a vehicle first')),
      );
    }
  }

  void _navigateToInsuranceBooking(BuildContext context) {
    if (vehicle != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InsuranceBookingScreen(vehicle: vehicle!),
        ),
      );
    } else if (vehicles.isNotEmpty) {
      // Show vehicle selection dialog
      _showVehicleSelector(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a vehicle first')),
      );
    }
  }

  void _showVehicleSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.gray;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Vehicle', style: AppTheme.titleLg.copyWith(color: textPrimary)),
            const SizedBox(height: 16),
            ...vehicles.map((v) => ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.directions_car, color: AppColors.primary),
              ),
              title: Text(v.displayName, style: TextStyle(color: textPrimary)),
              subtitle: Text(v.fullPlate, style: TextStyle(color: textSecondary)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InsuranceBookingScreen(vehicle: v),
                  ),
                );
              },
            )),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}