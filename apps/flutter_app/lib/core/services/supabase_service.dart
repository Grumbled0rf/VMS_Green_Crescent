import 'package:supabase_flutter/supabase_flutter.dart';

// ============================================
// SUPABASE SERVICE
// Provides easy access to the Supabase client
// ============================================
class SupabaseService {
  SupabaseService._();

  // ==========================================
  // CLIENT ACCESS
  // ==========================================
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => Supabase.instance.client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Session? get currentSession => Supabase.instance.client.auth.currentSession;

  // ==========================================
  // AUTH SHORTCUTS
  // ==========================================
  static Stream<AuthState> get authStateChanges => 
      Supabase.instance.client.auth.onAuthStateChange;

  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}