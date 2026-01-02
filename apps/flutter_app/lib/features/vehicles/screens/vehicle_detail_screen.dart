import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import 'edit_vehicle_screen.dart';

// ============================================
// VEHICLE DETAIL SCREEN
// Shows full vehicle info with actions
// ============================================
class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle)? onVehicleUpdated;
  final Function(String)? onVehicleDeleted;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
    this.onVehicleUpdated,
    this.onVehicleDeleted,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  void _navigateToEdit() async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(
        builder: (_) => EditVehicleScreen(
          vehicle: _vehicle,
          onVehicleSaved: (updatedVehicle) {
            setState(() => _vehicle = updatedVehicle);
            widget.onVehicleUpdated?.call(updatedVehicle);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() => _vehicle = result);
    }
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${_vehicle.displayName}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _deleteVehicle();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteVehicle() async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Close loading
    Navigator.pop(context);

    // Callback
    widget.onVehicleDeleted?.call(_vehicle.id ?? '');

    // Show success and go back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle deleted successfully')),
    );
    Navigator.pop(context, 'deleted');
  }

  void _bookTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking screen coming soon!')),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Hero Image
          _buildSliverAppBar(),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Status Card
                _buildStatusCard(),
                const SizedBox(height: 20),

                // Vehicle Info
                _buildInfoSection(),
                const SizedBox(height: 20),

                // Test History
                _buildTestHistorySection(),
                const SizedBox(height: 20),

                // Actions
                _buildActionsSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ==========================================
  // SLIVER APP BAR
  // ==========================================

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: _navigateToEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outlined),
          onPressed: _confirmDelete,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _vehicle.displayName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Car Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 12),
                // Plate Number
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _vehicle.fullPlate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STATUS CARD
  // ==========================================

  Widget _buildStatusCard() {
    final status = _getStatus();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: status.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: status.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              status.icon,
              color: status.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: status.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status.subtitle,
                  style: AppTheme.bodyMd,
                ),
              ],
            ),
          ),
          if (_vehicle.daysUntilDue != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: status.color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${_vehicle.daysUntilDue!.abs()}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    _vehicle.daysUntilDue! >= 0 ? 'days' : 'overdue',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // INFO SECTION
  // ==========================================

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Information', style: AppTheme.titleLg),
          const SizedBox(height: 16),
          
          _buildInfoRow('Make', _vehicle.make),
          _buildInfoRow('Model', _vehicle.model),
          _buildInfoRow('Year', _vehicle.year.toString()),
          _buildInfoRow('Fuel Type', _vehicle.fuelType),
          if (_vehicle.color != null)
            _buildInfoRow('Color', _vehicle.color!),
          _buildInfoRow('Emirate', _vehicle.emirate),
          _buildInfoRow('Plate', _vehicle.plateNumber),
          if (_vehicle.vin != null)
            _buildInfoRow('VIN', _vehicle.vin!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd),
          Text(
            value,
            style: AppTheme.titleMd.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TEST HISTORY SECTION
  // ==========================================

  Widget _buildTestHistorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Emission Test History', style: AppTheme.titleLg),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Full history coming soon!')),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_vehicle.lastTestDate == null)
            _buildNoTestHistory()
          else
            _buildTestHistoryItem(),
        ],
      ),
    );
  }

  Widget _buildNoTestHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.history,
            size: 48,
            color: AppColors.lightGray,
          ),
          const SizedBox(height: 12),
          Text(
            'No test records yet',
            style: AppTheme.titleMd,
          ),
          const SizedBox(height: 4),
          Text(
            'Book your first emission test',
            style: AppTheme.bodyMd,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _bookTest,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Book Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestHistoryItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Emission Test Passed',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Last tested: ${_formatDate(_vehicle.lastTestDate!)}',
                  style: AppTheme.bodySm,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Valid until',
                style: TextStyle(fontSize: 10, color: AppColors.gray),
              ),
              Text(
                _vehicle.nextTestDue != null
                    ? _formatDate(_vehicle.nextTestDue!)
                    : '-',
                style: AppTheme.labelLg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ACTIONS SECTION
  // ==========================================

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.titleLg),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.calendar_month,
                label: 'Book Test',
                color: AppColors.primary,
                onTap: _bookTest,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.edit_outlined,
                label: 'Edit',
                color: AppColors.secondary,
                onTap: _navigateToEdit,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.share_outlined,
                label: 'Share',
                color: AppColors.accent,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon!')),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // FAB
  // ==========================================

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _bookTest,
      icon: const Icon(Icons.calendar_today),
      label: const Text('Book Test'),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  _VehicleStatus _getStatus() {
    if (_vehicle.lastTestDate == null) {
      return _VehicleStatus(
        title: 'No Test Record',
        subtitle: 'Book your first emission test',
        icon: Icons.help_outline,
        color: AppColors.gray,
      );
    } else if (_vehicle.isTestDue) {
      return _VehicleStatus(
        title: 'Test Overdue',
        subtitle: 'Please book a test immediately',
        icon: Icons.error_outline,
        color: AppColors.error,
      );
    } else if (_vehicle.isTestExpiringSoon) {
      return _VehicleStatus(
        title: 'Expiring Soon',
        subtitle: 'Book your test before it expires',
        icon: Icons.warning_amber,
        color: AppColors.warning,
      );
    } else {
      return _VehicleStatus(
        title: 'Compliant',
        subtitle: 'Your vehicle is up to date',
        icon: Icons.check_circle,
        color: AppColors.success,
      );
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

// Status model
class _VehicleStatus {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  _VehicleStatus({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}