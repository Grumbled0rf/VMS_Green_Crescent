import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/responsive.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Theme helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get _primaryLight => _isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight;

  String _tr(String key) => AppStrings.get(key, context);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Login failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive layout
    if (Responsive.isDesktop(context)) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  // ==========================================
  // DESKTOP/TABLET LAYOUT - Split Screen
  // ==========================================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Row(
        children: [
          // Left Side - Branding
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _primaryColor,
                    _primaryColor.withBlue(180),
                    AppColors.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(Icons.directions_car, size: 60, color: _primaryColor),
                            Positioned(
                              right: 20,
                              bottom: 20,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: AppColors.success,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                ),
                                child: const Icon(Icons.check, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'VMS',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          'GREEN CRESCENT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Vehicle Management System',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Features
                      _buildFeatureItem(Icons.directions_car_outlined, 'Manage all your vehicles'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(Icons.calendar_today_outlined, 'Book emission tests'),
                      const SizedBox(height: 16),
                      _buildFeatureItem(Icons.notifications_outlined, 'Get timely reminders'),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Right Side - Login Form
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(48),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MOBILE LAYOUT
  // ==========================================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // LOGIN FORM (shared)
  // ==========================================
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo (mobile only)
          if (!Responsive.isDesktop(context)) ...[
            _buildLogo(),
            const SizedBox(height: 40),
          ],
          
          _buildWelcomeText(),
          const SizedBox(height: 32),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 8),
          _buildForgotPassword(),
          const SizedBox(height: 24),
          _buildLoginButton(),
          const SizedBox(height: 24),
          _buildRegisterLink(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: _primaryLight,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.directions_car, size: 56, color: _primaryColor),
            Positioned(
              right: 15,
              bottom: 15,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: _cardColor, width: 2),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: Responsive.isDesktop(context) 
          ? CrossAxisAlignment.start 
          : CrossAxisAlignment.center,
      children: [
        Text(
          _tr('welcome_back'),
          style: AppTheme.headingMd.copyWith(color: _textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          _tr('sign_in_continue'),
          style: AppTheme.bodyMd.copyWith(color: _textSecondary),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        labelText: _tr('email'),
        prefixIcon: Icon(Icons.email_outlined, color: _textSecondary),
        labelStyle: TextStyle(color: _textSecondary),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return _tr('required_field');
        if (!value.contains('@')) return _tr('invalid_email');
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        labelText: _tr('password'),
        prefixIcon: Icon(Icons.lock_outlined, color: _textSecondary),
        labelStyle: TextStyle(color: _textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: _textSecondary,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return _tr('required_field');
        if (value.length < 6) return _tr('password_min_length');
        return null;
      },
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
        ),
        child: Text(_tr('forgot_password')),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : Text(_tr('sign_in')),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_tr('dont_have_account'), style: TextStyle(color: _textSecondary)),
        TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          ),
          child: Text(_tr('sign_up')),
        ),
      ],
    );
  }
}