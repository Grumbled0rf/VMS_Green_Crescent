import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/booking_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/test_center.dart';
import '../../../shared/models/booking.dart';

class CreateBookingScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const CreateBookingScreen({super.key, required this.vehicles});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingCenters = true;

  Vehicle? _selectedVehicle;
  TestCenter? _selectedCenter;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  List<TestCenter> _testCenters = [];

  final List<String> _timeSlots = [
    '08:00 - 09:00',
    '09:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '12:00 - 13:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadTestCenters();
  }

  Future<void> _loadTestCenters() async {
    final result = await BookingService.getTestCenters();
    if (mounted) {
      setState(() {
        _isLoadingCenters = false;
        if (result.isSuccess) {
          _testCenters = result.data ?? [];
        }
      });
    }
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 3) {
        setState(() => _currentStep++);
      } else {
        _confirmBooking();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedVehicle == null) {
          _showSnackBar('Please select a vehicle');
          return false;
        }
        break;
      case 1:
        if (_selectedCenter == null) {
          _showSnackBar('Please select a test center');
          return false;
        }
        break;
      case 2:
        if (_selectedDate == null) {
          _showSnackBar('Please select a date');
          return false;
        }
        if (_selectedTimeSlot == null) {
          _showSnackBar('Please select a time slot');
          return false;
        }
        break;
    }
    return true;
  }

  Future<void> _confirmBooking() async {
    setState(() => _isLoading = true);

    final result = await BookingService.create(
      vehicleId: _selectedVehicle!.id!,
      testCenterId: _selectedCenter!.id!,
      bookingDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      price: _selectedCenter!.price,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      _showSuccessDialog(result.data!);
    } else {
      _showSnackBar(result.message ?? 'Failed to create booking');
    }
  }

  void _showSuccessDialog(Booking booking) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: AppColors.success, size: 48),
            ),
            const SizedBox(height: 24),
            Text('Booking Confirmed!', style: AppTheme.headingSm),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text('Confirmation Code', style: AppTheme.bodySm),
                  const SizedBox(height: 4),
                  Text(booking.confirmationCode ?? '', style: AppTheme.headingMd.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(_selectedVehicle?.displayName ?? '', style: AppTheme.titleMd),
            const SizedBox(height: 4),
            Text('${booking.formattedDate} • ${booking.timeSlot}', style: AppTheme.bodyMd),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, booking);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Book Test')),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildStepContent())),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Row(
        children: [
          _buildStepDot(0, 'Vehicle'),
          _buildStepLine(0),
          _buildStepDot(1, 'Center'),
          _buildStepLine(1),
          _buildStepDot(2, 'Date'),
          _buildStepLine(2),
          _buildStepDot(3, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: isCurrent ? 2 : 1),
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : AppColors.gray, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppColors.primary : AppColors.gray)),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16), color: isActive ? AppColors.primary : AppColors.border));
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildSelectVehicle();
      case 1: return _buildSelectCenter();
      case 2: return _buildSelectDateTime();
      case 3: return _buildConfirmation();
      default: return const SizedBox.shrink();
    }
  }

  // Step 1: Select Vehicle
  Widget _buildSelectVehicle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Vehicle', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Choose the vehicle for emission test', style: AppTheme.bodyMd),
        const SizedBox(height: 24),
        ...widget.vehicles.map((v) => _buildVehicleOption(v)),
      ],
    );
  }

  Widget _buildVehicleOption(Vehicle vehicle) {
    final isSelected = _selectedVehicle?.id == vehicle.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedVehicle = vehicle),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_car, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.displayName, style: AppTheme.titleMd),
                  Text(vehicle.fullPlate, style: AppTheme.bodySm),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // Step 2: Select Test Center
  Widget _buildSelectCenter() {
    if (_isLoadingCenters) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Test Center', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Choose where to get your test done', style: AppTheme.bodyMd),
        const SizedBox(height: 24),
        if (_testCenters.isEmpty)
          const Center(child: Text('No test centers available'))
        else
          ..._testCenters.map((c) => _buildCenterOption(c)),
      ],
    );
  }

  Widget _buildCenterOption(TestCenter center) {
    final isSelected = _selectedCenter?.id == center.id;
    final isGreenCrescent = center.isGreenCrescent;

    return GestureDetector(
      onTap: () => setState(() => _selectedCenter = center),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isGreenCrescent ? AppColors.success : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: isGreenCrescent ? AppColors.successLight : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isGreenCrescent ? Icons.home : Icons.location_on,
                    color: isGreenCrescent ? AppColors.success : AppColors.gray,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(center.name, style: AppTheme.titleMd)),
                          if (isGreenCrescent)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(4)),
                              child: const Text('RECOMMENDED', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(center.address, style: AppTheme.bodySm),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildCenterTag(Icons.star, center.formattedRating, AppColors.warning),
                const SizedBox(width: 12),
                _buildCenterTag(Icons.access_time, center.operatingHours, AppColors.gray),
                const Spacer(),
                Text(center.formattedPrice, style: AppTheme.titleMd.copyWith(color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterTag(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: AppColors.gray)),
      ],
    );
  }

  // Step 3: Select Date & Time
  Widget _buildSelectDateTime() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date & Time', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Pick your preferred slot', style: AppTheme.bodyMd),
        const SizedBox(height: 24),

        // Date picker
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date', style: AppTheme.titleMd),
              const SizedBox(height: 12),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: AppColors.primary),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null ? _formatDate(_selectedDate!) : 'Select Date',
                        style: AppTheme.bodyMd.copyWith(color: _selectedDate != null ? AppColors.dark : AppColors.gray),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.lightGray),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Time slots
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time Slot', style: AppTheme.titleMd),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _timeSlots.map((slot) => _buildTimeSlotChip(slot)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotChip(String slot) {
    final isSelected = _selectedTimeSlot == slot;
    return GestureDetector(
      onTap: () => setState(() => _selectedTimeSlot = slot),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        ),
        child: Text(slot, style: TextStyle(color: isSelected ? Colors.white : AppColors.dark, fontWeight: FontWeight.w500, fontSize: 13)),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Step 4: Confirmation
  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Booking', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Review your booking details', style: AppTheme.bodyMd),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              _buildConfirmRow('Vehicle', _selectedVehicle?.displayName ?? ''),
              _buildConfirmRow('Plate', _selectedVehicle?.fullPlate ?? ''),
              const Divider(height: 24),
              _buildConfirmRow('Test Center', _selectedCenter?.name ?? ''),
              _buildConfirmRow('Address', _selectedCenter?.address ?? ''),
              const Divider(height: 24),
              _buildConfirmRow('Date', _selectedDate != null ? _formatDate(_selectedDate!) : ''),
              _buildConfirmRow('Time', _selectedTimeSlot ?? ''),
              const Divider(height: 24),
              _buildConfirmRow('Price', _selectedCenter?.formattedPrice ?? '', isPrice: true),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Payment will be collected at the test center', style: AppTheme.bodySm.copyWith(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd),
          Text(value, style: isPrice ? AppTheme.titleLg.copyWith(color: AppColors.primary) : AppTheme.titleMd),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: AppColors.white, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(
        children: [
          if (_currentStep > 0) Expanded(child: OutlinedButton(onPressed: _isLoading ? null : _previousStep, child: const Text('Back'))),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(_currentStep == 3 ? 'Confirm Booking' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}