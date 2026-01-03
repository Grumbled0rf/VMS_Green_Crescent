import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

// ============================================
// LOGIN SCREEN
// Email/Password + Social Login (Google, Apple)
// ============================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================
  // ACTIONS
  // ==========================================
  
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      _showSnackBar(result.message ?? 'Welcome back! 🎉', isError: false);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      _showSnackBar(result.message ?? 'Login failed', isError: true);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _showSnackBar('Google login coming soon!', isError: false);
  }

  Future<void> _handleAppleLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    _showSnackBar('Apple login coming soon!', isError: false);
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _handleRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.isMobile(context) ? 24 : 40,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildLoginButton(),
                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialLogin(),
                  const SizedBox(height: 32),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome Back',
          style: AppTheme.headingMd.copyWith(color: AppColors.dark),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to manage your vehicles',
          style: AppTheme.bodyMd.copyWith(color: AppColors.gray),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'Enter your email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          Text('Password', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword 
                      ? Icons.visibility_outlined 
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _rememberMe = value ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('Remember me', style: AppTheme.bodyMd),
                ],
              ),
              TextButton(
                onPressed: _isLoading ? null : _handleForgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ],
          ),
        ],
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
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Sign In'),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or continue with',
            style: AppTheme.bodySm.copyWith(color: AppColors.gray),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: Icons.g_mobiledata_rounded,
            label: 'Google',
            onPressed: _isLoading ? null : _handleGoogleLogin,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SocialButton(
            icon: Icons.apple_rounded,
            label: 'Apple',
            onPressed: _isLoading ? null : _handleAppleLogin,
            isDark: true,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: AppTheme.bodyMd),
        TextButton(
          onPressed: _isLoading ? null : _handleRegister,
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isDark;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDark ? AppColors.dark : AppColors.white,
          foregroundColor: isDark ? AppColors.white : AppColors.dark,
          side: BorderSide(color: isDark ? AppColors.dark : AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}