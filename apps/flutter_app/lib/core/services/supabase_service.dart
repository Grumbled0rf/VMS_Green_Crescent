import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

// ============================================
// SUPABASE SERVICE
// Handles Supabase initialization and provides
// easy access to the Supabase client
// ============================================
class SupabaseService {
  static SupabaseClient? _client;

  SupabaseService._();

  // ==========================================
  // INITIALIZATION
  // ==========================================

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // ==========================================
  // CLIENT ACCESS
  // ==========================================

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call SupabaseService.initialize() first.');
    }
    return _client!;
  }

  static User? get currentUser => client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Session? get currentSession => client.auth.currentSession;

  // ==========================================
  // AUTH SHORTCUTS
  // ==========================================

  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}