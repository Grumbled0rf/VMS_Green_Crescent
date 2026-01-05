import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Locale _locale = const Locale('en');
  
  Locale get locale => _locale;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
  ];

  void setLocale(Locale locale) {
    if (!supportedLocales.contains(locale)) return;
    _locale = locale;
    notifyListeners();
    debugPrint('Language changed to: ${locale.languageCode}');
  }

  void setEnglish() => setLocale(const Locale('en'));
  void setArabic() => setLocale(const Locale('ar'));

  void toggleLanguage() {
    if (isEnglish) {
      setArabic();
    } else {
      setEnglish();
    }
  }
}

// ==========================================
// APP STRINGS - ENGLISH & ARABIC
// ==========================================
class AppStrings {
  static String get(String key, BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return isArabic ? (_arStrings[key] ?? key) : (_enStrings[key] ?? key);
  }

  // English Strings
  static const Map<String, String> _enStrings = {
    // General
    'app_name': 'VMS Green Crescent',
    'loading': 'Loading...',
    'error': 'Error',
    'success': 'Success',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'add': 'Add',
    'search': 'Search',
    'retry': 'Retry',
    'close': 'Close',
    'yes': 'Yes',
    'no': 'No',
    'ok': 'OK',
    'done': 'Done',
    'next': 'Next',
    'back': 'Back',
    'skip': 'Skip',

    // Auth
    'welcome_back': 'Welcome Back!',
    'sign_in_continue': 'Sign in to continue',
    'sign_in': 'Sign In',
    'sign_up': 'Sign Up',
    'sign_out': 'Sign Out',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'confirm_password': 'Confirm Password',
    'full_name': 'Full Name',
    'phone': 'Phone Number',
    'forgot_password': 'Forgot Password?',
    'dont_have_account': "Don't have an account?",
    'already_have_account': 'Already have an account?',
    'create_account': 'Create Account',
    'sign_up_get_started': 'Sign up to get started',
    'reset_password': 'Reset Password',
    'send_reset_link': 'Send Reset Link',
    'check_email': 'Check Your Email',
    'reset_email_sent': 'We have sent a password reset link to:',
    'back_to_login': 'Back to Login',
    'resend_email': 'Resend Email',
    'agree_terms': 'I agree to the Terms & Conditions',

    // Onboarding
    'onboarding_title_1': 'Manage Your Vehicles',
    'onboarding_desc_1': 'Add and track all your vehicles in one place. Keep your fleet organized and up-to-date.',
    'onboarding_title_2': 'Book Emission Tests',
    'onboarding_desc_2': 'Schedule emission tests at your convenience. Choose from multiple test centers across UAE.',
    'onboarding_title_3': 'Never Miss a Deadline',
    'onboarding_desc_3': 'Get timely reminders before your test expires. Stay compliant and avoid penalties.',
    'onboarding_title_4': 'Onsite Testing',
    'onboarding_desc_4': "Book Green Crescent onsite service and we'll come to you. Save time and hassle!",
    'get_started': 'Get Started',

    // Dashboard
    'home': 'Home',
    'dashboard': 'Dashboard',
    'good_morning': 'Good Morning',
    'good_afternoon': 'Good Afternoon',
    'good_evening': 'Good Evening',
    'manage_vehicles_bookings': 'Manage your vehicles and bookings',
    'overview': 'Overview',
    'total': 'Total',
    'compliant': 'Compliant',
    'expiring': 'Expiring',
    'no_test': 'No Test',
    'quick_actions': 'Quick Actions',
    'add_vehicle': 'Add Vehicle',
    'book_test': 'Book Test',
    'history': 'History',
    'my_vehicles': 'My Vehicles',
    'see_all': 'See All',

    // Vehicles
    'vehicles': 'Vehicles',
    'vehicle_details': 'Vehicle Details',
    'add_new_vehicle': 'Add New Vehicle',
    'edit_vehicle': 'Edit Vehicle',
    'delete_vehicle': 'Delete Vehicle',
    'delete_vehicle_confirm': 'Are you sure you want to delete this vehicle?',
    'no_vehicles': 'No vehicles yet',
    'add_first_vehicle': 'Add your first vehicle to get started',
    'plate_number': 'Plate Number',
    'make': 'Make',
    'model': 'Model',
    'year': 'Year',
    'color': 'Color',
    'fuel_type': 'Fuel Type',
    'vin': 'VIN Number',
    'emirate': 'Emirate',
    'last_test': 'Last Test',
    'next_test': 'Next Test Due',
    'test_status': 'Test Status',
    'overdue': 'Overdue',
    'days_remaining': 'days remaining',
    'share_vehicle': 'Share Vehicle',
    'vehicle_info': 'Vehicle Information',
    'test_info': 'Test Information',

    // Bookings
    'bookings': 'Bookings',
    'new_booking': 'New Booking',
    'create_booking': 'Create Booking',
    'upcoming': 'Upcoming',
    'past': 'Past',
    'no_upcoming_bookings': 'No upcoming bookings',
    'no_past_bookings': 'No past bookings',
    'book_vehicle_test': 'Book a test for your vehicle',
    'booking_history_appear': 'Your booking history will appear here',
    'select_vehicle': 'Select Vehicle',
    'select_center': 'Select Test Center',
    'select_date_time': 'Select Date & Time',
    'confirm_booking': 'Confirm Booking',
    'booking_confirmed': 'Booking Confirmed!',
    'confirmation_code': 'Confirmation Code',
    'test_center': 'Test Center',
    'date': 'Date',
    'time': 'Time',
    'price': 'Price',
    'total_price': 'Total Price',
    'cancel_booking': 'Cancel Booking',
    'cancel_booking_confirm': 'Are you sure you want to cancel this booking?',
    'reschedule': 'Reschedule',
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'completed': 'Completed',
    'cancelled': 'Cancelled',

    // Profile
    'profile': 'Profile',
    'edit_profile': 'Edit Profile',
    'change_password': 'Change Password',
    'current_password': 'Current Password',
    'new_password': 'New Password',
    'notifications': 'Notifications',
    'privacy_security': 'Privacy & Security',
    'help_support': 'Help & Support',
    'about': 'About',
    'logout_confirm': 'Are you sure you want to logout?',

    // Settings
    'settings': 'Settings',
    'appearance': 'Appearance',
    'theme': 'Theme',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'language': 'Language',
    'english': 'English',
    'arabic': 'Arabic',
    'push_notifications': 'Push Notifications',
    'email_notifications': 'Email Notifications',
    'sms_notifications': 'SMS Notifications',
    'test_reminders': 'Test Reminders',
    'reminder_before': 'Remind me before',
    'days': 'days',
    'app_preferences': 'App Preferences',
    'clear_cache': 'Clear Cache',
    'privacy_policy': 'Privacy Policy',
    'terms_of_service': 'Terms of Service',
    'rate_app': 'Rate the App',
    'version': 'Version',

    // Validation
    'required_field': 'This field is required',
    'invalid_email': 'Please enter a valid email',
    'password_min_length': 'Password must be at least 6 characters',
    'passwords_not_match': 'Passwords do not match',

    // Messages
    'vehicle_added': 'Vehicle added successfully!',
    'vehicle_updated': 'Vehicle updated successfully!',
    'vehicle_deleted': 'Vehicle deleted successfully!',
    'booking_cancelled': 'Booking cancelled',
    'profile_updated': 'Profile updated successfully!',
    'password_changed': 'Password changed successfully!',
    'cache_cleared': 'Cache cleared successfully!',
    'coming_soon': 'Coming soon!',
  };

  // Arabic Strings
  static const Map<String, String> _arStrings = {
    // General
    'app_name': 'نظام إدارة المركبات',
    'loading': 'جاري التحميل...',
    'error': 'خطأ',
    'success': 'نجاح',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'save': 'حفظ',
    'delete': 'حذف',
    'edit': 'تعديل',
    'add': 'إضافة',
    'search': 'بحث',
    'retry': 'إعادة المحاولة',
    'close': 'إغلاق',
    'yes': 'نعم',
    'no': 'لا',
    'ok': 'موافق',
    'done': 'تم',
    'next': 'التالي',
    'back': 'رجوع',
    'skip': 'تخطي',

    // Auth
    'welcome_back': 'مرحباً بعودتك!',
    'sign_in_continue': 'سجل الدخول للمتابعة',
    'sign_in': 'تسجيل الدخول',
    'sign_up': 'إنشاء حساب',
    'sign_out': 'تسجيل الخروج',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'confirm_password': 'تأكيد كلمة المرور',
    'full_name': 'الاسم الكامل',
    'phone': 'رقم الهاتف',
    'forgot_password': 'نسيت كلمة المرور؟',
    'dont_have_account': 'ليس لديك حساب؟',
    'already_have_account': 'لديك حساب بالفعل؟',
    'create_account': 'إنشاء حساب',
    'sign_up_get_started': 'سجل للبدء',
    'reset_password': 'إعادة تعيين كلمة المرور',
    'send_reset_link': 'إرسال رابط إعادة التعيين',
    'check_email': 'تحقق من بريدك الإلكتروني',
    'reset_email_sent': 'لقد أرسلنا رابط إعادة تعيين كلمة المرور إلى:',
    'back_to_login': 'العودة لتسجيل الدخول',
    'resend_email': 'إعادة إرسال البريد',
    'agree_terms': 'أوافق على الشروط والأحكام',

    // Onboarding
    'onboarding_title_1': 'إدارة مركباتك',
    'onboarding_desc_1': 'أضف وتتبع جميع مركباتك في مكان واحد. حافظ على تنظيم أسطولك.',
    'onboarding_title_2': 'حجز فحوصات الانبعاثات',
    'onboarding_desc_2': 'جدول فحوصات الانبعاثات في الوقت المناسب لك. اختر من مراكز فحص متعددة في الإمارات.',
    'onboarding_title_3': 'لا تفوت أي موعد',
    'onboarding_desc_3': 'احصل على تذكيرات في الوقت المناسب قبل انتهاء صلاحية الفحص. ابقَ ملتزماً وتجنب الغرامات.',
    'onboarding_title_4': 'الفحص في الموقع',
    'onboarding_desc_4': 'احجز خدمة الهلال الأخضر في الموقع وسنأتي إليك. وفر الوقت والجهد!',
    'get_started': 'ابدأ الآن',

    // Dashboard
    'home': 'الرئيسية',
    'dashboard': 'لوحة التحكم',
    'good_morning': 'صباح الخير',
    'good_afternoon': 'مساء الخير',
    'good_evening': 'مساء الخير',
    'manage_vehicles_bookings': 'إدارة مركباتك وحجوزاتك',
    'overview': 'نظرة عامة',
    'total': 'الإجمالي',
    'compliant': 'ملتزم',
    'expiring': 'قريب الانتهاء',
    'no_test': 'بدون فحص',
    'quick_actions': 'إجراءات سريعة',
    'add_vehicle': 'إضافة مركبة',
    'book_test': 'حجز فحص',
    'history': 'السجل',
    'my_vehicles': 'مركباتي',
    'see_all': 'عرض الكل',

    // Vehicles
    'vehicles': 'المركبات',
    'vehicle_details': 'تفاصيل المركبة',
    'add_new_vehicle': 'إضافة مركبة جديدة',
    'edit_vehicle': 'تعديل المركبة',
    'delete_vehicle': 'حذف المركبة',
    'delete_vehicle_confirm': 'هل أنت متأكد من حذف هذه المركبة؟',
    'no_vehicles': 'لا توجد مركبات',
    'add_first_vehicle': 'أضف مركبتك الأولى للبدء',
    'plate_number': 'رقم اللوحة',
    'make': 'الشركة المصنعة',
    'model': 'الموديل',
    'year': 'السنة',
    'color': 'اللون',
    'fuel_type': 'نوع الوقود',
    'vin': 'رقم الهيكل',
    'emirate': 'الإمارة',
    'last_test': 'آخر فحص',
    'next_test': 'الفحص القادم',
    'test_status': 'حالة الفحص',
    'overdue': 'متأخر',
    'days_remaining': 'يوم متبقي',
    'share_vehicle': 'مشاركة المركبة',
    'vehicle_info': 'معلومات المركبة',
    'test_info': 'معلومات الفحص',

    // Bookings
    'bookings': 'الحجوزات',
    'new_booking': 'حجز جديد',
    'create_booking': 'إنشاء حجز',
    'upcoming': 'القادمة',
    'past': 'السابقة',
    'no_upcoming_bookings': 'لا توجد حجوزات قادمة',
    'no_past_bookings': 'لا توجد حجوزات سابقة',
    'book_vehicle_test': 'احجز فحصاً لمركبتك',
    'booking_history_appear': 'سيظهر سجل حجوزاتك هنا',
    'select_vehicle': 'اختر المركبة',
    'select_center': 'اختر مركز الفحص',
    'select_date_time': 'اختر التاريخ والوقت',
    'confirm_booking': 'تأكيد الحجز',
    'booking_confirmed': 'تم تأكيد الحجز!',
    'confirmation_code': 'رمز التأكيد',
    'test_center': 'مركز الفحص',
    'date': 'التاريخ',
    'time': 'الوقت',
    'price': 'السعر',
    'total_price': 'السعر الإجمالي',
    'cancel_booking': 'إلغاء الحجز',
    'cancel_booking_confirm': 'هل أنت متأكد من إلغاء هذا الحجز؟',
    'reschedule': 'إعادة الجدولة',
    'pending': 'قيد الانتظار',
    'confirmed': 'مؤكد',
    'completed': 'مكتمل',
    'cancelled': 'ملغي',

    // Profile
    'profile': 'الملف الشخصي',
    'edit_profile': 'تعديل الملف',
    'change_password': 'تغيير كلمة المرور',
    'current_password': 'كلمة المرور الحالية',
    'new_password': 'كلمة المرور الجديدة',
    'notifications': 'الإشعارات',
    'privacy_security': 'الخصوصية والأمان',
    'help_support': 'المساعدة والدعم',
    'about': 'حول التطبيق',
    'logout_confirm': 'هل أنت متأكد من تسجيل الخروج؟',

    // Settings
    'settings': 'الإعدادات',
    'appearance': 'المظهر',
    'theme': 'السمة',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'النظام',
    'language': 'اللغة',
    'english': 'الإنجليزية',
    'arabic': 'العربية',
    'push_notifications': 'إشعارات الدفع',
    'email_notifications': 'إشعارات البريد',
    'sms_notifications': 'إشعارات الرسائل',
    'test_reminders': 'تذكيرات الفحص',
    'reminder_before': 'ذكرني قبل',
    'days': 'أيام',
    'app_preferences': 'تفضيلات التطبيق',
    'clear_cache': 'مسح الذاكرة المؤقتة',
    'privacy_policy': 'سياسة الخصوصية',
    'terms_of_service': 'شروط الخدمة',
    'rate_app': 'قيم التطبيق',
    'version': 'الإصدار',

    // Validation
    'required_field': 'هذا الحقل مطلوب',
    'invalid_email': 'يرجى إدخال بريد إلكتروني صحيح',
    'password_min_length': 'كلمة المرور يجب أن تكون 6 أحرف على الأقل',
    'passwords_not_match': 'كلمات المرور غير متطابقة',

    // Messages
    'vehicle_added': 'تمت إضافة المركبة بنجاح!',
    'vehicle_updated': 'تم تحديث المركبة بنجاح!',
    'vehicle_deleted': 'تم حذف المركبة بنجاح!',
    'booking_cancelled': 'تم إلغاء الحجز',
    'profile_updated': 'تم تحديث الملف الشخصي بنجاح!',
    'password_changed': 'تم تغيير كلمة المرور بنجاح!',
    'cache_cleared': 'تم مسح الذاكرة المؤقتة بنجاح!',
    'coming_soon': 'قريباً!',
  };
}

// ==========================================
// EXTENSION FOR EASY ACCESS
// ==========================================
extension LocalizedString on String {
  String tr(BuildContext context) => AppStrings.get(this, context);
}