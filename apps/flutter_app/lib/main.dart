import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase directly
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
  
  debugPrint('✅ Supabase initialized successfully');

  runApp(const VMSApp());
}

class VMSApp extends StatefulWidget {
  const VMSApp({super.key});

  // Static method to access state for theme changes
  static _VMSAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_VMSAppState>();

  @override
  State<VMSApp> createState() => _VMSAppState();
}

class _VMSAppState extends State<VMSApp> {
  final ThemeProvider _themeProvider = ThemeProvider();

  @override
  void initState() {
    super.initState();
    _themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
    _updateSystemUI();
  }

  void _updateSystemUI() {
    final isDark = _themeProvider.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  // Public method to change theme
  void setThemeMode(ThemeMode mode) {
    _themeProvider.setThemeMode(mode);
  }

  ThemeMode get themeMode => _themeProvider.themeMode;
  bool get isDarkMode => _themeProvider.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VMS Green Crescent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}