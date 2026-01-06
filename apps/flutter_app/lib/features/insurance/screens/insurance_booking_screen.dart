import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/insurance.dart';
import '../../../core/services/insurance_service.dart';

class InsuranceBookingScreen extends StatefulWidget {
  final Vehicle vehicle;

  const InsuranceBookingScreen({super.key, required this.vehicle});

  @override
  State<InsuranceBookingScreen> createState() => _InsuranceBookingScreenState();
}

class _InsuranceBookingScreenState extends State<InsuranceBookingScreen> {
  int _currentStep = 0;
  InsuranceCompany? _selectedCompany;
  InsuranceType _selectedType = InsuranceType.thirdParty;
  InsurancePlan _selectedPlan = InsurancePlan.basic;
  InsuranceQuote? _quote;
  bool _isLoadingQuote = false;
  bool _isBooking = false;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  // Theme helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _borderColor => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;

  List<InsuranceCompany> get _partnerCompanies => UAEInsuranceCompanies.getPartners();
  List<InsuranceCompany> get _otherCompanies => UAEInsuranceCompanies.getOtherCompanies();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('Book Insurance', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
      ),
      body: Column(
        children: [
          // Progress Stepper
          _buildStepper(),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildStepContent(),
            ),
          ),
          
          // Bottom Buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    final steps = ['Company', 'Plan', 'Quote', 'Confirm'];
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: _cardColor,
      child: Row(
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success
                        : isActive
                            ? _primaryColor
                            : _borderColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : _textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? AppColors.success : _borderColor,
                    ),
                  ),
                if (index < steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCompanySelection();
      case 1:
        return _buildPlanSelection();
      case 2:
        return _buildQuoteReview();
      case 3:
        return _buildConfirmation();
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // STEP 1: Company Selection
  // ==========================================
  Widget _buildCompanySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Vehicle Info
        _buildVehicleCard(),
        const SizedBox(height: 24),

        // Partner Companies
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('PARTNER', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            Text('Recommended Companies', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        ..._partnerCompanies.map((company) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCompanyCard(company, isPartner: true),
        )),

        const SizedBox(height: 24),

        // Other Companies
        Text('Other Insurance Providers', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ..._otherCompanies.map((company) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCompanyCard(company, isPartner: false),
        )),
      ],
    );
  }

  Widget _buildVehicleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.directions_car, color: _primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.vehicle.displayName, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                Text(widget.vehicle.fullPlate, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
              ],
            ),
          ),
          Icon(Icons.verified, color: _primaryColor),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(InsuranceCompany company, {required bool isPartner}) {
    final isSelected = _selectedCompany?.id == company.id;
    
    return InkWell(
      onTap: () => setState(() => _selectedCompany = company),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _primaryColor : _borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Logo
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(company.logo, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(company.name, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                      ),
                      if (isPartner)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Partner', style: TextStyle(color: AppColors.success, fontSize: 10)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.warning, size: 16),
                      const SizedBox(width: 4),
                      Text('${company.rating}', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
                      Text(' (${company.reviewCount} reviews)', style: TextStyle(color: _textSecondary, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'From AED ${company.basePrices['basic']?.toStringAsFixed(0)}/year',
                    style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? _primaryColor : _borderColor,
                  width: 2,
                ),
                color: isSelected ? _primaryColor : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STEP 2: Plan Selection
  // ==========================================
  Widget _buildPlanSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected Company
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(_selectedCompany?.logo ?? '🏢', style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(_selectedCompany?.name ?? '', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Insurance Type
        Text('Insurance Type', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...InsuranceType.values.map((type) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildTypeOption(type),
        )),

        const SizedBox(height: 24),

        // Plan Selection
        Text('Select Plan', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...InsurancePlan.values.map((plan) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPlanCard(plan),
        )),

        const SizedBox(height: 24),

        // Start Date
        Text('Start Date', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectStartDate,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: _primaryColor),
                const SizedBox(width: 12),
                Text(
                  '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                  style: AppTheme.bodyLg.copyWith(color: _textPrimary),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: _textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(InsuranceType type) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _primaryColor : _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: 2),
                color: isSelected ? _primaryColor : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(type.displayName, style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
                  Text(_getTypeDescription(type), style: TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTypeDescription(InsuranceType type) {
    switch (type) {
      case InsuranceType.thirdParty:
        return 'Basic coverage for third-party liability';
      case InsuranceType.thirdPartyFireTheft:
        return 'Third party + fire and theft protection';
      case InsuranceType.comprehensive:
        return 'Full coverage including own damage';
    }
  }

  Widget _buildPlanCard(InsurancePlan plan) {
    final isSelected = _selectedPlan == plan;
    final price = _selectedCompany?.basePrices[plan.name] ?? 1000;
    
    return InkWell(
      onTap: () => setState(() => _selectedPlan = plan),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(plan.displayName, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                      if (plan == InsurancePlan.premium) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AED ${price.toStringAsFixed(0)}/year',
                    style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: 2),
                color: isSelected ? _primaryColor : Colors.transparent,
              ),
              child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  // ==========================================
  // STEP 3: Quote Review
  // ==========================================
  Widget _buildQuoteReview() {
    if (_isLoadingQuote) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quote == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: _textSecondary),
            const SizedBox(height: 16),
            Text('Failed to load quote', style: TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadQuote, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quote Summary Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withBlue(180)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_selectedCompany?.logo ?? '🏢', style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_quote!.companyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(_quote!.type.displayName, style: TextStyle(color: Colors.white.withOpacity(0.8))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text('Annual Premium', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('AED ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18)),
                  Text(_quote!.premium.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  Text('/year', style: TextStyle(color: Colors.white.withOpacity(0.8))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Coverage: AED ${(_quote!.coverageAmount / 1000).toStringAsFixed(0)}K',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Coverage Details
        Text('What\'s Covered', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            children: _quote!.features.map((feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(feature, style: TextStyle(color: _textPrimary))),
                ],
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Policy Details
        Text('Policy Details', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        _buildDetailRow('Vehicle', widget.vehicle.displayName),
        _buildDetailRow('Plan', _quote!.plan.displayName),
        _buildDetailRow('Start Date', '${_startDate.day}/${_startDate.month}/${_startDate.year}'),
        _buildDetailRow('End Date', '${_startDate.add(const Duration(days: 365)).day}/${_startDate.add(const Duration(days: 365)).month}/${_startDate.add(const Duration(days: 365)).year}'),
        
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quote valid until ${_quote!.validUntil.day}/${_quote!.validUntil.month}/${_quote!.validUntil.year}',
                  style: TextStyle(color: _textSecondary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: _borderColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _textSecondary)),
          Text(value, style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 4: Confirmation
  // ==========================================
  Widget _buildConfirmation() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.success, size: 60),
          ),
          const SizedBox(height: 24),
          Text('Insurance Booked!', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 8),
          Text('Your application has been submitted', style: TextStyle(color: _textSecondary)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              children: [
                _buildConfirmRow('Company', _selectedCompany?.name ?? ''),
                _buildConfirmRow('Plan', '${_selectedType.displayName} - ${_selectedPlan.displayName}'),
                _buildConfirmRow('Premium', 'AED ${_quote?.premium.toStringAsFixed(0) ?? '0'}'),
                _buildConfirmRow('Status', 'Pending Approval'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'You will receive a confirmation email shortly.\nThe insurance company will contact you within 24 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: _textSecondary)),
          Text(value, style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ==========================================
  // Bottom Buttons
  // ==========================================
  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: _cardColor,
        border: Border(top: BorderSide(color: _borderColor)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0 && _currentStep < 3)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0 && _currentStep < 3) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _getButtonAction(),
              child: _isLoadingQuote || _isBooking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_getButtonText()),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Select Plan';
      case 1:
        return 'Get Quote';
      case 2:
        return 'Book Now - AED ${_quote?.premium.toStringAsFixed(0) ?? '0'}';
      case 3:
        return 'Done';
      default:
        return 'Continue';
    }
  }

  VoidCallback? _getButtonAction() {
    switch (_currentStep) {
      case 0:
        return _selectedCompany == null ? null : () => setState(() => _currentStep = 1);
      case 1:
        return _loadQuote;
      case 2:
        return _bookInsurance;
      case 3:
        return () => Navigator.of(context).pop(true);
      default:
        return null;
    }
  }

  Future<void> _loadQuote() async {
    if (_selectedCompany == null) return;

    setState(() => _isLoadingQuote = true);

    final result = await InsuranceService.getQuote(
      vehicle: widget.vehicle,
      company: _selectedCompany!,
      type: _selectedType,
      plan: _selectedPlan,
    );

    setState(() {
      _isLoadingQuote = false;
      if (result.isSuccess) {
        _quote = result.data;
        _currentStep = 2;
      }
    });
  }

  Future<void> _bookInsurance() async {
    if (_quote == null || _selectedCompany == null) return;

    setState(() => _isBooking = true);

    final result = await InsuranceService.create(
      vehicleId: widget.vehicle.id,
      companyId: _selectedCompany!.id,
      companyName: _selectedCompany!.name,
      type: _selectedType,
      plan: _selectedPlan,
      startDate: _startDate,
      premium: _quote!.premium,
      coverageAmount: _quote!.coverageAmount,
    );

    setState(() {
      _isBooking = false;
      if (result.isSuccess) {
        _currentStep = 3;
      }
    });
  }
}