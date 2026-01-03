import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/screens/splash_screen.dart';

// ============================================
// MAIN ENTRY POINT
// ============================================
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase
  await SupabaseService.initialize();

  // Run the app
  runApp(const VMSApp());
}

// ============================================
// VMS APP
// ============================================
class VMSApp extends StatelessWidget {
  const VMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMS Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}