import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/vehicle.dart';

// ============================================
// EDIT VEHICLE SCREEN
// Form to edit existing vehicle
// ============================================
class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle)? onVehicleSaved;

  const EditVehicleScreen({
    super.key,
    required this.vehicle,
    this.onVehicleSaved,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _plateNumberController;
  late TextEditingController _vinController;

  // Selected values
  String? _selectedEmirate;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  String? _selectedFuelType;
  String? _selectedColor;

  // State
  bool _isLoading = false;
  bool _hasChanges = false;

  // Available models based on selected make
  List<String> _availableModels = [];

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    final v = widget.vehicle;
    
    _plateNumberController = TextEditingController(text: v.plateNumber);
    _vinController = TextEditingController(text: v.vin ?? '');
    
    _selectedEmirate = v.emirate;
    _selectedMake = v.make;
    _selectedModel = v.model;
    _selectedYear = v.year;
    _selectedFuelType = v.fuelType;
    _selectedColor = v.color;

    // Set available models for the selected make
    _availableModels = AppConstants.carModels[v.make] ?? [];
  }

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
      _hasChanges = true;
    });
  }

  void _markChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Create updated vehicle
    final updatedVehicle = widget.vehicle.copyWith(
      plateNumber: _plateNumberController.text.trim().toUpperCase(),
      emirate: _selectedEmirate,
      make: _selectedMake,
      model: _selectedModel,
      year: _selectedYear,
      fuelType: _selectedFuelType,
      color: _selectedColor,
      vin: _vinController.text.trim().isNotEmpty
          ? _vinController.text.trim().toUpperCase()
          : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    // Callback
    widget.onVehicleSaved?.call(updatedVehicle);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vehicle updated successfully! ✓')),
    );

    // Go back with result
    Navigator.pop(context, updatedVehicle);
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Editing'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Vehicle'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Preview
                _buildVehiclePreview(),
                const SizedBox(height: 24),

                // Plate Section
                _buildSectionTitle('Plate Information'),
                const SizedBox(height: 16),
                _buildPlateSection(),
                const SizedBox(height: 24),

                // Vehicle Section
                _buildSectionTitle('Vehicle Details'),
                const SizedBox(height: 16),
                _buildVehicleSection(),
                const SizedBox(height: 24),

                // Additional Section
                _buildSectionTitle('Additional Information'),
                const SizedBox(height: 16),
                _buildAdditionalSection(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VEHICLE PREVIEW
  // ==========================================

  Widget _buildVehiclePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedMake ?? ''} ${_selectedModel ?? ''}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_selectedEmirate ?? ''} ${_plateNumberController.text.toUpperCase()}',
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

  // ==========================================
  // SECTION TITLE
  // ==========================================

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTheme.titleLg);
  }

  // ==========================================
  // PLATE SECTION
  // ==========================================

  Widget _buildPlateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Emirate
          DropdownButtonFormField<String>(
            value: _selectedEmirate,
            decoration: const InputDecoration(
              labelText: 'Emirate',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
            items: AppConstants.emirates.map((emirate) {
              return DropdownMenuItem(value: emirate, child: Text(emirate));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedEmirate = value;
                _hasChanges = true;
              });
            },
            validator: (value) =>
                value == null ? 'Please select an emirate' : null,
          ),
          const SizedBox(height: 16),

          // Plate Number
          TextFormField(
            controller: _plateNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Plate Number',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            onChanged: (_) => _markChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter plate number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VEHICLE SECTION
  // ==========================================

  Widget _buildVehicleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Make
          DropdownButtonFormField<String>(
            value: _selectedMake,
            decoration: const InputDecoration(
              labelText: 'Make',
              prefixIcon: Icon(Icons.directions_car_outlined),
            ),
            items: AppConstants.carMakes.map((make) {
              return DropdownMenuItem(value: make, child: Text(make));
            }).toList(),
            onChanged: _onMakeChanged,
            validator: (value) =>
                value == null ? 'Please select a make' : null,
          ),
          const SizedBox(height: 16),

          // Model
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: const InputDecoration(
              labelText: 'Model',
              prefixIcon: Icon(Icons.car_repair),
            ),
            items: _availableModels.map((model) {
              return DropdownMenuItem(value: model, child: Text(model));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedModel = value;
                _hasChanges = true;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a model' : null,
          ),
          const SizedBox(height: 16),

          // Year
          DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: const InputDecoration(
              labelText: 'Year',
              prefixIcon: Icon(Icons.calendar_today_outlined),
            ),
            items: AppConstants.vehicleYears.map((year) {
              return DropdownMenuItem(value: year, child: Text(year.toString()));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedYear = value;
                _hasChanges = true;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a year' : null,
          ),
          const SizedBox(height: 16),

          // Fuel Type
          DropdownButtonFormField<String>(
            value: _selectedFuelType,
            decoration: const InputDecoration(
              labelText: 'Fuel Type',
              prefixIcon: Icon(Icons.local_gas_station_outlined),
            ),
            items: AppConstants.fuelTypes.map((fuel) {
              return DropdownMenuItem(value: fuel, child: Text(fuel));
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedFuelType = value;
                _hasChanges = true;
              });
            },
            validator: (value) =>
                value == null ? 'Please select fuel type' : null,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ADDITIONAL SECTION
  // ==========================================

  Widget _buildAdditionalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Color
          DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: const InputDecoration(
              labelText: 'Color (Optional)',
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
            onChanged: (value) {
              setState(() {
                _selectedColor = value;
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 16),

          // VIN
          TextFormField(
            controller: _vinController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 17,
            decoration: const InputDecoration(
              labelText: 'VIN Number (Optional)',
              prefixIcon: Icon(Icons.qr_code),
              helperText: '17-character Vehicle Identification Number',
            ),
            onChanged: (_) => _markChanged(),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length != 17) {
                return 'VIN must be 17 characters';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SAVE BUTTON
  // ==========================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_hasChanges ? null : _handleSave,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Save Changes'),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

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