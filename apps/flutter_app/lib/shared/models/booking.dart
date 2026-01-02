// ============================================
// BOOKING MODEL
// Represents an emission test booking
// ============================================
class Booking {
  final String? id;
  final String? oderId;
  final String vehicleId;
  final String testCenterId;
  final DateTime bookingDate;
  final String timeSlot;
  final String status; // pending, confirmed, completed, cancelled
  final String? confirmationCode;
  final double? price;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Related objects (for display)
  final String? vehicleName;
  final String? vehiclePlate;
  final String? testCenterName;
  final String? testCenterAddress;

  Booking({
    this.id,
    this.oderId,
    required this.vehicleId,
    required this.testCenterId,
    required this.bookingDate,
    required this.timeSlot,
    this.status = 'pending',
    this.confirmationCode,
    this.price,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.vehicleName,
    this.vehiclePlate,
    this.testCenterName,
    this.testCenterAddress,
  });

  // ==========================================
  // COMPUTED PROPERTIES
  // ==========================================

  /// Formatted date
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[bookingDate.weekday - 1]}, ${bookingDate.day} ${months[bookingDate.month - 1]} ${bookingDate.year}';
  }

  /// Short date format
  String get shortDate {
    return '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
  }

  /// Formatted price
  String get formattedPrice => 'AED ${(price ?? 0).toStringAsFixed(0)}';

  /// Is booking upcoming
  bool get isUpcoming {
    final now = DateTime.now();
    final bookingDateTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
    );
    return bookingDateTime.isAfter(now) || 
           bookingDateTime.isAtSameMomentAs(DateTime(now.year, now.month, now.day));
  }

  /// Is booking today
  bool get isToday {
    final now = DateTime.now();
    return bookingDate.year == now.year &&
           bookingDate.month == now.month &&
           bookingDate.day == now.day;
  }

  /// Is pending
  bool get isPending => status == 'pending';

  /// Is confirmed
  bool get isConfirmed => status == 'confirmed';

  /// Is completed
  bool get isCompleted => status == 'completed';

  /// Is cancelled
  bool get isCancelled => status == 'cancelled';

  /// Can be cancelled
  bool get canCancel => (isPending || isConfirmed) && isUpcoming;

  // ==========================================
  // JSON SERIALIZATION
  // ==========================================

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id']?.toString(),
      oderId: json['user_id']?.toString(),
      vehicleId: json['vehicle_id']?.toString() ?? '',
      testCenterId: json['test_center_id']?.toString() ?? '',
      bookingDate: json['booking_date'] != null
          ? DateTime.parse(json['booking_date'])
          : DateTime.now(),
      timeSlot: json['time_slot'] ?? '',
      status: json['status'] ?? 'pending',
      confirmationCode: json['confirmation_code'],
      price: json['price']?.toDouble(),
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      // Related data
      vehicleName: json['vehicle_name'],
      vehiclePlate: json['vehicle_plate'],
      testCenterName: json['test_center_name'],
      testCenterAddress: json['test_center_address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'vehicle_id': vehicleId,
      'test_center_id': testCenterId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'status': status,
      if (confirmationCode != null) 'confirmation_code': confirmationCode,
      if (price != null) 'price': price,
      if (notes != null) 'notes': notes,
    };
  }

  Booking copyWith({
    String? id,
    String? oderId,
    String? vehicleId,
    String? testCenterId,
    DateTime? bookingDate,
    String? timeSlot,
    String? status,
    String? confirmationCode,
    double? price,
    String? notes,
    String? vehicleName,
    String? vehiclePlate,
    String? testCenterName,
    String? testCenterAddress,
  }) {
    return Booking(
      id: id ?? this.id,
      oderId: oderId ?? this.oderId,
      vehicleId: vehicleId ?? this.vehicleId,
      testCenterId: testCenterId ?? this.testCenterId,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      confirmationCode: confirmationCode ?? this.confirmationCode,
      price: price ?? this.price,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      vehicleName: vehicleName ?? this.vehicleName,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      testCenterName: testCenterName ?? this.testCenterName,
      testCenterAddress: testCenterAddress ?? this.testCenterAddress,
    );
  }

  @override
  String toString() {
    return 'Booking(id: $id, date: $formattedDate, time: $timeSlot, status: $status)';
  }
}