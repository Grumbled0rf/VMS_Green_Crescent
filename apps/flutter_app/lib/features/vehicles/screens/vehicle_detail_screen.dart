import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../booking/screens/create_booking_screen.dart';
import 'edit_vehicle_screen.dart';

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
    if (result != null) setState(() => _vehicle = result);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${_vehicle.displayName}?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); _deleteVehicle(); },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteVehicle() async {
    showDialog(context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()));
    final result = await VehicleService.delete(_vehicle.id ?? '');
    if (!mounted) return;
    Navigator.pop(context);
    if (result.isSuccess) {
      widget.onVehicleDeleted?.call(_vehicle.id ?? '');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle deleted successfully')));
      Navigator.pop(context, 'deleted');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Failed to delete vehicle')));
    }
  }

  // ==========================================
  // BOOK TEST - FIXED
  // ==========================================
  void _bookTest() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CreateBookingScreen(vehicles: [_vehicle]),
      ),
    );
    
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed! Code: ${result.confirmationCode}')),
      );
    }
  }

  // ==========================================
  // SHARE DETAILS - FIXED
  // ==========================================
  void _shareDetails() {
    final details = '''
🚗 Vehicle Details
━━━━━━━━━━━━━━━━━━
${_vehicle.displayName}
Plate: ${_vehicle.fullPlate}

Make: ${_vehicle.make}
Model: ${_vehicle.model}
Year: ${_vehicle.year}
Fuel: ${_vehicle.fuelType}
${_vehicle.color != null ? 'Color: ${_vehicle.color}' : ''}
${_vehicle.vin != null ? 'VIN: ${_vehicle.vin}' : ''}

Test Status: ${_getStatusText()}
${_vehicle.lastTestDate != null ? 'Last Test: ${_formatDate(_vehicle.lastTestDate!)}' : ''}
${_vehicle.nextTestDue != null ? 'Next Due: ${_formatDate(_vehicle.nextTestDue!)}' : ''}
━━━━━━━━━━━━━━━━━━
Shared via VMS App
''';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Share Vehicle Details', style: AppTheme.titleLg),
            const SizedBox(height: 20),
            
            // Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(details, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
            ),
            const SizedBox(height: 20),
            
            // Share options
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: details));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Details copied to clipboard! 📋')),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareViaSystem(details);
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _shareViaSystem(String details) {
    // For now, copy to clipboard with message
    // In production, use share_plus package
    Clipboard.setData(ClipboardData(text: details));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Details copied! You can now paste and share. 📤')),
    );
  }

  String _getStatusText() {
    if (_vehicle.lastTestDate == null) {
      return 'No Test Record';
    } else if (_vehicle.isTestDue) {
      return 'Test Overdue ⚠️';
    } else if (_vehicle.isTestExpiringSoon) {
      return 'Expiring Soon ⏰';
    } else {
      return 'Compliant ✅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusCard(),
                const SizedBox(height: 20),
                _buildInfoSection(),
                const SizedBox(height: 20),
                _buildTestHistorySection(),
                const SizedBox(height: 20),
                _buildActionsSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bookTest,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Book Test'),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      actions: [
        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: _navigateToEdit),
        IconButton(icon: const Icon(Icons.delete_outlined), onPressed: _confirmDelete),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_vehicle.displayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.primaryGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.directions_car, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(_vehicle.fullPlate, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
            width: 56, height: 56,
            decoration: BoxDecoration(color: status.color.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: Icon(status.icon, color: status.color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(status.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: status.color)),
                const SizedBox(height: 4),
                Text(status.subtitle, style: AppTheme.bodyMd),
              ],
            ),
          ),
          if (_vehicle.daysUntilDue != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: status.color, borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  Text('${_vehicle.daysUntilDue!.abs()}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(_vehicle.daysUntilDue! >= 0 ? 'days' : 'overdue', style: const TextStyle(fontSize: 10, color: Colors.white)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle Information', style: AppTheme.titleLg),
          const SizedBox(height: 16),
          _buildInfoRow('Make', _vehicle.make),
          _buildInfoRow('Model', _vehicle.model),
          _buildInfoRow('Year', _vehicle.year.toString()),
          _buildInfoRow('Fuel Type', _vehicle.fuelType),
          if (_vehicle.color != null) _buildInfoRow('Color', _vehicle.color!),
          _buildInfoRow('Emirate', _vehicle.emirate),
          _buildInfoRow('Plate', _vehicle.plateNumber),
          if (_vehicle.vin != null) _buildInfoRow('VIN', _vehicle.vin!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: AppTheme.bodyMd), Text(value, style: AppTheme.titleMd.copyWith(fontSize: 14))],
      ),
    );
  }

  Widget _buildTestHistorySection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Emission Test History', style: AppTheme.titleLg),
              TextButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Full history coming soon!'))),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _vehicle.lastTestDate == null ? _buildNoTestHistory() : _buildTestHistoryItem(),
        ],
      ),
    );
  }

  Widget _buildNoTestHistory() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Icon(Icons.history, size: 48, color: AppColors.lightGray),
          const SizedBox(height: 12),
          Text('No test records yet', style: AppTheme.titleMd),
          const SizedBox(height: 4),
          Text('Book your first emission test', style: AppTheme.bodyMd),
          const SizedBox(height: 16),
          OutlinedButton.icon(onPressed: _bookTest, icon: const Icon(Icons.calendar_today), label: const Text('Book Test')),
        ],
      ),
    );
  }

  Widget _buildTestHistoryItem() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.check_circle, color: AppColors.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Emission Test Passed', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.success)),
                const SizedBox(height: 4),
                Text('Last tested: ${_formatDate(_vehicle.lastTestDate!)}', style: AppTheme.bodySm),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Valid until', style: TextStyle(fontSize: 10, color: AppColors.gray)),
              Text(_vehicle.nextTestDue != null ? _formatDate(_vehicle.nextTestDue!) : '-', style: AppTheme.labelLg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.titleLg),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionCard(Icons.calendar_month, 'Book Test', AppColors.primary, _bookTest)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(Icons.edit_outlined, 'Edit', AppColors.secondary, _navigateToEdit)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(Icons.share_outlined, 'Share', AppColors.accent, _shareDetails)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  _VehicleStatus _getStatus() {
    if (_vehicle.lastTestDate == null) {
      return _VehicleStatus(title: 'No Test Record', subtitle: 'Book your first emission test', icon: Icons.help_outline, color: AppColors.gray);
    } else if (_vehicle.isTestDue) {
      return _VehicleStatus(title: 'Test Overdue', subtitle: 'Please book a test immediately', icon: Icons.error_outline, color: AppColors.error);
    } else if (_vehicle.isTestExpiringSoon) {
      return _VehicleStatus(title: 'Expiring Soon', subtitle: 'Book your test before it expires', icon: Icons.warning_amber, color: AppColors.warning);
    } else {
      return _VehicleStatus(title: 'Compliant', subtitle: 'Your vehicle is up to date', icon: Icons.check_circle, color: AppColors.success);
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _VehicleStatus {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _VehicleStatus({required this.title, required this.subtitle, required this.icon, required this.color});
}