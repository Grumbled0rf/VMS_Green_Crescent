// lib/shared/models/insurance.dart
// ONLY the model classes - NOT the service

class Insurance {
  final String id;
  final String vehicleId;
  final String policyNumber;
  final String companyId;
  final String companyName;
  final InsuranceType type;
  final InsurancePlan plan;
  final DateTime startDate;
  final DateTime expiryDate;
  final double premium;
  final double coverageAmount;
  final InsuranceStatus status;
  final String? documentUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Insurance({
    required this.id,
    required this.vehicleId,
    required this.policyNumber,
    required this.companyId,
    required this.companyName,
    required this.type,
    required this.plan,
    required this.startDate,
    required this.expiryDate,
    required this.premium,
    required this.coverageAmount,
    required this.status,
    this.documentUrl,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isExpiringSoon => expiryDate.difference(DateTime.now()).inDays <= 30 && !isExpired;
  int get daysUntilExpiry => expiryDate.difference(DateTime.now()).inDays;
  bool get isActive => status == InsuranceStatus.active && !isExpired;

  factory Insurance.fromJson(Map<String, dynamic> json) {
    return Insurance(
      id: json['id'] as String,
      vehicleId: json['vehicle_id'] as String,
      policyNumber: json['policy_number'] as String,
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String,
      type: InsuranceType.values.firstWhere((e) => e.name == json['type'], orElse: () => InsuranceType.thirdParty),
      plan: InsurancePlan.values.firstWhere((e) => e.name == json['plan'], orElse: () => InsurancePlan.basic),
      startDate: DateTime.parse(json['start_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      premium: (json['premium'] as num).toDouble(),
      coverageAmount: (json['coverage_amount'] as num).toDouble(),
      status: InsuranceStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => InsuranceStatus.pending),
      documentUrl: json['document_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }
}

enum InsuranceType { thirdParty, comprehensive, thirdPartyFireTheft }

extension InsuranceTypeExt on InsuranceType {
  String get displayName {
    switch (this) {
      case InsuranceType.thirdParty: return 'Third Party';
      case InsuranceType.comprehensive: return 'Comprehensive';
      case InsuranceType.thirdPartyFireTheft: return 'Third Party + Fire & Theft';
    }
  }
}

enum InsurancePlan { basic, standard, premium, platinum }

extension InsurancePlanExt on InsurancePlan {
  String get displayName {
    switch (this) {
      case InsurancePlan.basic: return 'Basic';
      case InsurancePlan.standard: return 'Standard';
      case InsurancePlan.premium: return 'Premium';
      case InsurancePlan.platinum: return 'Platinum';
    }
  }
}

enum InsuranceStatus { pending, active, expired, cancelled }

class InsuranceCompany {
  final String id;
  final String name;
  final String logo;
  final double rating;
  final int reviewCount;
  final Map<String, double> basePrices;
  final bool isPartner;

  InsuranceCompany({
    required this.id,
    required this.name,
    required this.logo,
    required this.rating,
    required this.reviewCount,
    required this.basePrices,
    this.isPartner = false,
  });
}

class UAEInsuranceCompanies {
  static List<InsuranceCompany> getPartners() => [
    InsuranceCompany(id: 'oman', name: 'Oman Insurance', logo: '🏢', rating: 4.5, reviewCount: 2850, basePrices: {'basic': 850, 'standard': 1200, 'premium': 1800, 'platinum': 2500}, isPartner: true),
    InsuranceCompany(id: 'aman', name: 'Dubai Islamic (Aman)', logo: '🕌', rating: 4.3, reviewCount: 1920, basePrices: {'basic': 800, 'standard': 1150, 'premium': 1700, 'platinum': 2400}, isPartner: true),
    InsuranceCompany(id: 'axa', name: 'AXA Gulf', logo: '🔵', rating: 4.4, reviewCount: 3200, basePrices: {'basic': 900, 'standard': 1300, 'premium': 1900, 'platinum': 2700}, isPartner: true),
  ];

  static List<InsuranceCompany> getOtherCompanies() => [
    InsuranceCompany(id: 'sukoon', name: 'Sukoon Insurance', logo: '💚', rating: 4.2, reviewCount: 1450, basePrices: {'basic': 750, 'standard': 1100, 'premium': 1650}, isPartner: false),
  ];
}

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