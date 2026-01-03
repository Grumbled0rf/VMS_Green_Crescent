import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'login_screen.dart';

// ============================================
// REGISTER SCREEN
// Full registration with validation
// ============================================
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showSnackBar('Please agree to the Terms & Conditions', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      if (result.requiresVerification) {
        _showVerificationDialog();
      } else {
        _showSnackBar(result.message ?? 'Account created! 🎉', isError: false);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      _showSnackBar(result.message ?? 'Registration failed', isError: true);
    }
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.infoLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.email_outlined,
                color: AppColors.info,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text('Verify Your Email', style: AppTheme.headingSm),
            const SizedBox(height: 12),
            Text(
              'We\'ve sent a verification link to\n${_emailController.text}',
              style: AppTheme.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your inbox and click the link to verify your account.',
              style: AppTheme.bodySm,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text('Go to Login'),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. Acceptance of Terms', style: AppTheme.titleMd),
              const SizedBox(height: 8),
              const Text(
                'By using VMS Platform, you agree to these terms and conditions. '
                'This service is provided for vehicle management and emission test booking.',
              ),
              const SizedBox(height: 16),
              Text('2. User Responsibilities', style: AppTheme.titleMd),
              const SizedBox(height: 8),
              const Text(
                'Users must provide accurate vehicle information and maintain valid '
                'emission certificates as required by UAE law.',
              ),
              const SizedBox(height: 16),
              Text('3. Privacy', style: AppTheme.titleMd),
              const SizedBox(height: 8),
              const Text(
                'We collect and process personal data in accordance with UAE data '
                'protection regulations. Your information is kept secure.',
              ),
              const SizedBox(height: 16),
              Text('4. Booking Policy', style: AppTheme.titleMd),
              const SizedBox(height: 8),
              const Text(
                'Bookings can be cancelled up to 24 hours before the appointment. '
                'Payment is collected at the test center.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _agreeToTerms = true);
              Navigator.pop(context);
            },
            child: const Text('I Agree'),
          ),
        ],
      ),
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
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 32),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 24),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginLink(),
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
        Text(
          'Join VMS Platform',
          style: AppTheme.headingMd.copyWith(color: AppColors.dark),
        ),
        const SizedBox(height: 8),
        Text(
          'Create an account to manage your vehicles',
          style: AppTheme.bodyMd.copyWith(color: AppColors.gray),
          textAlign: TextAlign.center,
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
          // Full Name
          Text('Full Name', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: 'Enter your full name',
              prefixIcon: Icon(Icons.person_outlined),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name is too short';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Email
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

          // Phone
          Text('Phone Number (Optional)', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: const InputDecoration(
              hintText: '+971 50 123 4567',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 9) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Password
          Text('Password', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            enabled: !_isLoading,
            decoration: InputDecoration(
              hintText: 'Create a password',
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
              helperText: 'At least 6 characters with 1 number',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              if (!RegExp(r'[0-9]').hasMatch(value)) {
                return 'Password must contain at least 1 number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Confirm Password
          Text('Confirm Password', style: AppTheme.labelLg),
          const SizedBox(height: 8),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            enabled: !_isLoading,
            onFieldSubmitted: (_) => _handleRegister(),
            decoration: InputDecoration(
              hintText: 'Confirm your password',
              prefixIcon: const Icon(Icons.lock_outlined),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () {
                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: _isLoading
                ? null
                : (value) => setState(() => _agreeToTerms = value ?? false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: _showTermsDialog,
            child: RichText(
              text: TextSpan(
                style: AppTheme.bodyMd.copyWith(color: AppColors.dark),
                children: [
                  const TextSpan(text: 'I agree to the '),
                  TextSpan(
                    text: 'Terms & Conditions',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleRegister,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text('Create Account'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTheme.bodyMd),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}