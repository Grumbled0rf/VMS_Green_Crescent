import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../shared/models/vehicle.dart';

// ============================================
// EDIT VEHICLE SCREEN
// ============================================
class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;
  final Function(Vehicle)? onVehicleSaved;

  const EditVehicleScreen({super.key, required this.vehicle, this.onVehicleSaved});

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _plateNumberController;
  late TextEditingController _vinController;

  String? _selectedEmirate;
  String? _selectedMake;
  String? _selectedModel;
  int? _selectedYear;
  String? _selectedFuelType;
  String? _selectedColor;

  bool _isLoading = false;
  bool _hasChanges = false;

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
    _availableModels = AppConstants.carModels[v.make] ?? [];
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _vinController.dispose();
    super.dispose();
  }

  void _onMakeChanged(String? make) {
    setState(() {
      _selectedMake = make;
      _selectedModel = null;
      _availableModels = AppConstants.carModels[make] ?? [];
      _hasChanges = true;
    });
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedVehicle = widget.vehicle.copyWith(
      plateNumber: _plateNumberController.text.trim().toUpperCase(),
      emirate: _selectedEmirate,
      make: _selectedMake,
      model: _selectedModel,
      year: _selectedYear,
      fuelType: _selectedFuelType,
      color: _selectedColor,
      vin: _vinController.text.trim().isNotEmpty ? _vinController.text.trim().toUpperCase() : null,
    );

    final result = await VehicleService.update(updatedVehicle);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      widget.onVehicleSaved?.call(result.data!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle updated successfully! ✓')));
      Navigator.pop(context, result.data);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message ?? 'Failed to update vehicle')));
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
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
                _buildVehiclePreview(),
                const SizedBox(height: 24),
                _buildSectionTitle('Plate Information'),
                const SizedBox(height: 16),
                _buildPlateSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('Vehicle Details'),
                const SizedBox(height: 16),
                _buildVehicleSection(),
                const SizedBox(height: 24),
                _buildSectionTitle('Additional Information'),
                const SizedBox(height: 16),
                _buildAdditionalSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVehiclePreview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.directions_car, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_selectedMake ?? ''} ${_selectedModel ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${_selectedEmirate ?? ''} ${_plateNumberController.text.toUpperCase()}', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: AppTheme.titleLg);

  Widget _buildPlateSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedEmirate,
            decoration: const InputDecoration(labelText: 'Emirate', prefixIcon: Icon(Icons.location_on_outlined)),
            items: AppConstants.emirates.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) { setState(() { _selectedEmirate = v; _hasChanges = true; }); },
            validator: (v) => v == null ? 'Please select an emirate' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _plateNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Plate Number', prefixIcon: Icon(Icons.pin_outlined)),
            onChanged: (_) => _markChanged(),
            validator: (v) => v == null || v.trim().isEmpty ? 'Please enter plate number' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedMake,
            decoration: const InputDecoration(labelText: 'Make', prefixIcon: Icon(Icons.directions_car_outlined)),
            items: AppConstants.carMakes.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: _onMakeChanged,
            validator: (v) => v == null ? 'Please select a make' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedModel,
            decoration: const InputDecoration(labelText: 'Model', prefixIcon: Icon(Icons.car_repair)),
            items: _availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) { setState(() { _selectedModel = v; _hasChanges = true; }); },
            validator: (v) => v == null ? 'Please select a model' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedYear,
            decoration: const InputDecoration(labelText: 'Year', prefixIcon: Icon(Icons.calendar_today_outlined)),
            items: AppConstants.vehicleYears.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
            onChanged: (v) { setState(() { _selectedYear = v; _hasChanges = true; }); },
            validator: (v) => v == null ? 'Please select a year' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedFuelType,
            decoration: const InputDecoration(labelText: 'Fuel Type', prefixIcon: Icon(Icons.local_gas_station_outlined)),
            items: AppConstants.fuelTypes.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) { setState(() { _selectedFuelType = v; _hasChanges = true; }); },
            validator: (v) => v == null ? 'Please select fuel type' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedColor,
            decoration: const InputDecoration(labelText: 'Color (Optional)', prefixIcon: Icon(Icons.palette_outlined)),
            items: AppConstants.vehicleColors.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { setState(() { _selectedColor = v; _hasChanges = true; }); },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _vinController,
            textCapitalization: TextCapitalization.characters,
            maxLength: 17,
            decoration: const InputDecoration(labelText: 'VIN Number (Optional)', prefixIcon: Icon(Icons.qr_code), helperText: '17-character Vehicle Identification Number'),
            onChanged: (_) => _markChanged(),
            validator: (v) => v != null && v.isNotEmpty && v.length != 17 ? 'VIN must be 17 characters' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_hasChanges ? null : _handleSave,
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Save Changes'),
      ),
    );
  }
}