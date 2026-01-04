import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../main.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppearanceSection(isDark),
            const SizedBox(height: 24),
            _buildNotificationSection(isDark),
            const SizedBox(height: 24),
            _buildReminderSection(isDark),
            const SizedBox(height: 24),
            _buildAppSection(isDark),
            const SizedBox(height: 24),
            _buildAboutSection(isDark),
            const SizedBox(height: 24),
            _buildVersionInfo(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(bool isDark) {
    final appState = VMSApp.of(context);
    final currentTheme = appState?.themeMode ?? ThemeMode.system;

    return _buildSection(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      isDark: isDark,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: AppTheme.labelLg.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.dark,
              )),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildThemeOption(
                    icon: Icons.light_mode,
                    label: 'Light',
                    isSelected: currentTheme == ThemeMode.light,
                    onTap: () => appState?.setThemeMode(ThemeMode.light),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    icon: Icons.dark_mode,
                    label: 'Dark',
                    isSelected: currentTheme == ThemeMode.dark,
                    onTap: () => appState?.setThemeMode(ThemeMode.dark),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    icon: Icons.settings_suggest,
                    label: 'System',
                    isSelected: currentTheme == ThemeMode.system,
                    onTap: () => appState?.setThemeMode(ThemeMode.system),
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final bgColor = isDark ? AppColors.darkCard : AppColors.background;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : textColor.withOpacity(0.6),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? primaryColor : textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle, color: primaryColor, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection(bool isDark) {
    return _buildSection(
      title: 'Notifications',
      icon: Icons.notifications_outlined,
      isDark: isDark,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive push notifications',
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildSwitchTile(
          title: 'Email Notifications',
          subtitle: 'Receive booking confirmations via email',
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildSwitchTile(
          title: 'SMS Notifications',
          subtitle: 'Receive SMS reminders',
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildReminderSection(bool isDark) {
    return _buildSection(
      title: 'Test Reminders',
      icon: Icons.alarm,
      isDark: isDark,
      children: [
        _buildSwitchTile(
          title: 'Test Expiry Reminders',
          subtitle: 'Get notified before test expires',
          value: _reminderEnabled,
          onChanged: (value) => setState(() => _reminderEnabled = value),
          isDark: isDark,
        ),
        if (_reminderEnabled) ...[
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remind me before', style: AppTheme.bodyMd.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
                )),
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
                      selectedColor: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.2),
                      backgroundColor: isDark ? AppColors.darkCard : AppColors.background,
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                            : (isDark ? AppColors.darkTextPrimary : AppColors.dark),
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

  Widget _buildAppSection(bool isDark) {
    return _buildSection(
      title: 'App Preferences',
      icon: Icons.tune,
      isDark: isDark,
      children: [
        _buildTapTile(
          title: 'Language',
          subtitle: 'English',
          icon: Icons.language,
          onTap: () => _showLanguageDialog(),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildTapTile(
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          icon: Icons.cleaning_services_outlined,
          onTap: () => _showClearCacheDialog(),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return _buildSection(
      title: 'About',
      icon: Icons.info_outline,
      isDark: isDark,
      children: [
        _buildTapTile(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_outlined,
          onTap: () => _showSnackBar('Privacy Policy coming soon'),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildTapTile(
          title: 'Terms of Service',
          icon: Icons.description_outlined,
          onTap: () => _showSnackBar('Terms of Service coming soon'),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildTapTile(
          title: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () => _showSnackBar('Help & Support coming soon'),
          isDark: isDark,
        ),
        Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.divider),
        _buildTapTile(
          title: 'Rate the App',
          icon: Icons.star_outline,
          onTap: () => _showSnackBar('Rate the App coming soon'),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildVersionInfo(bool isDark) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.directions_car, 
              color: isDark ? AppColors.darkPrimary : AppColors.primary, 
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text('VMS Green Crescent', style: AppTheme.titleMd.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.dark,
          )),
          const SizedBox(height: 4),
          Text('Version 1.0.0', style: AppTheme.bodySm.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
          )),
          const SizedBox(height: 4),
          Text('© 2025 Green Crescent', style: AppTheme.bodySm.copyWith(
            color: isDark ? AppColors.darkTextHint : AppColors.lightGray,
          )),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: isDark ? AppColors.darkPrimary : AppColors.primary),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.titleLg.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.dark,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
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
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(title, style: AppTheme.bodyMd.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.dark,
      )),
      subtitle: Text(subtitle, style: AppTheme.bodySm.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
      )),
      value: value,
      onChanged: onChanged,
      activeColor: isDark ? AppColors.darkPrimary : AppColors.primary,
    );
  }

  Widget _buildTapTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDark ? AppColors.darkTextSecondary : AppColors.gray, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.dark,
      )),
      subtitle: subtitle != null ? Text(subtitle, style: AppTheme.bodySm.copyWith(
        color: isDark ? AppColors.darkTextSecondary : AppColors.gray,
      )) : null,
      trailing: Icon(Icons.chevron_right, color: isDark ? AppColors.darkTextHint : AppColors.lightGray),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', true, isDark),
            _buildLanguageOption('العربية (Arabic)', false, isDark),
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

  Widget _buildLanguageOption(String language, bool isSelected, bool isDark) {
    return ListTile(
      title: Text(language),
      trailing: isSelected 
          ? Icon(Icons.check, color: isDark ? AppColors.darkPrimary : AppColors.primary) 
          : null,
      onTap: () {
        Navigator.pop(context);
        _showSnackBar('Language changed to $language');
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