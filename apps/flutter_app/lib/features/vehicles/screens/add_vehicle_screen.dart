import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../shared/models/vehicle.dart';

// ============================================
// ADD VEHICLE SCREEN
// ============================================
class AddVehicleScreen extends StatefulWidget {
  final Function(Vehicle)? onVehicleAdded;

  const AddVehicleScreen({super.key, this.onVehicleAdded});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  int _currentStep = 0;
  bool _isLoading = false;

  final _plateNumberController = TextEditingController();
  final _vinController = TextEditingController();

  String? _selectedEmirate;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  String? _selectedFuelType;
  String? _selectedColor;

  List<String> _availableModels = [];

  @override
  void dispose() {
    _plateNumberController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      if (_currentStep < 2) {
        setState(() => _currentStep++);
      } else {
        _saveVehicle();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_selectedEmirate == null) { _showSnackBar('Please select an emirate'); return false; }
        if (_plateNumberController.text.trim().isEmpty) { _showSnackBar('Please enter plate number'); return false; }
        break;
      case 1:
        if (_selectedMake == null) { _showSnackBar('Please select a make'); return false; }
        if (_selectedModel == null) { _showSnackBar('Please select a model'); return false; }
        if (_selectedYear == null) { _showSnackBar('Please select a year'); return false; }
        if (_selectedFuelType == null) { _showSnackBar('Please select fuel type'); return false; }
        break;
      case 2:
        if (_vinController.text.isNotEmpty && _vinController.text.length != 17) { _showSnackBar('VIN must be 17 characters'); return false; }
        break;
    }
    return true;
  }

  Future<void> _saveVehicle() async {
    setState(() => _isLoading = true);

    final vehicle = Vehicle(
      plateNumber: _plateNumberController.text.trim().toUpperCase(),
      emirate: _selectedEmirate!,
      make: _selectedMake!,
      model: _selectedModel!,
      year: _selectedYear!,
      fuelType: _selectedFuelType!,
      color: _selectedColor,
      vin: _vinController.text.trim().isNotEmpty ? _vinController.text.trim().toUpperCase() : null,
    );

    final result = await VehicleService.create(vehicle);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      widget.onVehicleAdded?.call(result.data!);
      _showSuccessDialog(result.data!);
    } else {
      _showSnackBar(result.message ?? 'Failed to save vehicle');
    }
  }

  void _showSuccessDialog(Vehicle vehicle) {
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
            Text('Vehicle Added!', style: AppTheme.headingSm),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  Text(vehicle.displayName, style: AppTheme.titleMd),
                  const SizedBox(height: 4),
                  Text(vehicle.fullPlate, style: AppTheme.bodyMd),
                ],
              ),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, vehicle);
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
      appBar: AppBar(title: const Text('Add Vehicle')),
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
          _buildStepDot(0, 'Plate'),
          _buildStepLine(0),
          _buildStepDot(1, 'Details'),
          _buildStepLine(1),
          _buildStepDot(2, 'More'),
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
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? AppColors.primary : AppColors.border, width: isCurrent ? 2 : 1),
          ),
          child: Center(
            child: isActive && !isCurrent
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : AppColors.gray, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? AppColors.primary : AppColors.gray, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isActive = _currentStep > afterStep;
    return Expanded(child: Container(height: 2, margin: const EdgeInsets.only(bottom: 16), color: isActive ? AppColors.primary : AppColors.border));
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Plate Information', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Enter your vehicle\'s plate details', style: AppTheme.bodyMd),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedEmirate,
                decoration: const InputDecoration(labelText: 'Emirate', prefixIcon: Icon(Icons.location_on_outlined)),
                items: AppConstants.emirates.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setState(() => _selectedEmirate = v),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _plateNumberController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Plate Number', hintText: 'e.g., A 12345', prefixIcon: Icon(Icons.pin_outlined)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Vehicle Details', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Enter your vehicle\'s specifications', style: AppTheme.bodyMd),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMake,
                decoration: const InputDecoration(labelText: 'Make', prefixIcon: Icon(Icons.directions_car_outlined)),
                items: AppConstants.carMakes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedMake = v;
                    _selectedModel = null;
                    _availableModels = AppConstants.carModels[v] ?? [];
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedModel,
                decoration: const InputDecoration(labelText: 'Model', prefixIcon: Icon(Icons.car_repair)),
                items: _availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (v) => setState(() => _selectedModel = v),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _selectedYear,
                decoration: const InputDecoration(labelText: 'Year', prefixIcon: Icon(Icons.calendar_today_outlined)),
                items: AppConstants.vehicleYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
                onChanged: (v) => setState(() => _selectedYear = v),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedFuelType,
                decoration: const InputDecoration(labelText: 'Fuel Type', prefixIcon: Icon(Icons.local_gas_station_outlined)),
                items: AppConstants.fuelTypes.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                onChanged: (v) => setState(() => _selectedFuelType = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information', style: AppTheme.headingSm),
        const SizedBox(height: 8),
        Text('Optional details about your vehicle', style: AppTheme.bodyMd),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _selectedColor,
                decoration: const InputDecoration(labelText: 'Color (Optional)', prefixIcon: Icon(Icons.palette_outlined)),
                items: AppConstants.vehicleColors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _selectedColor = v),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _vinController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 17,
                decoration: const InputDecoration(labelText: 'VIN Number (Optional)', prefixIcon: Icon(Icons.qr_code), helperText: '17-character Vehicle Identification Number'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSummary(),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: AppTheme.titleMd),
          const SizedBox(height: 12),
          _buildSummaryRow('Plate', '${_selectedEmirate ?? ''} ${_plateNumberController.text.toUpperCase()}'),
          _buildSummaryRow('Vehicle', '${_selectedMake ?? ''} ${_selectedModel ?? ''}'),
          _buildSummaryRow('Year', _selectedYear?.toString() ?? ''),
          _buildSummaryRow('Fuel', _selectedFuelType ?? ''),
          if (_selectedColor != null) _buildSummaryRow('Color', _selectedColor!),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: AppTheme.bodySm), Text(value, style: AppTheme.labelLg)],
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
                  : Text(_currentStep == 2 ? 'Save Vehicle' : 'Continue'),
            ),
          ),
        ],
      ),
    );
  }
}