import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

// ============================================
// SPLASH SCREEN
// Animated intro + Auth state check
// ============================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _loadingController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Logo animation controller (0 - 800ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Text animation controller (400ms - 1000ms)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Loading spinner controller
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo scale: 0.5 -> 1.0 with elastic bounce
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Logo opacity: 0 -> 1
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOut),
    );

    // Text opacity: 0 -> 1
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Text slide: from bottom
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );
  }

  void _startAnimations() async {
    // Start logo animation
    _logoController.forward();

    // Start text animation after 400ms
    await Future.delayed(const Duration(milliseconds: 400));
    _textController.forward();

    // Start loading spinner after 800ms
    await Future.delayed(const Duration(milliseconds: 400));
    _loadingController.repeat();

    // Navigate after 2.5 seconds total
    await Future.delayed(const Duration(milliseconds: 1300));
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    if (!mounted) return;

    // Check if user is already logged in
    final isLoggedIn = SupabaseService.isLoggedIn;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const DashboardScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Animated Logo
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Animated Text
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const Text(
                      'VMS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vehicle Management System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Loading Spinner
              AnimatedBuilder(
                animation: _loadingController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _loadingController.value > 0 ? 1.0 : 0.0,
                    child: RotationTransition(
                      turns: _loadingController,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: SweepGradient(
                        colors: [Colors.transparent, Colors.white],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Version
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _textOpacity.value,
                    child: child,
                  );
                },
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}