class Booking {
  final String? id;
  final String userId;
  final String vehicleId;
  final String testCenterId;
  final DateTime bookingDate;
  final String timeSlot;
  final String status;
  final String? confirmationCode;
  final double? price;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Joined data from relations
  final String? vehicleName;
  final String? vehiclePlate;
  final String? testCenterName;
  final String? testCenterAddress;
  final String? testCenterEmirate;

  Booking({
    this.id,
    required this.userId,
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
    this.testCenterEmirate,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      testCenterId: json['test_center_id'] ?? '',
      bookingDate: json['booking_date'] != null 
          ? DateTime.parse(json['booking_date']) 
          : DateTime.now(),
      timeSlot: json['time_slot'] ?? '',
      status: json['status'] ?? 'pending',
      confirmationCode: json['confirmation_code'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  factory Booking.fromJsonWithRelations(Map<String, dynamic> json) {
    final vehicle = json['vehicles'] as Map<String, dynamic>?;
    final testCenter = json['test_centers'] as Map<String, dynamic>?;

    String? vehicleName;
    String? vehiclePlate;
    if (vehicle != null) {
      vehicleName = '${vehicle['make'] ?? ''} ${vehicle['model'] ?? ''}'.trim();
      vehiclePlate = '${vehicle['emirate'] ?? ''} ${vehicle['plate_number'] ?? ''}'.trim();
    }

    return Booking(
      id: json['id'],
      userId: json['user_id'] ?? '',
      vehicleId: json['vehicle_id'] ?? '',
      testCenterId: json['test_center_id'] ?? '',
      bookingDate: json['booking_date'] != null 
          ? DateTime.parse(json['booking_date']) 
          : DateTime.now(),
      timeSlot: json['time_slot'] ?? '',
      status: json['status'] ?? 'pending',
      confirmationCode: json['confirmation_code'],
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      notes: json['notes'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate,
      testCenterName: testCenter?['name'],
      testCenterAddress: testCenter?['address'],
      testCenterEmirate: testCenter?['emirate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_id': vehicleId,
      'test_center_id': testCenterId,
      'booking_date': bookingDate.toIso8601String().split('T')[0],
      'time_slot': timeSlot,
      'status': status,
      'confirmation_code': confirmationCode,
      'price': price,
      'notes': notes,
    };
  }

  // Status helpers
  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isUpcoming {
    final now = DateTime.now();
    final bookingDateTime = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return bookingDateTime.isAfter(today) || bookingDateTime.isAtSameMomentAs(today);
  }

  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${bookingDate.day} ${months[bookingDate.month - 1]} ${bookingDate.year}';
  }

  String get displayStatus {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  Booking copyWith({
    String? id,
    String? userId,
    String? vehicleId,
    String? testCenterId,
    DateTime? bookingDate,
    String? timeSlot,
    String? status,
    String? confirmationCode,
    double? price,
    String? notes,
  }) {
    return Booking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
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
      vehicleName: vehicleName,
      vehiclePlate: vehiclePlate,
      testCenterName: testCenterName,
      testCenterAddress: testCenterAddress,
      testCenterEmirate: testCenterEmirate,
    );
  }
}