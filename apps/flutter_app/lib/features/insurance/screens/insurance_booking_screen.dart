// lib/features/insurance/screens/insurance_booking_screen.dart
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
  bool _isLoading = false;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _borderColor => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(title: Text('Book Insurance', style: TextStyle(color: _textPrimary)), backgroundColor: _cardColor),
      body: Column(
        children: [
          _buildStepper(),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: _buildContent())),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _cardColor,
      child: Row(
        children: ['Company', 'Plan', 'Quote', 'Done'].asMap().entries.map((e) {
          final isActive = e.key == _currentStep;
          final isDone = e.key < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(color: isDone ? AppColors.success : isActive ? _primaryColor : _borderColor, shape: BoxShape.circle),
                  child: Center(child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : Text('${e.key + 1}', style: TextStyle(color: isActive ? Colors.white : _textSecondary, fontWeight: FontWeight.bold, fontSize: 12))),
                ),
                if (e.key < 3) Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), color: isDone ? AppColors.success : _borderColor)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0: return _buildCompanyStep();
      case 1: return _buildPlanStep();
      case 2: return _buildQuoteStep();
      case 3: return _buildDoneStep();
      default: return const SizedBox();
    }
  }

  Widget _buildCompanyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVehicleInfo(),
        const SizedBox(height: 24),
        Text('Partner Companies', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...UAEInsuranceCompanies.getPartners().map((c) => _buildCompanyCard(c, true)),
        const SizedBox(height: 24),
        Text('Other Providers', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...UAEInsuranceCompanies.getOtherCompanies().map((c) => _buildCompanyCard(c, false)),
      ],
    );
  }

  Widget _buildVehicleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.directions_car, color: _primaryColor, size: 32),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.vehicle.displayName, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
            Text(widget.vehicle.fullPlate, style: TextStyle(color: _textSecondary)),
          ]),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(InsuranceCompany company, bool isPartner) {
    final isSelected = _selectedCompany?.id == company.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedCompany = company),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: isSelected ? 2 : 1)),
          child: Row(
            children: [
              Text(company.logo, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(company.name, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                    if (isPartner) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: const Text('Partner', style: TextStyle(color: AppColors.success, fontSize: 10)))],
                  ]),
                  Row(children: [const Icon(Icons.star, color: AppColors.warning, size: 16), Text(' ${company.rating}', style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)), Text(' (${company.reviewCount})', style: TextStyle(color: _textSecondary, fontSize: 12))]),
                  Text('From AED ${company.basePrices['basic']?.toInt()}/year', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                ]),
              ),
              Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: 2), color: isSelected ? _primaryColor : Colors.transparent), child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [Text(_selectedCompany?.logo ?? '', style: const TextStyle(fontSize: 24)), const SizedBox(width: 12), Text(_selectedCompany?.name ?? '', style: AppTheme.titleMd.copyWith(color: _textPrimary))])),
        const SizedBox(height: 24),
        Text('Insurance Type', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...InsuranceType.values.map((t) => _buildTypeCard(t)),
        const SizedBox(height: 24),
        Text('Select Plan', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        ...InsurancePlan.values.map((p) => _buildPlanCard(p)),
      ],
    );
  }

  Widget _buildTypeCard(InsuranceType type) {
    final isSelected = _selectedType == type;
    final desc = type == InsuranceType.thirdParty ? 'Basic third-party coverage' : type == InsuranceType.comprehensive ? 'Full coverage' : 'Third party + fire & theft';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? _primaryColor : _borderColor)),
          child: Row(children: [
            Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: 2), color: isSelected ? _primaryColor : Colors.transparent), child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 14) : null),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(type.displayName, style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)), Text(desc, style: TextStyle(color: _textSecondary, fontSize: 12))]),
          ]),
        ),
      ),
    );
  }

  Widget _buildPlanCard(InsurancePlan plan) {
    final isSelected = _selectedPlan == plan;
    final price = _selectedCompany?.basePrices[plan.name] ?? 1000;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedPlan = plan),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isSelected ? _primaryColor.withOpacity(0.1) : _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: isSelected ? 2 : 1)),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(plan.displayName, style: AppTheme.titleMd.copyWith(color: _textPrimary)), if (plan == InsurancePlan.premium) ...[const SizedBox(width: 8), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(4)), child: const Text('Popular', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))]]),
              Text('AED ${price.toInt()}/year', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold, fontSize: 18)),
            ])),
            Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: isSelected ? _primaryColor : _borderColor, width: 2), color: isSelected ? _primaryColor : Colors.transparent), child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 16) : null),
          ]),
        ),
      ),
    );
  }

  Widget _buildQuoteStep() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_quote == null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error, size: 64, color: _textSecondary), const SizedBox(height: 16), ElevatedButton(onPressed: _loadQuote, child: const Text('Retry'))]));
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [_primaryColor, _primaryColor.withBlue(180)]), borderRadius: BorderRadius.circular(20)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Text(_selectedCompany?.logo ?? '', style: const TextStyle(fontSize: 32)), const SizedBox(width: 12), Text(_quote!.companyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))]),
            const SizedBox(height: 20),
            Text('Annual Premium', style: TextStyle(color: Colors.white.withOpacity(0.8))),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('AED ', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18)), Text(_quote!.premium.toInt().toString(), style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)), Text('/year', style: TextStyle(color: Colors.white.withOpacity(0.8)))]),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: Text('Coverage: AED ${(_quote!.coverageAmount / 1000).toInt()}K', style: const TextStyle(color: Colors.white))),
          ]),
        ),
        const SizedBox(height: 24),
        Text('Coverage', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
          child: Column(children: _quote!.features.map((f) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 20), const SizedBox(width: 12), Expanded(child: Text(f, style: TextStyle(color: _textPrimary)))]))).toList()),
        ),
      ],
    );
  }

  Widget _buildDoneStep() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle, color: AppColors.success, size: 60)),
        const SizedBox(height: 24),
        Text('Insurance Booked!', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 8),
        Text('Application submitted', style: TextStyle(color: _textSecondary)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
          child: Column(children: [
            _buildRow('Company', _selectedCompany?.name ?? ''),
            _buildRow('Plan', '${_selectedType.displayName} - ${_selectedPlan.displayName}'),
            _buildRow('Premium', 'AED ${_quote?.premium.toInt() ?? 0}'),
            _buildRow('Status', 'Pending'),
          ]),
        ),
      ]),
    );
  }

  Widget _buildRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: _textSecondary)), Text(value, style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600))]));

  Widget _buildButtons() {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(color: _cardColor, border: Border(top: BorderSide(color: _borderColor))),
      child: Row(children: [
        if (_currentStep > 0 && _currentStep < 3) Expanded(child: OutlinedButton(onPressed: () => setState(() => _currentStep--), child: const Text('Back'))),
        if (_currentStep > 0 && _currentStep < 3) const SizedBox(width: 12),
        Expanded(flex: 2, child: ElevatedButton(onPressed: _getAction(), child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text(_getText()))),
      ]),
    );
  }

  String _getText() => ['Select Plan', 'Get Quote', 'Book - AED ${_quote?.premium.toInt() ?? 0}', 'Done'][_currentStep];

  VoidCallback? _getAction() {
    if (_currentStep == 0) return _selectedCompany == null ? null : () => setState(() => _currentStep = 1);
    if (_currentStep == 1) return _loadQuote;
    if (_currentStep == 2) return _book;
    return () => Navigator.pop(context, true);
  }

  Future<void> _loadQuote() async {
    if (_selectedCompany == null) return;
    setState(() => _isLoading = true);
    final result = await InsuranceService.getQuote(vehicle: widget.vehicle, company: _selectedCompany!, type: _selectedType, plan: _selectedPlan);
    setState(() { _isLoading = false; if (result.isSuccess) { _quote = result.data; _currentStep = 2; } });
  }

  Future<void> _book() async {
    if (_quote == null || _selectedCompany == null) return;
    setState(() => _isLoading = true);
    final result = await InsuranceService.create(vehicleId: widget.vehicle.id ?? '', companyId: _selectedCompany!.id, companyName: _selectedCompany!.name, type: _selectedType, plan: _selectedPlan, startDate: _startDate, premium: _quote!.premium, coverageAmount: _quote!.coverageAmount);
    setState(() { _isLoading = false; if (result.isSuccess) _currentStep = 3; });
  }
}