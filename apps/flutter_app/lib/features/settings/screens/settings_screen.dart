import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/localization_service.dart';
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

  // Theme helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _borderColor => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;

  // Localization helper
  String _tr(String key) => AppStrings.get(key, context);
  bool get _isArabic => VMSApp.of(context)?.isArabic ?? false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_tr('settings'))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppearanceSection(),
            const SizedBox(height: 24),
            _buildLanguageSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildReminderSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildVersionInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    final appState = VMSApp.of(context);
    final currentTheme = appState?.themeMode ?? ThemeMode.system;

    return _buildSection(
      title: _tr('appearance'),
      icon: Icons.palette_outlined,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_tr('theme'), style: AppTheme.labelLg.copyWith(color: _textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildThemeOption(
                    icon: Icons.light_mode,
                    label: _tr('light'),
                    isSelected: currentTheme == ThemeMode.light,
                    onTap: () => appState?.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    icon: Icons.dark_mode,
                    label: _tr('dark'),
                    isSelected: currentTheme == ThemeMode.dark,
                    onTap: () => appState?.setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(width: 12),
                  _buildThemeOption(
                    icon: Icons.settings_suggest,
                    label: _tr('system'),
                    isSelected: currentTheme == ThemeMode.system,
                    onTap: () => appState?.setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    final appState = VMSApp.of(context);
    final isArabic = appState?.isArabic ?? false;

    return _buildSection(
      title: _tr('language'),
      icon: Icons.language,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_tr('language'), style: AppTheme.labelLg.copyWith(color: _textPrimary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildLanguageOption(
                    flag: '🇺🇸',
                    label: 'English',
                    isSelected: !isArabic,
                    onTap: () => appState?.setEnglish(),
                  ),
                  const SizedBox(width: 12),
                  _buildLanguageOption(
                    flag: '🇦🇪',
                    label: 'العربية',
                    isSelected: isArabic,
                    onTap: () => appState?.setArabic(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: _primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isArabic 
                            ? 'سيتم تطبيق اللغة العربية مع دعم RTL'
                            : 'Arabic language includes RTL support',
                        style: AppTheme.bodySm.copyWith(color: _primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageOption({
    required String flag,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.1) : _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _primaryColor : _textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle, color: _primaryColor, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor.withOpacity(0.1) : _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? _primaryColor : _textPrimary.withOpacity(0.6), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _primaryColor : _textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(height: 4),
                Icon(Icons.check_circle, color: _primaryColor, size: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSection(
      title: _tr('notifications'),
      icon: Icons.notifications_outlined,
      children: [
        _buildSwitchTile(
          title: _tr('push_notifications'),
          subtitle: _isArabic ? 'استلام إشعارات الدفع' : 'Receive push notifications',
          value: _notificationsEnabled,
          onChanged: (value) => setState(() => _notificationsEnabled = value),
        ),
        Divider(height: 1, color: _borderColor),
        _buildSwitchTile(
          title: _tr('email_notifications'),
          subtitle: _isArabic ? 'استلام تأكيدات الحجز بالبريد' : 'Receive booking confirmations via email',
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        Divider(height: 1, color: _borderColor),
        _buildSwitchTile(
          title: _tr('sms_notifications'),
          subtitle: _isArabic ? 'استلام تذكيرات برسائل SMS' : 'Receive SMS reminders',
          value: _smsNotifications,
          onChanged: (value) => setState(() => _smsNotifications = value),
        ),
      ],
    );
  }

  Widget _buildReminderSection() {
    return _buildSection(
      title: _tr('test_reminders'),
      icon: Icons.alarm,
      children: [
        _buildSwitchTile(
          title: _isArabic ? 'تذكيرات انتهاء الفحص' : 'Test Expiry Reminders',
          subtitle: _isArabic ? 'الحصول على إشعار قبل انتهاء الفحص' : 'Get notified before test expires',
          value: _reminderEnabled,
          onChanged: (value) => setState(() => _reminderEnabled = value),
        ),
        if (_reminderEnabled) ...[
          Divider(height: 1, color: _borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tr('reminder_before'), style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [3, 7, 14, 30].map((days) {
                    final isSelected = _reminderDays == days;
                    return ChoiceChip(
                      label: Text('$days ${_tr('days')}'),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) setState(() => _reminderDays = days);
                      },
                      selectedColor: _primaryColor.withOpacity(0.2),
                      backgroundColor: _cardColor,
                      labelStyle: TextStyle(
                        color: isSelected ? _primaryColor : _textPrimary,
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

  Widget _buildAboutSection() {
    return _buildSection(
      title: _tr('about'),
      icon: Icons.info_outline,
      children: [
        _buildTapTile(
          title: _tr('privacy_policy'),
          icon: Icons.privacy_tip_outlined,
          onTap: () => _showSnackBar(_tr('coming_soon')),
        ),
        Divider(height: 1, color: _borderColor),
        _buildTapTile(
          title: _tr('terms_of_service'),
          icon: Icons.description_outlined,
          onTap: () => _showSnackBar(_tr('coming_soon')),
        ),
        Divider(height: 1, color: _borderColor),
        _buildTapTile(
          title: _tr('help_support'),
          icon: Icons.help_outline,
          onTap: () => _showSnackBar(_tr('coming_soon')),
        ),
        Divider(height: 1, color: _borderColor),
        _buildTapTile(
          title: _tr('rate_app'),
          icon: Icons.star_outline,
          onTap: () => _showSnackBar(_tr('coming_soon')),
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
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.directions_car, color: _primaryColor, size: 32),
          ),
          const SizedBox(height: 12),
          Text(_tr('app_name'), style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 4),
          Text('${_tr('version')} 1.0.0', style: AppTheme.bodySm.copyWith(color: _textSecondary)),
          const SizedBox(height: 4),
          Text('© 2025 Green Crescent', style: AppTheme.bodySm.copyWith(color: _textSecondary.withOpacity(0.6))),
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
            Icon(icon, size: 20, color: _primaryColor),
            const SizedBox(width: 8),
            Text(title, style: AppTheme.titleLg.copyWith(color: _textPrimary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
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
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: _textPrimary)),
      subtitle: Text(subtitle, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
      value: value,
      onChanged: onChanged,
      activeColor: _primaryColor,
    );
  }

  Widget _buildTapTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _textSecondary, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: _textPrimary)),
      trailing: Icon(Icons.chevron_right, color: _textSecondary),
      onTap: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}