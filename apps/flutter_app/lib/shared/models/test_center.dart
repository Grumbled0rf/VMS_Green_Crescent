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
  final String? openTime;
  final String? closeTime;
  final bool isActive;
  final DateTime? createdAt;

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
    this.openTime,
    this.closeTime,
    this.isActive = true,
    this.createdAt,
  });

  factory TestCenter.fromJson(Map<String, dynamic> json) {
    return TestCenter(
      id: json['id'],
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      emirate: json['emirate'] ?? '',
      phone: json['phone'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 120.0 : 120.0,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      openTime: json['open_time'],
      closeTime: json['close_time'],
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'emirate': emirate,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'price': price,
      'rating': rating,
      'open_time': openTime,
      'close_time': closeTime,
      'is_active': isActive,
    };
  }

  String get formattedPrice => 'AED ${price.toStringAsFixed(0)}';

  String get formattedRating => rating != null ? rating!.toStringAsFixed(1) : 'N/A';

  String get operatingHours {
    if (openTime != null && closeTime != null) {
      return '$openTime - $closeTime';
    }
    return '08:00 - 18:00';
  }

  bool get isGreenCrescent => name.toLowerCase().contains('green crescent');
}