import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/test_center.dart';
import '../../../shared/models/booking.dart';

// ============================================
// CREATE BOOKING SCREEN
// Step-by-step booking wizard
// ============================================
class CreateBookingScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Vehicle? preselectedVehicle;

  const CreateBookingScreen({
    super.key,
    required this.vehicles,
    this.preselectedVehicle,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  // Selections
  Vehicle? _selectedVehicle;
  TestCenter? _selectedCenter;
  DateTime? _selectedDate;
  String? _selectedTimeSlot;

  // Demo test centers - Green Crescent Onsite is first and recommended
  final List<TestCenter> _testCenters = [
    // ⭐ RECOMMENDED - Green Crescent Onsite Test
    TestCenter(
      id: 'gc-onsite',
      name: 'Green Crescent Onsite Test',
      address: 'We come to your location',
      emirate: 'All Emirates',
      phone: '+971 800 GCTEST',
      price: 150,
      rating: 4.9,
      openTime: '08:00 AM',
      closeTime: '06:00 PM',
      isActive: true,
    ),
    // Regular test centers
    TestCenter(
      id: '1',
      name: 'Tasjeel Deira',
      address: 'Al Khabaisi, Deira',
      emirate: 'Dubai',
      phone: '+971 4 269 2222',
      price: 120,
      rating: 4.5,
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    TestCenter(
      id: '2',
      name: 'ADNOC Service Station',
      address: 'Sheikh Zayed Road',
      emirate: 'Dubai',
      phone: '+971 4 333 4444',
      price: 120,
      rating: 4.3,
      openTime: '08:00 AM',
      closeTime: '06:00 PM',
    ),
    TestCenter(
      id: '3',
      name: 'RTA Testing Center',
      address: 'Al Quoz Industrial Area',
      emirate: 'Dubai',
      phone: '+971 4 345 6789',
      price: 120,
      rating: 4.7,
      openTime: '07:30 AM',
      closeTime: '05:30 PM',
    ),
    TestCenter(
      id: '4',
      name: 'Shamil Testing',
      address: 'Al Nahda, Sharjah',
      emirate: 'Sharjah',
      phone: '+971 6 555 1234',
      price: 100,
      rating: 4.2,
      openTime: '08:00 AM',
      closeTime: '05:00 PM',
    ),
    TestCenter(
      id: '5',
      name: 'ADNOC Musaffah',
      address: 'Musaffah Industrial Area',
      emirate: 'Abu Dhabi',
      phone: '+971 2 666 7890',
      price: 130,
      rating: 4.6,
      openTime: '07:00 AM',
      closeTime: '06:00 PM',
    ),
  ];

  // Available time slots (filtered based on date)
  List<String> get _availableTimeSlots {
    // In real app, check availability from API
    return AppConstants.timeSlots;
  }

  // Check if center is Green Crescent Onsite
  bool _isOnsiteTest(TestCenter center) {
    return center.id == 'gc-onsite';
  }

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.preselectedVehicle;
  }

  // ==========================================
  // ACTIONS
  // ==========================================

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
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
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

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Generate confirmation code
    final prefix = _isOnsiteTest(_selectedCenter!) ? 'GC' : 'VMS';
    final confirmationCode = '$prefix-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    // Create booking
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      vehicleId: _selectedVehicle!.id ?? '',
      testCenterId: _selectedCenter!.id ?? '',
      bookingDate: _selectedDate!,
      timeSlot: _selectedTimeSlot!,
      status: 'confirmed',
      confirmationCode: confirmationCode,
      price: _selectedCenter!.price,
      vehicleName: _selectedVehicle!.displayName,
      vehiclePlate: _selectedVehicle!.fullPlate,
      testCenterName: _selectedCenter!.name,
      testCenterAddress: _isOnsiteTest(_selectedCenter!) 
          ? 'Onsite - We come to you' 
          : _selectedCenter!.address,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Show success and return
    _showSuccessDialog(booking);
  }

  void _showSuccessDialog(Booking booking) {
    final isOnsite = _isOnsiteTest(_selectedCenter!);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isOnsite ? AppColors.primaryLight : AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOnsite ? Icons.home_work : Icons.check_circle,
                color: isOnsite ? AppColors.primary : AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isOnsite ? 'Onsite Test Booked!' : 'Booking Confirmed!',
              style: AppTheme.headingSm,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                booking.confirmationCode ?? '',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${booking.formattedDate}\nat ${booking.timeSlot}',
              style: AppTheme.bodyMd,
              textAlign: TextAlign.center,
            ),
            if (isOnsite) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Our team will contact you to confirm your location.',
                        style: AppTheme.bodySm.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, booking); // Return booking
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Emission Test'),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),

          // Bottom buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  // ==========================================
  // PROGRESS INDICATOR
  // ==========================================

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.white,
      child: Row(
        children: [
          _buildStepCircle(0, 'Vehicle'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Center'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Date'),
          _buildStepLine(2),
          _buildStepCircle(3, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.border,
              width: isCurrent ? 2 : 1,
            ),
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.gray,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.primary : AppColors.gray,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;

    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 16),
        color: isActive ? AppColors.primary : AppColors.border,
      ),
    );
  }

  // ==========================================
  // STEP CONTENT
  // ==========================================

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildVehicleStep();
      case 1:
        return _buildCenterStep();
      case 2:
        return _buildDateTimeStep();
      case 3:
        return _buildConfirmStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // STEP 1: Select Vehicle
  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Vehicle', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text(
          'Choose which vehicle needs an emission test',
          style: AppTheme.bodyMd,
        ),
        const SizedBox(height: 24),
        ...widget.vehicles.map((vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildVehicleOption(vehicle),
            )),
      ],
    );
  }

  Widget _buildVehicleOption(Vehicle vehicle) {
    final isSelected = _selectedVehicle?.id == vehicle.id;

    return InkWell(
      onTap: () => setState(() => _selectedVehicle = vehicle),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.directions_car,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(vehicle.displayName, style: AppTheme.titleMd),
                  Text(vehicle.fullPlate, style: AppTheme.bodySm),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // STEP 2: Select Test Center
  Widget _buildCenterStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Test Center', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text(
          'Choose a convenient location for your test',
          style: AppTheme.bodyMd,
        ),
        const SizedBox(height: 24),
        
        // Map through centers - first one is Green Crescent Onsite (recommended)
        ..._testCenters.asMap().entries.map((entry) {
          final index = entry.key;
          final center = entry.value;
          final isOnsite = _isOnsiteTest(center);
          
          return Padding(
            padding: EdgeInsets.only(bottom: isOnsite ? 20 : 12),
            child: isOnsite 
                ? _buildOnsiteOption(center)
                : _buildCenterOption(center),
          );
        }),
      ],
    );
  }

  // ⭐ HIGHLIGHTED ONSITE OPTION
  Widget _buildOnsiteOption(TestCenter center) {
    final isSelected = _selectedCenter?.id == center.id;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: () => setState(() => _selectedCenter = center),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isSelected 
                  ? AppColors.primaryGradient 
                  : LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.1),
                        AppColors.primaryDark.withOpacity(0.1),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary,
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.home_work_rounded,
                        color: isSelected ? Colors.white : Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  center.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.primary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: Colors.white, size: 24),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: isSelected ? Colors.white70 : AppColors.primary.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                center.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white70 : AppColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Benefits row
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBenefit(
                        Icons.access_time,
                        'Save Time',
                        isSelected,
                      ),
                      _buildBenefit(
                        Icons.car_repair,
                        'No Travel',
                        isSelected,
                      ),
                      _buildBenefit(
                        Icons.verified,
                        'Certified',
                        isSelected,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Price and rating row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 18,
                          color: isSelected ? AppColors.accent : AppColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          center.ratingDisplay,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.dark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${center.emirate}',
                          style: TextStyle(
                            color: isSelected ? Colors.white70 : AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        center.formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppColors.primary : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // RECOMMENDED badge
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'RECOMMENDED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String label, bool isSelected) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : AppColors.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.dark,
          ),
        ),
      ],
    );
  }

  // Regular test center option
  Widget _buildCenterOption(TestCenter center) {
    final isSelected = _selectedCenter?.id == center.id;

    return InkWell(
      onTap: () => setState(() => _selectedCenter = center),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.secondaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.location_on,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center.name, style: AppTheme.titleMd),
                  Text(center.fullAddress, style: AppTheme.bodySm),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text(center.ratingDisplay, style: AppTheme.bodySm),
                      const SizedBox(width: 12),
                      Text(center.formattedPrice,
                          style: AppTheme.labelLg.copyWith(color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  // STEP 3: Select Date & Time
  Widget _buildDateTimeStep() {
    final isOnsite = _selectedCenter != null && _isOnsiteTest(_selectedCenter!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Date & Time', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text(
          isOnsite 
              ? 'Choose when you want us to visit you'
              : 'Choose your preferred appointment slot',
          style: AppTheme.bodyMd,
        ),
        const SizedBox(height: 24),

        // Onsite info banner
        if (isOnsite) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.home_work, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Onsite Test Selected',
                        style: AppTheme.labelLg.copyWith(color: AppColors.primary),
                      ),
                      Text(
                        'Our team will come to your location',
                        style: AppTheme.bodySm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Date picker
        Text('Date', style: AppTheme.labelLg),
        const SizedBox(height: 12),
        InkWell(
          onTap: _pickDate,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.gray),
                const SizedBox(width: 12),
                Text(
                  _selectedDate != null
                      ? _formatDate(_selectedDate!)
                      : 'Select a date',
                  style: _selectedDate != null
                      ? AppTheme.titleMd
                      : AppTheme.bodyMd.copyWith(color: AppColors.lightGray),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, color: AppColors.gray),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Time slots
        Text(
          isOnsite ? 'Preferred Time Window' : 'Available Time Slots',
          style: AppTheme.labelLg,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableTimeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return InkWell(
              onTap: () => setState(() => _selectedTimeSlot = slot),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  slot,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.dark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _selectedTimeSlot = null; // Reset time when date changes
      });
    }
  }

  // STEP 4: Confirm
  Widget _buildConfirmStep() {
    final isOnsite = _selectedCenter != null && _isOnsiteTest(_selectedCenter!);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Booking', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text(
          'Review your booking details',
          style: AppTheme.bodyMd,
        ),
        const SizedBox(height: 24),

        // Summary card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildSummaryRow(
                icon: Icons.directions_car,
                label: 'Vehicle',
                value: _selectedVehicle?.displayName ?? '',
                subtitle: _selectedVehicle?.fullPlate,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                icon: isOnsite ? Icons.home_work : Icons.location_on,
                label: isOnsite ? 'Service Type' : 'Test Center',
                value: _selectedCenter?.name ?? '',
                subtitle: isOnsite ? 'Onsite - We come to you' : _selectedCenter?.address,
                highlight: isOnsite,
              ),
              const Divider(height: 24),
              _buildSummaryRow(
                icon: Icons.calendar_today,
                label: 'Date & Time',
                value: _selectedDate != null ? _formatDate(_selectedDate!) : '',
                subtitle: _selectedTimeSlot,
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount', style: AppTheme.titleMd),
                  Text(
                    _selectedCenter?.formattedPrice ?? 'AED 120',
                    style: AppTheme.headingSm.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Info note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOnsite ? AppColors.primaryLight : AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                isOnsite ? Icons.home_work : Icons.info_outline,
                color: isOnsite ? AppColors.primary : AppColors.info,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnsite
                      ? 'Our Green Crescent team will call you to confirm your exact location before the visit.'
                      : 'Payment will be collected at the test center. Please arrive 10 minutes before your appointment.',
                  style: AppTheme.bodySm.copyWith(
                    color: isOnsite ? AppColors.primary : AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: highlight ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: highlight ? Colors.white : AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodySm),
              Text(
                value,
                style: highlight 
                    ? AppTheme.titleMd.copyWith(color: AppColors.primary)
                    : AppTheme.titleMd,
              ),
              if (subtitle != null)
                Text(subtitle, style: AppTheme.bodySm),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // BOTTOM BUTTONS
  // ==========================================

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _previousStep,
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _nextStep,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(_currentStep == 3 ? 'Confirm Booking' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}