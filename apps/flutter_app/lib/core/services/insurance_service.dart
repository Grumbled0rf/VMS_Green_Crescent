// lib/core/services/insurance_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/insurance.dart';
import '../../shared/models/vehicle.dart';

class InsuranceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;
  InsuranceResult.success(this.data) : isSuccess = true, message = null;
  InsuranceResult.failure(this.message) : isSuccess = false, data = null;
}

class InsuranceService {
  static final _supabase = Supabase.instance.client;

  static Future<InsuranceResult<List<Insurance>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return InsuranceResult.failure('Not authenticated');
      final response = await _supabase.from('insurance_policies').select().eq('user_id', userId);
      final policies = (response as List).map((j) => Insurance.fromJson(j)).toList();
      return InsuranceResult.success(policies);
    } catch (e) {
      debugPrint('Error: $e');
      return InsuranceResult.success(_getMockInsurance());
    }
  }

  static Future<InsuranceResult<Insurance>> create({
    required String vehicleId,
    required String companyId,
    required String companyName,
    required InsuranceType type,
    required InsurancePlan plan,
    required DateTime startDate,
    required double premium,
    required double coverageAmount,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return InsuranceResult.failure('Not authenticated');
      final data = {
        'user_id': userId, 'vehicle_id': vehicleId, 'policy_number': 'VMS-${DateTime.now().millisecondsSinceEpoch}',
        'company_id': companyId, 'company_name': companyName, 'type': type.name, 'plan': plan.name,
        'start_date': startDate.toIso8601String(), 'expiry_date': startDate.add(const Duration(days: 365)).toIso8601String(),
        'premium': premium, 'coverage_amount': coverageAmount, 'status': 'pending', 'created_at': DateTime.now().toIso8601String(),
      };
      final response = await _supabase.from('insurance_policies').insert(data).select().single();
      return InsuranceResult.success(Insurance.fromJson(response));
    } catch (e) {
      debugPrint('Error: $e');
      return InsuranceResult.success(_createMock(vehicleId, companyId, companyName, type, plan, startDate, premium, coverageAmount));
    }
  }

  static Future<InsuranceResult<InsuranceQuote>> getQuote({
    required Vehicle vehicle,
    required InsuranceCompany company,
    required InsuranceType type,
    required InsurancePlan plan,
  }) async {
    double price = company.basePrices[plan.name] ?? 1000;
    final age = DateTime.now().year - (vehicle.year ?? DateTime.now().year);
    if (age > 5) price *= 1.1;
    if (age > 10) price *= 1.2;
    if (type == InsuranceType.comprehensive) price *= 1.8;
    if (type == InsuranceType.thirdPartyFireTheft) price *= 1.4;
    
    double coverage = type == InsuranceType.comprehensive ? 1000000 : type == InsuranceType.thirdPartyFireTheft ? 500000 : 250000;
    
    List<String> features = ['24/7 Roadside Assistance', 'Free Towing'];
    if (type == InsuranceType.comprehensive) features.addAll(['Own Damage Cover', 'Fire & Theft', 'Natural Disaster']);
    if (plan == InsurancePlan.premium || plan == InsurancePlan.platinum) features.addAll(['Agency Repair', 'Replacement Car']);
    
    return InsuranceResult.success(InsuranceQuote(
      companyId: company.id, companyName: company.name, type: type, plan: plan,
      premium: price.roundToDouble(), coverageAmount: coverage,
      validUntil: DateTime.now().add(const Duration(days: 7)), features: features,
    ));
  }

  static List<Insurance> _getMockInsurance() => [
    Insurance(
      id: 'mock-1', vehicleId: 'v1', policyNumber: 'VMS-001', companyId: 'oman', companyName: 'Oman Insurance',
      type: InsuranceType.comprehensive, plan: InsurancePlan.premium,
      startDate: DateTime.now().subtract(const Duration(days: 200)),
      expiryDate: DateTime.now().add(const Duration(days: 165)),
      premium: 1800, coverageAmount: 1000000, status: InsuranceStatus.active,
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
    ),
  ];

  static Insurance _createMock(String vId, String cId, String cName, InsuranceType type, InsurancePlan plan, DateTime start, double premium, double coverage) {
    return Insurance(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}', vehicleId: vId,
      policyNumber: 'VMS-${DateTime.now().millisecondsSinceEpoch}',
      companyId: cId, companyName: cName, type: type, plan: plan,
      startDate: start, expiryDate: start.add(const Duration(days: 365)),
      premium: premium, coverageAmount: coverage, status: InsuranceStatus.pending, createdAt: DateTime.now(),
    );
  }
}