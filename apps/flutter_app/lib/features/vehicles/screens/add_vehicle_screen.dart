import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/vehicle.dart';

// ============================================
// ADD VEHICLE SCREEN
// Form to add a new vehicle
// ============================================
class AddVehicleScreen extends StatefulWidget {
  final Function(Vehicle)? onVehicleAdded;

  const AddVehicleScreen({
    super.key,
    this.onVehicleAdded,
  });

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _plateNumberController = TextEditingController();
  final _vinController = TextEditingController();

  // Selected values
  String? _selectedEmirate;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  String? _selectedFuelType;
  String? _selectedColor;

  // State
  bool _isLoading = false;
  int _currentStep = 0;

  // Available models based on selected make
  List<String> _availableModels = [];

  @override
  void dispose() {
    _plateNumberController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  void _onMakeChanged(String? make) {
    setState(() {
      _selectedMake = make;
      _selectedModel = null;
      _availableModels = AppConstants.carModels[make] ?? [];
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Create vehicle object
    final vehicle = Vehicle(
      plateNumber: _plateNumberController.text.trim().toUpperCase(),
      emirate: _selectedEmirate!,
      make: _selectedMake!,
      model: _selectedModel!,
      year: _selectedYear!,
      fuelType: _selectedFuelType!,
      color: _selectedColor,
      vin: _vinController.text.trim().isNotEmpty 
          ? _vinController.text.trim().toUpperCase() 
          : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Callback
    widget.onVehicleAdded?.call(vehicle);

    // Show success and go back
    _showSuccessDialog(vehicle);
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.successLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Vehicle Added!',
              style: AppTheme.headingSm,
            ),
            const SizedBox(height: 8),
            Text(
              '${vehicle.displayName}\n${vehicle.fullPlate}',
              style: AppTheme.bodyMd,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, vehicle); // Return to previous screen
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
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
        title: const Text('Add Vehicle'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: _buildStepControls,
          steps: [
            // Step 1: Plate Information
            Step(
              title: const Text('Plate Information'),
              subtitle: _currentStep > 0 
                  ? Text('${_selectedEmirate ?? ''} ${_plateNumberController.text}')
                  : null,
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPlateStep(),
            ),
            
            // Step 2: Vehicle Details
            Step(
              title: const Text('Vehicle Details'),
              subtitle: _currentStep > 1 
                  ? Text('${_selectedMake ?? ''} ${_selectedModel ?? ''}')
                  : null,
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildVehicleStep(),
            ),
            
            // Step 3: Additional Info
            Step(
              title: const Text('Additional Info'),
              subtitle: const Text('Optional'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: _buildAdditionalStep(),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 1: PLATE INFORMATION
  // ==========================================

  Widget _buildPlateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emirate Dropdown
        Text('Emirate', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedEmirate,
          decoration: const InputDecoration(
            hintText: 'Select emirate',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          items: AppConstants.emirates.map((emirate) {
            return DropdownMenuItem(
              value: emirate,
              child: Text(emirate),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedEmirate = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an emirate';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Plate Number
        Text('Plate Number', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        TextFormField(
          controller: _plateNumberController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'e.g., A 12345',
            prefixIcon: Icon(Icons.pin_outlined),
            helperText: 'Enter plate code and number',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter plate number';
            }
            if (value.trim().length < 2) {
              return 'Plate number is too short';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // STEP 2: VEHICLE DETAILS
  // ==========================================

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Make Dropdown
        Text('Make', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedMake,
          decoration: const InputDecoration(
            hintText: 'Select make',
            prefixIcon: Icon(Icons.directions_car_outlined),
          ),
          items: AppConstants.carMakes.map((make) {
            return DropdownMenuItem(
              value: make,
              child: Text(make),
            );
          }).toList(),
          onChanged: _onMakeChanged,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a make';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Model Dropdown
        Text('Model', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedModel,
          decoration: const InputDecoration(
            hintText: 'Select model',
            prefixIcon: Icon(Icons.car_repair),
          ),
          items: _availableModels.map((model) {
            return DropdownMenuItem(
              value: model,
              child: Text(model),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedModel = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a model';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Year Dropdown
        Text('Year', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: _selectedYear,
          decoration: const InputDecoration(
            hintText: 'Select year',
            prefixIcon: Icon(Icons.calendar_today_outlined),
          ),
          items: AppConstants.vehicleYears.map((year) {
            return DropdownMenuItem(
              value: year,
              child: Text(year.toString()),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedYear = value),
          validator: (value) {
            if (value == null) {
              return 'Please select a year';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Fuel Type Dropdown
        Text('Fuel Type', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedFuelType,
          decoration: const InputDecoration(
            hintText: 'Select fuel type',
            prefixIcon: Icon(Icons.local_gas_station_outlined),
          ),
          items: AppConstants.fuelTypes.map((fuel) {
            return DropdownMenuItem(
              value: fuel,
              child: Text(fuel),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedFuelType = value),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select fuel type';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ==========================================
  // STEP 3: ADDITIONAL INFO
  // ==========================================

  Widget _buildAdditionalStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Color Dropdown
        Text('Color (Optional)', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedColor,
          decoration: const InputDecoration(
            hintText: 'Select color',
            prefixIcon: Icon(Icons.palette_outlined),
          ),
          items: AppConstants.vehicleColors.map((color) {
            return DropdownMenuItem(
              value: color,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: _getColorFromName(color),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                  ),
                  Text(color),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedColor = value),
        ),
        const SizedBox(height: 20),

        // VIN Number
        Text('VIN Number (Optional)', style: AppTheme.labelLg),
        const SizedBox(height: 8),
        TextFormField(
          controller: _vinController,
          textCapitalization: TextCapitalization.characters,
          maxLength: 17,
          decoration: const InputDecoration(
            hintText: 'Enter 17-character VIN',
            prefixIcon: Icon(Icons.qr_code),
            helperText: 'Vehicle Identification Number',
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length != 17) {
              return 'VIN must be 17 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Summary Card
        _buildSummaryCard(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSummaryCard() {
    if (_selectedMake == null || _selectedModel == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Vehicle Summary',
                style: AppTheme.labelLg.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Plate', '${_selectedEmirate ?? '-'} ${_plateNumberController.text.toUpperCase()}'),
          _buildSummaryRow('Vehicle', '${_selectedMake ?? '-'} ${_selectedModel ?? '-'}'),
          _buildSummaryRow('Year', _selectedYear?.toString() ?? '-'),
          _buildSummaryRow('Fuel', _selectedFuelType ?? '-'),
          if (_selectedColor != null)
            _buildSummaryRow('Color', _selectedColor!),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.bodyMd),
          Text(value, style: AppTheme.titleMd.copyWith(fontSize: 14)),
        ],
      ),
    );
  }

  // ==========================================
  // STEP CONTROLS
  // ==========================================

  Widget _buildStepControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 2;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          // Continue/Submit Button
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : details.onStepContinue,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isLastStep ? 'Add Vehicle' : 'Continue'),
            ),
          ),
          
          // Back Button
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : details.onStepCancel,
                child: const Text('Back'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onStepContinue() {
    // Validate current step
    if (_currentStep == 0) {
      if (_selectedEmirate == null || _plateNumberController.text.trim().isEmpty) {
        _showSnackBar('Please fill all required fields');
        return;
      }
    } else if (_currentStep == 1) {
      if (_selectedMake == null || _selectedModel == null || 
          _selectedYear == null || _selectedFuelType == null) {
        _showSnackBar('Please fill all required fields');
        return;
      }
    }

    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Submit form
      _handleSubmit();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'silver':
        return Colors.grey.shade400;
      case 'gray':
      case 'grey':
        return Colors.grey;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'brown':
        return Colors.brown;
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }
}