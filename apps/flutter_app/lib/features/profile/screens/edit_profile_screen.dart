import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: AuthService.userFullName ?? '');
    _phoneController = TextEditingController(text: AuthService.userPhone ?? '');
    
    _nameController.addListener(_checkChanges);
    _phoneController.addListener(_checkChanges);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _checkChanges() {
    final hasChanges = _nameController.text != (AuthService.userFullName ?? '') ||
        _phoneController.text != (AuthService.userPhone ?? '');
    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.updateProfile(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully! ✓')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message ?? 'Failed to update profile')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Editing')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 32),
                _buildFormSection(),
                const SizedBox(height: 32),
                _buildEmailSection(),
                const SizedBox(height: 32),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final initials = AuthService.userInitials;
    
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 3),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Photo upload coming soon!')),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Change Photo', style: AppTheme.bodyMd.copyWith(color: AppColors.primary)),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Personal Information', style: AppTheme.titleLg),
          const SizedBox(height: 20),
          
          // Full Name
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Phone
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: Icon(Icons.phone_outlined),
              hintText: '+971 XX XXX XXXX',
            ),
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 9) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Account Information', style: AppTheme.titleLg),
          const SizedBox(height: 20),
          
          // Email (read-only)
          TextFormField(
            initialValue: AuthService.userEmail ?? '',
            readOnly: true,
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.lightGray),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Email cannot be changed',
            style: AppTheme.bodySm.copyWith(color: AppColors.gray),
          ),
          
          const SizedBox(height: 20),
          
          // Change Password Button
          OutlinedButton.icon(
            onPressed: () => _showChangePasswordDialog(),
            icon: const Icon(Icons.lock_outline),
            label: const Text('Change Password'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading || !_hasChanges ? null : _saveProfile,
        child: _isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : const Text('Save Changes'),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(obscureCurrent ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureCurrent = !obscureCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (newPasswordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a new password')),
                        );
                        return;
                      }
                      if (newPasswordController.text.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password must be at least 6 characters')),
                        );
                        return;
                      }
                      if (newPasswordController.text != confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Passwords do not match')),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);

                      final result = await AuthService.updatePassword(newPasswordController.text);

                      setDialogState(() => isLoading = false);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.isSuccess ? 'Password updated successfully! ✓' : result.message ?? 'Failed to update password')),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}