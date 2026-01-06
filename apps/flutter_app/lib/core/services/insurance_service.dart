import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../shared/models/insurance.dart';
import '../../../shared/models/vehicle.dart';

/// Result wrapper for insurance operations
class InsuranceResult<T> {
  final bool isSuccess;
  final T? data;
  final String? message;

  InsuranceResult.success(this.data)
      : isSuccess = true,
        message = null;

  InsuranceResult.failure(this.message)
      : isSuccess = false,
        data = null;
}

/// Insurance Service for managing vehicle insurance
class InsuranceService {
  static final _supabase = Supabase.instance.client;

  /// Get all insurance policies for current user
  static Future<InsuranceResult<List<Insurance>>> getAll() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return InsuranceResult.failure('User not authenticated');
      }

      final response = await _supabase
          .from('insurance_policies')
          .select()
          .eq('user_id', userId)
          .order('expiry_date', ascending: true);

      final policies = (response as List)
          .map((json) => Insurance.fromJson(json))
          .toList();

      return InsuranceResult.success(policies);
    } catch (e) {
      debugPrint('Error fetching insurance: $e');
      // Return mock data for demo
      return InsuranceResult.success(_getMockInsurance());
    }
  }

  /// Get insurance for a specific vehicle
  static Future<InsuranceResult<Insurance?>> getByVehicleId(String vehicleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return InsuranceResult.failure('User not authenticated');
      }

      final response = await _supabase
          .from('insurance_policies')
          .select()
          .eq('user_id', userId)
          .eq('vehicle_id', vehicleId)
          .eq('status', 'active')
          .order('expiry_date', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        return InsuranceResult.success(null);
      }

      return InsuranceResult.success(Insurance.fromJson(response));
    } catch (e) {
      debugPrint('Error fetching vehicle insurance: $e');
      return InsuranceResult.success(null);
    }
  }

  /// Create new insurance policy
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
      if (userId == null) {
        return InsuranceResult.failure('User not authenticated');
      }

      final policyNumber = _generatePolicyNumber();
      final expiryDate = startDate.add(const Duration(days: 365));

      final data = {
        'user_id': userId,
        'vehicle_id': vehicleId,
        'policy_number': policyNumber,
        'company_id': companyId,
        'company_name': companyName,
        'type': type.name,
        'plan': plan.name,
        'start_date': startDate.toIso8601String(),
        'expiry_date': expiryDate.toIso8601String(),
        'premium': premium,
        'coverage_amount': coverageAmount,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('insurance_policies')
          .insert(data)
          .select()
          .single();

      return InsuranceResult.success(Insurance.fromJson(response));
    } catch (e) {
      debugPrint('Error creating insurance: $e');
      // Return mock success for demo
      return InsuranceResult.success(_createMockInsurance(
        vehicleId: vehicleId,
        companyId: companyId,
        companyName: companyName,
        type: type,
        plan: plan,
        startDate: startDate,
        premium: premium,
        coverageAmount: coverageAmount,
      ));
    }
  }

  /// Update insurance status
  static Future<InsuranceResult<Insurance>> updateStatus(
    String insuranceId,
    InsuranceStatus status,
  ) async {
    try {
      final response = await _supabase
          .from('insurance_policies')
          .update({
            'status': status.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', insuranceId)
          .select()
          .single();

      return InsuranceResult.success(Insurance.fromJson(response));
    } catch (e) {
      debugPrint('Error updating insurance: $e');
      return InsuranceResult.failure('Failed to update insurance');
    }
  }

  /// Cancel insurance policy
  static Future<InsuranceResult<bool>> cancel(String insuranceId) async {
    try {
      await _supabase
          .from('insurance_policies')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', insuranceId);

      return InsuranceResult.success(true);
    } catch (e) {
      debugPrint('Error cancelling insurance: $e');
      return InsuranceResult.failure('Failed to cancel insurance');
    }
  }

  /// Get insurance quote
  static Future<InsuranceResult<InsuranceQuote>> getQuote({
    required Vehicle vehicle,
    required InsuranceCompany company,
    required InsuranceType type,
    required InsurancePlan plan,
  }) async {
    try {
      // Calculate base price
      double basePrice = company.basePrices[plan.name] ?? 1000;

      // Adjust based on vehicle age
      final vehicleAge = DateTime.now().year - (vehicle.year ?? DateTime.now().year);
      if (vehicleAge > 5) {
        basePrice *= 1.1; // 10% increase for older vehicles
      }
      if (vehicleAge > 10) {
        basePrice *= 1.2; // Additional 20% for very old vehicles
      }

      // Adjust based on insurance type
      switch (type) {
        case InsuranceType.comprehensive:
          basePrice *= 1.8;
          break;
        case InsuranceType.thirdPartyFireTheft:
          basePrice *= 1.4;
          break;
        case InsuranceType.thirdParty:
          break;
      }

      // Calculate coverage
      double coverage = 0;
      switch (type) {
        case InsuranceType.thirdParty:
          coverage = 250000;
          break;
        case InsuranceType.thirdPartyFireTheft:
          coverage = 500000;
          break;
        case InsuranceType.comprehensive:
          coverage = 1000000;
          break;
      }

      return InsuranceResult.success(InsuranceQuote(
        companyId: company.id,
        companyName: company.name,
        type: type,
        plan: plan,
        premium: basePrice.roundToDouble(),
        coverageAmount: coverage,
        validUntil: DateTime.now().add(const Duration(days: 7)),
        features: _getPlanFeatures(plan, type),
      ));
    } catch (e) {
      debugPrint('Error getting quote: $e');
      return InsuranceResult.failure('Failed to get quote');
    }
  }

  /// Get features for a plan
  static List<String> _getPlanFeatures(InsurancePlan plan, InsuranceType type) {
    List<String> features = [];

    // Base features
    features.add('24/7 Roadside Assistance');
    features.add('Free Towing Service');

    switch (type) {
      case InsuranceType.thirdParty:
        features.add('Third Party Liability Coverage');
        features.add('Legal Expenses Cover');
        break;
      case InsuranceType.thirdPartyFireTheft:
        features.addAll([
          'Third Party Liability Coverage',
          'Fire Damage Protection',
          'Theft Protection',
          'Legal Expenses Cover',
        ]);
        break;
      case InsuranceType.comprehensive:
        features.addAll([
          'Third Party Liability Coverage',
          'Own Damage Cover',
          'Fire & Theft Protection',
          'Natural Disaster Cover',
          'Personal Accident Cover',
          'Legal Expenses Cover',
        ]);
        break;
    }

    // Plan specific features
    switch (plan) {
      case InsurancePlan.standard:
        features.add('Agency Repair Option');
        break;
      case InsurancePlan.premium:
        features.addAll([
          'Agency Repair Guaranteed',
          'Replacement Car (7 days)',
          'No Depreciation on Parts',
        ]);
        break;
      case InsurancePlan.platinum:
        features.addAll([
          'Agency Repair Guaranteed',
          'Replacement Car (14 days)',
          'No Depreciation on Parts',
          'Zero Deductible',
          'VIP Claims Processing',
          'Personal Belongings Cover',
        ]);
        break;
      default:
        break;
    }

    return features;
  }

  /// Generate policy number
  static String _generatePolicyNumber() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'VMS-INS-$timestamp';
  }

  /// Get mock insurance for demo
  static List<Insurance> _getMockInsurance() {
    return [
      Insurance(
        id: 'mock-1',
        vehicleId: 'vehicle-1',
        policyNumber: 'VMS-INS-2024001',
        companyId: 'oman_insurance',
        companyName: 'Oman Insurance Company',
        type: InsuranceType.comprehensive,
        plan: InsurancePlan.premium,
        startDate: DateTime.now().subtract(const Duration(days: 200)),
        expiryDate: DateTime.now().add(const Duration(days: 165)),
        premium: 1800,
        coverageAmount: 1000000,
        status: InsuranceStatus.active,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
    ];
  }

  /// Create mock insurance for demo
  static Insurance _createMockInsurance({
    required String vehicleId,
    required String companyId,
    required String companyName,
    required InsuranceType type,
    required InsurancePlan plan,
    required DateTime startDate,
    required double premium,
    required double coverageAmount,
  }) {
    return Insurance(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      vehicleId: vehicleId,
      policyNumber: _generatePolicyNumber(),
      companyId: companyId,
      companyName: companyName,
      type: type,
      plan: plan,
      startDate: startDate,
      expiryDate: startDate.add(const Duration(days: 365)),
      premium: premium,
      coverageAmount: coverageAmount,
      status: InsuranceStatus.pending,
      createdAt: DateTime.now(),
    );
  }
}

/// Insurance quote model
class InsuranceQuote {
  final String companyId;
  final String companyName;
  final InsuranceType type;
  final InsurancePlan plan;
  final double premium;
  final double coverageAmount;
  final DateTime validUntil;
  final List<String> features;

  InsuranceQuote({
    required this.companyId,
    required this.companyName,
    required this.type,
    required this.plan,
    required this.premium,
    required this.coverageAmount,
    required this.validUntil,
    required this.features,
  });
}