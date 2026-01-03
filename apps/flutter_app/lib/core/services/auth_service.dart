import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

// ============================================
// AUTH SERVICE
// Handles all authentication operations
// ============================================
class AuthService {
  static SupabaseClient get _client => SupabaseService.client;

  // ==========================================
  // SIGN UP
  // ==========================================

  static Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      debugPrint('AuthService: Attempting sign up for $email');
      
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'full_name': fullName.trim(),
          'phone': phone?.trim(),
        },
      );

      debugPrint('AuthService: Sign up response received');

      if (response.user == null) {
        return AuthResult.failure('Registration failed. Please try again.');
      }

      if (response.user!.emailConfirmedAt == null && response.session == null) {
        return AuthResult.success(
          user: response.user,
          message: 'Please check your email to verify your account.',
          requiresVerification: true,
        );
      }

      return AuthResult.success(
        user: response.user,
        session: response.session,
        message: 'Account created successfully!',
      );
    } on AuthException catch (e) {
      debugPrint('AuthService: AuthException - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      debugPrint('AuthService: Exception - $e');
      
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') || 
          errorString.contains('connection') ||
          errorString.contains('network')) {
        return AuthResult.failure(
          'Network error. Please check your internet connection.'
        );
      }
      
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // ==========================================
  // SIGN IN
  // ==========================================

  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('AuthService: Attempting sign in for $email');
      
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Login failed. Please try again.');
      }

      return AuthResult.success(
        user: response.user,
        session: response.session,
        message: 'Welcome back!',
      );
    } on AuthException catch (e) {
      debugPrint('AuthService: AuthException - ${e.message}');
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      debugPrint('AuthService: Exception - $e');
      
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('socket') || 
          errorString.contains('connection') ||
          errorString.contains('network')) {
        return AuthResult.failure(
          'Network error. Please check your internet connection.'
        );
      }
      
      return AuthResult.failure('An unexpected error occurred. Please try again.');
    }
  }

  // ==========================================
  // SIGN OUT
  // ==========================================

  static Future<AuthResult> signOut() async {
    try {
      await _client.auth.signOut();
      return AuthResult.success(message: 'Logged out successfully');
    } catch (e) {
      debugPrint('AuthService: Sign out error - $e');
      return AuthResult.failure('Failed to log out. Please try again.');
    }
  }

  // ==========================================
  // PASSWORD RESET
  // ==========================================

  static Future<AuthResult> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email.trim());
      return AuthResult.success(
        message: 'Password reset email sent. Please check your inbox.',
      );
    } on AuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to send reset email. Please try again.');
    }
  }

  static Future<AuthResult> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      return AuthResult.success(message: 'Password updated successfully');
    } on AuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to update password. Please try again.');
    }
  }

  // ==========================================
  // CURRENT USER
  // ==========================================

  static User? get currentUser => _client.auth.currentUser;

  static bool get isLoggedIn => currentUser != null;

  static Map<String, dynamic>? get userMetadata => currentUser?.userMetadata;

  static String? get userFullName => userMetadata?['full_name'];

  static String? get userPhone => userMetadata?['phone'];

  static String? get userEmail => currentUser?.email;

  static String get userInitials {
    final name = userFullName ?? userEmail ?? 'U';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ==========================================
  // UPDATE PROFILE
  // ==========================================

  static Future<AuthResult> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName.trim();
      if (phone != null) data['phone'] = phone.trim();

      await _client.auth.updateUser(UserAttributes(data: data));
      return AuthResult.success(message: 'Profile updated successfully');
    } on AuthException catch (e) {
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      return AuthResult.failure('Failed to update profile. Please try again.');
    }
  }

  // ==========================================
  // HELPERS
  // ==========================================

  static String _getAuthErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password. Please try again.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (message.contains('user already registered') ||
        message.contains('user already exists')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (message.contains('weak password') || 
        message.contains('password should be') ||
        message.contains('password is too short')) {
      return 'Password is too weak. Use at least 6 characters.';
    }
    if (message.contains('rate limit') || message.contains('too many requests')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (message.contains('signup is disabled')) {
      return 'Sign up is currently disabled. Please contact support.';
    }

    return e.message;
  }
}

// ============================================
// AUTH RESULT MODEL
// ============================================
class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;
  final Session? session;
  final bool requiresVerification;

  AuthResult._({
    required this.isSuccess,
    this.message,
    this.user,
    this.session,
    this.requiresVerification = false,
  });

  factory AuthResult.success({
    String? message,
    User? user,
    Session? session,
    bool requiresVerification = false,
  }) {
    return AuthResult._(
      isSuccess: true,
      message: message,
      user: user,
      session: session,
      requiresVerification: requiresVerification,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}