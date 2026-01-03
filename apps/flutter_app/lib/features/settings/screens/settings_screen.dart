import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _reminderEnabled = true;
  int _reminderDays = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildReminderSection(),
            const SizedBox(height: 24),
            _buildAppSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive push notifications',
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
        ),
        const Divider(height: 1),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive booking confirmations via email',
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        const Divider(height: 1),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive SMS reminders',
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return _buildSection(
      title: 'Test Reminders',
      icon: Icons.alarm,
      children: [
        _buildSwitchTile(
          title: 'Test Expiry Reminders',
          subtitle: 'Get notified before test expires',
          value: _reminderEnabled,
          onChanged: (value) => setState(() => _reminderEnabled = value),
        ),
        if (_reminderEnabled) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remind me before', style: AppTheme.bodyMd),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [3, 7, 14, 30].map((days) {
                    final isSelected = _reminderDays == days;
                    return ChoiceChip(
                      label: Text('$days days'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _reminderDays = days);
                      },
                      selectedColor: AppColors.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.dark,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppSection() {
    return _buildSection(
      title: 'App Preferences',
      icon: Icons.tune,
      children: [
        _buildTapTile(
          title: 'Language',
          subtitle: 'English',
          icon: Icons.language,
          onTap: () => _showLanguageDialog(),
        ),
        const Divider(height: 1),
        _buildTapTile(
          title: 'Theme',
          subtitle: 'Light',
          icon: Icons.palette_outlined,
          onTap: () => _showThemeDialog(),
        ),
        const Divider(height: 1),
        _buildTapTile(
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          icon: Icons.cleaning_services_outlined,
          onTap: () => _showClearCacheDialog(),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return _buildSection(
      title: 'About',
      icon: Icons.info_outline,
      children: [
        _buildTapTile(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          onTap: () => _showSnackBar('Privacy Policy coming soon'),
        ),
        const Divider(height: 1),
        _buildTapTile(
          title: 'Terms of Service',
          icon: Icons.description_outlined,
          onTap: () => _showSnackBar('Terms of Service coming soon'),
        ),
        const Divider(height: 1),
        _buildTapTile(
          title: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () => _showSnackBar('Help & Support coming soon'),
        ),
        const Divider(height: 1),
        _buildTapTile(
          title: 'Rate the App',
          icon: Icons.star_outline,
          onTap: () => _showSnackBar('Rate the App coming soon'),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 12),
          Text('VMS Green Crescent', style: AppTheme.titleMd),
          const SizedBox(height: 4),
          Text('Version 1.0.0', style: AppTheme.bodySm),
          const SizedBox(height: 4),
          Text('© 2025 Green Crescent', style: AppTheme.bodySm.copyWith(color: AppColors.lightGray)),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.titleLg),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: AppColors.dark)),
      subtitle: Text(subtitle, style: AppTheme.bodySm),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildTapTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.gray, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: AppColors.dark)),
      subtitle: subtitle != null ? Text(subtitle, style: AppTheme.bodySm) : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGray),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', true),
            _buildLanguageOption('العربية (Arabic)', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String language, bool isSelected) {
    return ListTile(
      title: Text(language),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('Language changed to $language');
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption('Light', Icons.light_mode, true),
            _buildThemeOption('Dark', Icons.dark_mode, false),
            _buildThemeOption('System', Icons.settings_suggest, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String theme, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.gray),
      title: Text(theme),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('Theme changed to $theme');
      },
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will clear temporary files and free up storage space. Your data will not be affected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully!');
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}