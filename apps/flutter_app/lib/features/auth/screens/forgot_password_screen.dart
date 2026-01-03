import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

// ============================================
// FORGOT PASSWORD SCREEN
// ============================================
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.resetPassword(_emailController.text);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _emailSent = true);
    } else {
      _showSnackBar(result.message ?? 'Failed to send reset email', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Reset Password'),
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
              child: _emailSent ? _buildSuccessView() : _buildFormView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 32),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset,
            size: 40,
            color: AppColors.primary,
          ),
        ),

        // Title
        Text(
          'Forgot Password?',
          style: AppTheme.headingMd.copyWith(color: AppColors.dark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we\'ll send you a link to reset your password.',
          style: AppTheme.bodyMd.copyWith(color: AppColors.gray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Form
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Email', style: AppTheme.labelLg),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                enabled: !_isLoading,
                onFieldSubmitted: (_) => _handleResetPassword(),
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
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Submit Button
        SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : const Text('Send Reset Link'),
          ),
        ),
        const SizedBox(height: 24),

        // Back to login
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read,
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // Title
        Text(
          'Check Your Email',
          style: AppTheme.headingMd.copyWith(color: AppColors.dark),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),

        // Message
        Text(
          'We\'ve sent a password reset link to:',
          style: AppTheme.bodyMd.copyWith(color: AppColors.gray),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text,
          style: AppTheme.titleMd.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),

        // Instructions
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.infoLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Next Steps:',
                    style: AppTheme.labelLg.copyWith(color: AppColors.info),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '1. Check your inbox (and spam folder)\n'
                '2. Click the reset link in the email\n'
                '3. Create a new password',
                style: AppTheme.bodySm.copyWith(color: AppColors.info),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Back to login button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back to Login'),
          ),
        ),
        const SizedBox(height: 16),

        // Resend option
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('Didn\'t receive email? Try again'),
        ),
      ],
    );
  }
}