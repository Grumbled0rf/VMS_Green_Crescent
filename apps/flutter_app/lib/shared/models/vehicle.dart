// ============================================
// VEHICLE MODEL
// Represents a vehicle in the VMS system
// ============================================
class Vehicle {
  final String? id;
  final String plateNumber;
  final String emirate;
  final String make;
  final String model;
  final int year;
  final String fuelType;
  final String? vin;
  final String? color;
  final DateTime? lastTestDate;
  final DateTime? nextTestDue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Vehicle({
    this.id,
    required this.plateNumber,
    required this.emirate,
    required this.make,
    required this.model,
    required this.year,
    required this.fuelType,
    this.vin,
    this.color,
    this.lastTestDate,
    this.nextTestDue,
    this.createdAt,
    this.updatedAt,
  });

  // ==========================================
  // COMPUTED PROPERTIES
  // ==========================================

  /// Full display name: "Toyota Land Cruiser"
  String get displayName => '$make $model';

  /// Full plate: "Dubai A 12345"
  String get fullPlate => '$emirate $plateNumber';

  /// Check if emission test is due (past due date)
  bool get isTestDue {
    if (nextTestDue == null) return false;
    return DateTime.now().isAfter(nextTestDue!);
  }

  /// Check if test is expiring within 30 days
  bool get isTestExpiringSoon {
    if (nextTestDue == null) return false;
    final daysUntilDue = nextTestDue!.difference(DateTime.now()).inDays;
    return daysUntilDue > 0 && daysUntilDue <= 30;
  }

  /// Days until next test due
  int? get daysUntilDue {
    if (nextTestDue == null) return null;
    return nextTestDue!.difference(DateTime.now()).inDays;
  }

  /// Get status string
  String get statusText {
    if (lastTestDate == null) return 'No Test';
    if (isTestDue) return 'Overdue';
    if (isTestExpiringSoon) return 'Expiring Soon';
    return 'Compliant';
  }

  // ==========================================
  // JSON SERIALIZATION
  // ==========================================

  /// Create Vehicle from JSON (Supabase response)
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString(),
      plateNumber: json['plate_number'] ?? '',
      emirate: json['emirate'] ?? '',
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      year: json['year'] ?? DateTime.now().year,
      fuelType: json['fuel_type'] ?? 'Petrol',
      vin: json['vin'],
      color: json['color'],
      lastTestDate: json['last_test_date'] != null
          ? DateTime.parse(json['last_test_date'])
          : null,
      nextTestDue: json['next_test_due'] != null
          ? DateTime.parse(json['next_test_due'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  /// Convert Vehicle to JSON (for Supabase insert/update)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'plate_number': plateNumber,
      'emirate': emirate,
      'make': make,
      'model': model,
      'year': year,
      'fuel_type': fuelType,
      if (vin != null) 'vin': vin,
      if (color != null) 'color': color,
      if (lastTestDate != null)
        'last_test_date': lastTestDate!.toIso8601String().split('T')[0],
      if (nextTestDue != null)
        'next_test_due': nextTestDue!.toIso8601String().split('T')[0],
    };
  }

  // ==========================================
  // COPY WITH
  // ==========================================

  Vehicle copyWith({
    String? id,
    String? plateNumber,
    String? emirate,
    String? make,
    String? model,
    int? year,
    String? fuelType,
    String? vin,
    String? color,
    DateTime? lastTestDate,
    DateTime? nextTestDue,
  }) {
    return Vehicle(
      id: id ?? this.id,
      plateNumber: plateNumber ?? this.plateNumber,
      emirate: emirate ?? this.emirate,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      fuelType: fuelType ?? this.fuelType,
      vin: vin ?? this.vin,
      color: color ?? this.color,
      lastTestDate: lastTestDate ?? this.lastTestDate,
      nextTestDue: nextTestDue ?? this.nextTestDue,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'Vehicle(id: $id, plate: $fullPlate, name: $displayName)';
  }
}