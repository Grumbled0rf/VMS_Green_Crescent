import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';

class TestHistoryScreen extends StatefulWidget {
  final Vehicle vehicle;

  const TestHistoryScreen({super.key, required this.vehicle});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  // Sample test history data - In production, fetch from Supabase
  final List<TestRecord> _testHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTestHistory();
  }

  void _loadTestHistory() {
    // Simulate loading test history
    // In production, fetch from Supabase based on vehicle ID
    if (widget.vehicle.lastTestDate != null) {
      _testHistory.add(
        TestRecord(
          id: '1',
          testDate: widget.vehicle.lastTestDate!,
          expiryDate: widget.vehicle.nextTestDue,
          result: 'Passed',
          testCenter: 'Green Crescent Onsite',
          emissions: EmissionValues(
            co: 0.12,
            hc: 45,
            nox: 0.08,
          ),
          certificateNumber: 'VMS-2025-001234',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Test History'),
      ),
      body: _testHistory.isEmpty ? _buildEmptyState() : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text('No Test Records', style: AppTheme.titleLg),
          const SizedBox(height: 8),
          Text(
            'This vehicle has no emission test history yet.',
            style: AppTheme.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.calendar_today),
            label: const Text('Book a Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle info card
          _buildVehicleCard(),
          const SizedBox(height: 24),

          // Current status
          _buildStatusCard(),
          const SizedBox(height: 24),

          // Test history
          Text('Test Records', style: AppTheme.titleLg),
          const SizedBox(height: 16),
          ..._testHistory.map((record) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildTestRecordCard(record),
              )),
        ],
      ),
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicle.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.vehicle.fullPlate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final isCompliant = widget.vehicle.nextTestDue != null &&
        widget.vehicle.nextTestDue!.isAfter(DateTime.now());
    final daysRemaining = widget.vehicle.daysUntilDue ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompliant ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompliant ? AppColors.success.withOpacity(0.3) : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isCompliant ? AppColors.success.withOpacity(0.2) : AppColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isCompliant ? Icons.check_circle : Icons.warning,
              color: isCompliant ? AppColors.success : AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompliant ? 'Compliant' : 'Test Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCompliant ? AppColors.success : AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompliant
                      ? '$daysRemaining days until next test'
                      : 'Your emission test has expired',
                  style: AppTheme.bodyMd,
                ),
              ],
            ),
          ),
          if (daysRemaining > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isCompliant ? AppColors.success : AppColors.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '$daysRemaining',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'days',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTestRecordCard(TestRecord record) {
    final isPassed = record.result == 'Passed';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isPassed ? AppColors.successLight : AppColors.errorLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  isPassed ? Icons.check_circle : Icons.cancel,
                  color: isPassed ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emission Test ${record.result}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isPassed ? AppColors.success : AppColors.error,
                        ),
                      ),
                      Text(
                        _formatDate(record.testDate),
                        style: AppTheme.bodySm,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPassed ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    record.result.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow('Test Center', record.testCenter),
                if (record.expiryDate != null)
                  _buildDetailRow('Valid Until', _formatDate(record.expiryDate!)),
                if (record.certificateNumber != null)
                  _buildDetailRow('Certificate #', record.certificateNumber!),
              ],
            ),
          ),

          // Emission Values
          if (record.emissions != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Emission Values', style: AppTheme.labelLg),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildEmissionValue('CO', '${record.emissions!.co}%', AppColors.primary),
                      const SizedBox(width: 12),
                      _buildEmissionValue('HC', '${record.emissions!.hc} ppm', AppColors.secondary),
                      const SizedBox(width: 12),
                      _buildEmissionValue('NOx', '${record.emissions!.nox}%', AppColors.accent),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Actions
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar('Download coming soon!'),
                    icon: const Icon(Icons.download, size: 18),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar('Share coming soon!'),
                    icon: const Icon(Icons.share, size: 18),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd),
          Text(value, style: AppTheme.labelLg),
        ],
      ),
    );
  }

  Widget _buildEmissionValue(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class TestRecord {
  final String id;
  final DateTime testDate;
  final DateTime? expiryDate;
  final String result;
  final String testCenter;
  final EmissionValues? emissions;
  final String? certificateNumber;

  TestRecord({
    required this.id,
    required this.testDate,
    this.expiryDate,
    required this.result,
    required this.testCenter,
    this.emissions,
    this.certificateNumber,
  });
}

class EmissionValues {
  final double co;
  final int hc;
  final double nox;

  EmissionValues({
    required this.co,
    required this.hc,
    required this.nox,
  });
}