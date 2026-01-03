import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  /// Get the Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current user
  static User? get currentUser => Supabase.instance.client.auth.currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => Supabase.instance.client.auth.currentUser != null;

  /// Get current session
  static Session? get currentSession => Supabase.instance.client.auth.currentSession;

  /// Auth state changes stream
  static Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

  /// Sign out
  static Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}