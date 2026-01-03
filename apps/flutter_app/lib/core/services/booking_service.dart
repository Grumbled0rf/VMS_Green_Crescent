import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/booking.dart';
import '../../shared/models/test_center.dart';
import 'supabase_service.dart';
import 'vehicle_service.dart' show ServiceResult;

class BookingService {
  static SupabaseClient get _client => SupabaseService.client;

  // ==========================================
  // CREATE BOOKING
  // ==========================================
  static Future<ServiceResult<Booking>> create({
    required String vehicleId,
    required String testCenterId,
    required DateTime bookingDate,
    required String timeSlot,
    required double price,
    String? notes,
  }) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final confirmationCode = _generateConfirmationCode();

      final data = {
        'user_id': userId,
        'vehicle_id': vehicleId,
        'test_center_id': testCenterId,
        'booking_date': bookingDate.toIso8601String().split('T')[0],
        'time_slot': timeSlot,
        'status': 'pending',
        'confirmation_code': confirmationCode,
        'price': price,
        'notes': notes,
      };

      final response = await _client.from('bookings').insert(data).select().single();
      return ServiceResult.success(data: Booking.fromJson(response), message: 'Booking created successfully');
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to create booking: ${e.toString()}');
    }
  }

  // ==========================================
  // GET ALL BOOKINGS
  // ==========================================
  static Future<ServiceResult<List<Booking>>> getAll() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final response = await _client
          .from('bookings')
          .select('*, vehicles(make, model, plate_number, emirate), test_centers(name, address, emirate)')
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      final bookings = (response as List).map((json) => Booking.fromJsonWithRelations(json)).toList();
      return ServiceResult.success(data: bookings);
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to load bookings: ${e.toString()}');
    }
  }

  // ==========================================
  // GET UPCOMING BOOKINGS
  // ==========================================
  static Future<ServiceResult<List<Booking>>> getUpcoming() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('bookings')
          .select('*, vehicles(make, model, plate_number, emirate), test_centers(name, address, emirate)')
          .eq('user_id', userId)
          .gte('booking_date', today)
          .neq('status', 'cancelled')
          .order('booking_date', ascending: true);

      final bookings = (response as List).map((json) => Booking.fromJsonWithRelations(json)).toList();
      return ServiceResult.success(data: bookings);
    } catch (e) {
      return ServiceResult.failure('Failed to load upcoming bookings: ${e.toString()}');
    }
  }

  // ==========================================
  // GET PAST BOOKINGS
  // ==========================================
  static Future<ServiceResult<List<Booking>>> getPast() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _client
          .from('bookings')
          .select('*, vehicles(make, model, plate_number, emirate), test_centers(name, address, emirate)')
          .eq('user_id', userId)
          .or('booking_date.lt.$today,status.eq.cancelled,status.eq.completed')
          .order('booking_date', ascending: false);

      final bookings = (response as List).map((json) => Booking.fromJsonWithRelations(json)).toList();
      return ServiceResult.success(data: bookings);
    } catch (e) {
      return ServiceResult.failure('Failed to load past bookings: ${e.toString()}');
    }
  }

  // ==========================================
  // UPDATE BOOKING STATUS
  // ==========================================
  static Future<ServiceResult<Booking>> updateStatus(String bookingId, String status) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final response = await _client
          .from('bookings')
          .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', bookingId)
          .eq('user_id', userId)
          .select()
          .single();

      return ServiceResult.success(data: Booking.fromJson(response), message: 'Booking updated successfully');
    } catch (e) {
      return ServiceResult.failure('Failed to update booking: ${e.toString()}');
    }
  }

  // ==========================================
  // CANCEL BOOKING
  // ==========================================
  static Future<ServiceResult<Booking>> cancel(String bookingId) async {
    return updateStatus(bookingId, 'cancelled');
  }

  // ==========================================
  // GET TEST CENTERS
  // ==========================================
  static Future<ServiceResult<List<TestCenter>>> getTestCenters() async {
    try {
      final response = await _client
          .from('test_centers')
          .select()
          .eq('is_active', true)
          .order('rating', ascending: false);

      final centers = (response as List).map((json) => TestCenter.fromJson(json)).toList();
      return ServiceResult.success(data: centers);
    } catch (e) {
      return ServiceResult.failure('Failed to load test centers: ${e.toString()}');
    }
  }

  // ==========================================
  // GET TEST CENTERS BY EMIRATE
  // ==========================================
  static Future<ServiceResult<List<TestCenter>>> getTestCentersByEmirate(String emirate) async {
    try {
      final response = await _client
          .from('test_centers')
          .select()
          .eq('is_active', true)
          .or('emirate.eq.$emirate,emirate.eq.All Emirates')
          .order('rating', ascending: false);

      final centers = (response as List).map((json) => TestCenter.fromJson(json)).toList();
      return ServiceResult.success(data: centers);
    } catch (e) {
      return ServiceResult.failure('Failed to load test centers: ${e.toString()}');
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================
  static String _generateConfirmationCode() {
    final year = DateTime.now().year;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
    return 'VMS-$year-$random';
  }
}