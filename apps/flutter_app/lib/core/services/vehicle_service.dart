import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models/vehicle.dart';
import 'supabase_service.dart';

// ============================================
// VEHICLE SERVICE
// ============================================
class VehicleService {
  static SupabaseClient get _client => SupabaseService.client;
  static const String _table = 'vehicles';

  static Future<ServiceResult<Vehicle>> create(Vehicle vehicle) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final data = vehicle.toJson();
      data['user_id'] = userId;
      data.remove('id');
      data.remove('created_at');
      data.remove('updated_at');

      final response = await _client.from(_table).insert(data).select().single();
      return ServiceResult.success(data: Vehicle.fromJson(response), message: 'Vehicle added successfully');
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to add vehicle: ${e.toString()}');
    }
  }

  static Future<ServiceResult<List<Vehicle>>> getAll() async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final response = await _client.from(_table).select().eq('user_id', userId).order('created_at', ascending: false);
      final vehicles = (response as List).map((json) => Vehicle.fromJson(json)).toList();
      return ServiceResult.success(data: vehicles);
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to load vehicles: ${e.toString()}');
    }
  }

  static Future<ServiceResult<Vehicle>> getById(String id) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      final response = await _client.from(_table).select().eq('id', id).eq('user_id', userId).single();
      return ServiceResult.success(data: Vehicle.fromJson(response));
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to load vehicle: ${e.toString()}');
    }
  }

  static Future<ServiceResult<Vehicle>> update(Vehicle vehicle) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');
      if (vehicle.id == null) return ServiceResult.failure('Vehicle ID is required');

      final data = vehicle.toJson();
      data.remove('id');
      data.remove('created_at');
      data.remove('user_id');
      data['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client.from(_table).update(data).eq('id', vehicle.id!).eq('user_id', userId).select().single();
      return ServiceResult.success(data: Vehicle.fromJson(response), message: 'Vehicle updated successfully');
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to update vehicle: ${e.toString()}');
    }
  }

  static Future<ServiceResult<void>> delete(String id) async {
    try {
      final userId = SupabaseService.currentUser?.id;
      if (userId == null) return ServiceResult.failure('User not logged in');

      await _client.from(_table).delete().eq('id', id).eq('user_id', userId);
      return ServiceResult.success(message: 'Vehicle deleted successfully');
    } on PostgrestException catch (e) {
      return ServiceResult.failure(e.message);
    } catch (e) {
      return ServiceResult.failure('Failed to delete vehicle: ${e.toString()}');
    }
  }
}

class ServiceResult<T> {
  final bool isSuccess;
  final String? message;
  final T? data;

  ServiceResult._({required this.isSuccess, this.message, this.data});

  factory ServiceResult.success({T? data, String? message}) {
    return ServiceResult._(isSuccess: true, data: data, message: message);
  }

  factory ServiceResult.failure(String message) {
    return ServiceResult._(isSuccess: false, message: message);
  }
}