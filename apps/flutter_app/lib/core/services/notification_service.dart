import 'package:flutter/material.dart';

/// NotificationService - Handles local notifications for test reminders
/// Note: For production, add flutter_local_notifications package
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // TODO: Initialize flutter_local_notifications
    // For now, this is a placeholder
    _isInitialized = true;
    debugPrint('NotificationService: Initialized');
  }

  /// Schedule a test reminder notification
  Future<void> scheduleTestReminder({
    required String vehicleId,
    required String vehicleName,
    required DateTime testDueDate,
    required int reminderDaysBefore,
  }) async {
    final reminderDate = testDueDate.subtract(Duration(days: reminderDaysBefore));
    
    if (reminderDate.isBefore(DateTime.now())) {
      debugPrint('NotificationService: Reminder date is in the past, skipping');
      return;
    }

    debugPrint('NotificationService: Scheduled reminder for $vehicleName on $reminderDate');
    
    // TODO: Implement actual notification scheduling
    // await flutterLocalNotificationsPlugin.zonedSchedule(
    //   vehicleId.hashCode,
    //   'Test Reminder',
    //   '$vehicleName emission test is due in $reminderDaysBefore days',
    //   reminderDate,
    //   notificationDetails,
    //   androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //   uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    // );
  }

  /// Cancel a scheduled reminder
  Future<void> cancelReminder(String vehicleId) async {
    debugPrint('NotificationService: Cancelled reminder for $vehicleId');
    // TODO: await flutterLocalNotificationsPlugin.cancel(vehicleId.hashCode);
  }

  /// Cancel all reminders
  Future<void> cancelAllReminders() async {
    debugPrint('NotificationService: Cancelled all reminders');
    // TODO: await flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Show instant notification (for testing)
  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('NotificationService: Show notification - $title: $body');
    // TODO: Implement actual notification
  }

  /// Schedule booking confirmation notification
  Future<void> scheduleBookingReminder({
    required String bookingId,
    required String vehicleName,
    required DateTime bookingDate,
    required String timeSlot,
  }) async {
    // Remind 1 day before
    final reminderDate = bookingDate.subtract(const Duration(days: 1));
    
    if (reminderDate.isBefore(DateTime.now())) {
      // If booking is tomorrow or today, remind in 1 hour
      final now = DateTime.now();
      final reminderTime = now.add(const Duration(hours: 1));
      debugPrint('NotificationService: Scheduled booking reminder for $reminderTime');
    } else {
      debugPrint('NotificationService: Scheduled booking reminder for $reminderDate');
    }
    
    // TODO: Implement actual notification scheduling
  }
}

/// Extension to show in-app notifications
extension NotificationSnackBar on BuildContext {
  void showSuccessNotification(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showErrorNotification(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showInfoNotification(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void showWarningNotification(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}