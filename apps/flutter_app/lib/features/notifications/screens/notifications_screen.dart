import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/push_notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [];
  String? _fcmToken;

  // Theme helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _borderColor => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;

  @override
  void initState() {
    super.initState();
    _fcmToken = PushNotificationService().fcmToken;
    _loadSampleNotifications();
  }

  void _loadSampleNotifications() {
    // Sample notifications for demo
    _notifications.addAll([
      NotificationItem(
        title: 'Welcome to VMS! 🚗',
        body: 'Thank you for using Vehicle Management System.',
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        type: NotificationType.info,
        isRead: false,
      ),
      NotificationItem(
        title: 'Test Reminder',
        body: 'Your Toyota Camry emission test expires in 7 days.',
        time: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.warning,
        isRead: false,
      ),
      NotificationItem(
        title: 'Booking Confirmed ✅',
        body: 'Your test appointment is scheduled for Jan 15, 2025 at 10:00 AM.',
        time: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.success,
        isRead: true,
      ),
    ]);
  }

  void _copyToken() {
    if (_fcmToken != null) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('FCM Token copied to clipboard! 📋')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
        actions: [
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                setState(() {
                  for (var n in _notifications) {
                    n.isRead = true;
                  }
                });
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FCM Token Card (for testing)
            _buildFCMTokenCard(),
            const SizedBox(height: 24),

            // Notifications List
            Text('Recent Notifications', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
            const SizedBox(height: 16),

            if (_notifications.isEmpty)
              _buildEmptyState()
            else
              ..._notifications.map((notification) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildNotificationCard(notification),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildFCMTokenCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key, color: _primaryColor, size: 20),
              const SizedBox(width: 8),
              Text('FCM Token (for testing)', style: AppTheme.titleMd.copyWith(color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _fcmToken ?? 'Token not available',
                    style: AppTheme.bodySm.copyWith(
                      color: _textSecondary,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _fcmToken != null ? _copyToken : null,
                  icon: Icon(Icons.copy, color: _primaryColor),
                  tooltip: 'Copy token',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '💡 Copy this token and paste it in Firebase Console → Messaging → Send test message',
            style: AppTheme.bodySm.copyWith(color: _textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return InkWell(
      onTap: () {
        setState(() => notification.isRead = true);
        // Handle notification tap
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? _cardColor : _primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.isRead ? _borderColor : _primaryColor.withOpacity(0.3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: _getNotificationColor(notification.type),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: AppTheme.titleMd.copyWith(
                            color: _textPrimary,
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: AppTheme.bodyMd.copyWith(color: _textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.time),
                    style: AppTheme.bodySm.copyWith(color: _textSecondary.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.notifications_off_outlined, size: 40, color: _textSecondary),
          ),
          const SizedBox(height: 16),
          Text('No notifications', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: AppTheme.bodyMd.copyWith(color: _textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.info:
        return _primaryColor;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning_amber;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}

enum NotificationType { success, warning, error, info }

class NotificationItem {
  final String title;
  final String body;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}