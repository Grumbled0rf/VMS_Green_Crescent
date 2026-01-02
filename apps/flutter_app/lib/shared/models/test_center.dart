// ============================================
// TEST CENTER MODEL
// Represents an emission test center
// ============================================
class TestCenter {
  final String? id;
  final String name;
  final String address;
  final String emirate;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final double price;
  final double? rating;
  final List<String>? workingDays;
  final String? openTime;
  final String? closeTime;
  final bool isActive;

  TestCenter({
    this.id,
    required this.name,
    required this.address,
    required this.emirate,
    this.phone,
    this.latitude,
    this.longitude,
    this.price = 120.0,
    this.rating,
    this.workingDays,
    this.openTime,
    this.closeTime,
    this.isActive = true,
  });

  // ==========================================
  // COMPUTED PROPERTIES
  // ==========================================

  /// Full address with emirate
  String get fullAddress => '$address, $emirate';

  /// Formatted price
  String get formattedPrice => 'AED ${price.toStringAsFixed(0)}';

  /// Rating display
  String get ratingDisplay => rating?.toStringAsFixed(1) ?? '-';

  /// Working hours display
  String get workingHours {
    if (openTime == null || closeTime == null) return 'N/A';
    return '$openTime - $closeTime';
  }

  // ==========================================
  // JSON SERIALIZATION
  // ==========================================

  factory TestCenter.fromJson(Map<String, dynamic> json) {
    return TestCenter(
      id: json['id']?.toString(),
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      emirate: json['emirate'] ?? '',
      phone: json['phone'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      price: (json['price'] ?? 120.0).toDouble(),
      rating: json['rating']?.toDouble(),
      workingDays: json['working_days'] != null
          ? List<String>.from(json['working_days'])
          : null,
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'address': address,
      'emirate': emirate,
      if (phone != null) 'phone': phone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'price': price,
      if (rating != null) 'rating': rating,
      if (workingDays != null) 'working_days': workingDays,
      if (openTime != null) 'open_time': openTime,
      if (closeTime != null) 'close_time': closeTime,
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'TestCenter(id: $id, name: $name, emirate: $emirate)';
  }
}