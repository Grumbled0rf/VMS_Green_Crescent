import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// AI Chat Service using Anthropic Claude API
class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  // ============================================
  // 🔑 CONFIGURATION - UPDATE THESE VALUES
  // ============================================
  
  // TODO: Replace with your Anthropic API key
  // Get it from: https://console.anthropic.com/settings/keys
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY_HERE';
  
  // Anthropic API endpoint
  static const String _apiUrl = 'https://api.anthropic.com/v1/messages';
  
  // Model to use (claude-3-haiku is fast & cheap, claude-3-sonnet is smarter)
  static const String _model = 'claude-3-haiku-20240307';
  
  // Demo mode when no API key is set
  static bool get _useDemoMode => _apiKey == 'YOUR_ANTHROPIC_API_KEY_HERE';

  // ============================================
  // 📚 KNOWLEDGE BASE - Customize for your app
  // ============================================
  static const String _systemPrompt = '''
You are a helpful, friendly customer support assistant for VMS (Vehicle Management System) by Green Crescent in the UAE.

YOUR ROLE:
- Help users with questions about the VMS app and emission testing
- Be concise, helpful, and friendly
- Use emojis occasionally to be friendly 😊
- If you don't know something, suggest contacting human support
- Respond in the same language the user writes in (English or Arabic)

ABOUT VMS APP:
- VMS is a Vehicle Management System for tracking vehicle emission tests in UAE
- Features: Add vehicles, book emission tests, get reminders, view test history
- Available on iOS, Android, and Web
- Supports English and Arabic languages
- Has dark mode

EMISSION TESTS IN UAE:
- All vehicles must pass annual emission test
- Cost: AED 100-150 (standard), AED 200 (express)
- Test duration: 15-30 minutes
- Valid for 1 year
- Fines up to AED 500 for non-compliance
- Required documents: Vehicle registration (Mulkiya), Emirates ID

TEST CENTERS:
- Multiple authorized centers across all Emirates
- Hours: Saturday-Thursday, 8 AM - 6 PM
- Some offer weekend/extended hours
- Book through the app for convenience

HOW TO USE THE APP:
1. Add Vehicle: Dashboard → Add Vehicle → Enter plate number, make, model
2. Book Test: Dashboard → Book Test → Select vehicle → Choose center → Pick date/time
3. Notifications: Settings → Enable push notifications for reminders
4. Cancel/Reschedule: Bookings tab → Select booking → Cancel or Reschedule

COMMON ISSUES:
- Can't login: Use "Forgot Password" to reset
- Not receiving notifications: Check phone settings and app permissions
- Booking not showing: Pull to refresh or check internet
- Vehicle not adding: Verify plate number format (e.g., Dubai A 12345)

CONTACT SUPPORT:
- Email: support@greencrescent.ae
- Phone: +971-4-XXX-XXXX (8 AM - 8 PM)
- Chat: 24/7 (that's you!)

IMPORTANT RULES:
- Never share personal data or sensitive information
- Don't make up information you're not sure about
- For complex issues, suggest contacting human support
- Be patient and understanding with frustrated users
''';

  final List<ChatMessage> _conversationHistory = [];

  /// Send message and get AI response
  Future<String> sendMessage(String userMessage) async {
    // Add user message to history
    _conversationHistory.add(ChatMessage(role: 'user', content: userMessage));

    // Use demo mode if no API key
    if (_useDemoMode) {
      debugPrint('⚠️ Using demo mode - Add your Anthropic API key for real AI');
      return _getDemoResponse(userMessage);
    }

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode({
          'model': _model,
          'max_tokens': 1024,
          'system': _systemPrompt,
          'messages': _conversationHistory.map((m) => {
            'role': m.role,
            'content': m.content,
          }).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiMessage = data['content'][0]['text'] as String;
        
        // Add AI response to history
        _conversationHistory.add(ChatMessage(role: 'assistant', content: aiMessage));
        
        debugPrint('✅ Claude response received');
        return aiMessage;
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        
        // Parse error message
        try {
          final error = jsonDecode(response.body);
          final errorMsg = error['error']?['message'] ?? 'Unknown error';
          return "I'm having trouble connecting right now. Error: $errorMsg\n\nPlease try again or contact support@greencrescent.ae";
        } catch (_) {
          return _getDemoResponse(userMessage);
        }
      }
    } catch (e) {
      debugPrint('❌ Chat API Error: $e');
      return _getDemoResponse(userMessage);
    }
  }

  /// Demo responses when API key is not configured
  String _getDemoResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(userMessage);
    
    String response;

    // Greetings
    if (message.contains('hello') || message.contains('hi') || message.contains('hey')) {
      response = "Hello! 👋 Welcome to VMS Green Crescent Support. I'm here to help you 24/7.\n\nHow can I assist you today? You can ask about:\n• Booking emission tests\n• Adding vehicles\n• Prices & test centers\n• App features";
    } 
    else if (message.contains('مرحبا') || message.contains('السلام') || message.contains('هلا')) {
      response = "مرحباً! 👋 أهلاً بك في دعم VMS الهلال الأخضر.\n\nكيف يمكنني مساعدتك اليوم؟ يمكنك السؤال عن:\n• حجز فحص الانبعاثات\n• إضافة مركبة\n• الأسعار ومراكز الفحص";
    }
    // Pricing
    else if (message.contains('price') || message.contains('cost') || message.contains('fee') || message.contains('how much')) {
      response = "💰 **Emission Test Pricing:**\n\n• Standard test: AED 100-150\n• Express service: AED 200\n• Re-test (if failed): AED 50\n\nPrices may vary by test center. Payment accepted: Cash, Card, Apple Pay.\n\nWould you like to book a test now?";
    }
    else if (message.contains('سعر') || message.contains('تكلفة') || message.contains('كم')) {
      response = "💰 **أسعار فحص الانبعاثات:**\n\n• الفحص العادي: 100-150 درهم\n• الخدمة السريعة: 200 درهم\n• إعادة الفحص: 50 درهم\n\nهل تريد حجز فحص الآن؟";
    }
    // Booking
    else if (message.contains('book') || message.contains('appointment') || message.contains('schedule') || message.contains('reserve')) {
      response = "📅 **How to Book an Emission Test:**\n\n1. Open the app → Go to Dashboard\n2. Tap **'Book Test'** button\n3. Select your vehicle\n4. Choose a test center near you\n5. Pick your preferred date & time\n6. Confirm your booking\n\n✅ You'll receive a confirmation notification and email.\n\nNeed help with any step?";
    }
    else if (message.contains('حجز') || message.contains('موعد')) {
      response = "📅 **كيفية حجز فحص الانبعاثات:**\n\n1. افتح التطبيق → اذهب للوحة التحكم\n2. اضغط **'حجز فحص'**\n3. اختر مركبتك\n4. اختر مركز الفحص\n5. حدد التاريخ والوقت\n6. أكد الحجز\n\n✅ ستصلك رسالة تأكيد.\n\nهل تحتاج مساعدة؟";
    }
    // Add vehicle
    else if (message.contains('add vehicle') || message.contains('register car') || message.contains('new vehicle') || message.contains('add car')) {
      response = "🚗 **How to Add a Vehicle:**\n\n1. Go to Dashboard or Vehicles tab\n2. Tap **'+ Add Vehicle'** button\n3. Enter your plate number:\n   • Format: Dubai A 12345\n   • Select your Emirate\n4. Fill in: Make, Model, Year\n5. Add VIN number (optional)\n6. Tap **'Save'**\n\nYour vehicle will appear on the dashboard ready for booking!";
    }
    // Notifications
    else if (message.contains('notification') || message.contains('reminder') || message.contains('alert')) {
      response = "🔔 **Notification Settings:**\n\nWe send automatic reminders:\n• 30 days before test expires\n• 7 days before\n• 1 day before\n\n**To enable notifications:**\n1. Go to Settings in the app\n2. Enable 'Push Notifications'\n3. Allow notifications when prompted by your phone\n\n**Not receiving notifications?**\n• Check your phone's notification settings\n• Make sure the app has permission";
    }
    // Password reset
    else if (message.contains('password') || message.contains('forgot') || message.contains('reset') || message.contains('login problem')) {
      response = "🔐 **Reset Your Password:**\n\n1. Go to the Login screen\n2. Tap **'Forgot Password?'**\n3. Enter your email address\n4. Check your inbox (and spam folder)\n5. Click the reset link\n6. Create a new password\n\n⏰ The link expires in 24 hours.\n\nStill having trouble? Contact support@greencrescent.ae";
    }
    // Contact support
    else if (message.contains('contact') || message.contains('human') || message.contains('agent') || message.contains('call') || message.contains('email')) {
      response = "📞 **Contact Our Team:**\n\n• **Email:** support@greencrescent.ae\n• **Phone:** +971-4-XXX-XXXX\n• **Phone Hours:** 8 AM - 8 PM (Sat-Thu)\n• **Chat:** Available 24/7 (that's me! 🤖)\n\nI'm here to help, but for complex issues, our human team is happy to assist!\n\nWhat else can I help you with?";
    }
    // Working hours
    else if (message.contains('time') || message.contains('hours') || message.contains('open') || message.contains('when')) {
      response = "🕐 **Test Center Hours:**\n\n**Most Centers:**\n• Saturday - Thursday: 8 AM - 6 PM\n• Friday: Closed (some open limited hours)\n\n**Some Premium Centers:**\n• Extended hours until 8 PM\n• Weekend appointments available\n\n💡 Tip: Check specific center hours when booking in the app!";
    }
    // Test failure
    else if (message.contains('fail') || message.contains('not pass') || message.contains('reject') || message.contains('didn\'t pass')) {
      response = "❌ **If Your Vehicle Fails the Test:**\n\n1. You'll receive a report listing the issues\n2. Get repairs at any authorized garage\n3. Return for re-test within 14 days\n4. Re-test fee: Only AED 50\n\n**Common Failure Reasons:**\n• High emission levels\n• Engine problems\n• Exhaust system issues\n• Faulty catalytic converter\n\nWould you like garage recommendations?";
    }
    // Documents required
    else if (message.contains('document') || message.contains('require') || message.contains('bring') || message.contains('need')) {
      response = "📄 **What to Bring for Your Test:**\n\n✅ **Required:**\n• Vehicle Registration Card (Mulkiya)\n• Emirates ID\n• Your vehicle\n\n📋 **Optional but helpful:**\n• Previous test certificate\n• Booking confirmation\n\n⏱️ **Test Duration:** 15-30 minutes\n\nAny other questions?";
    }
    // Cancel or reschedule
    else if (message.contains('cancel') || message.contains('reschedule') || message.contains('change booking')) {
      response = "🔄 **Cancel or Reschedule Booking:**\n\n1. Open the app\n2. Go to **'Bookings'** tab\n3. Find your appointment\n4. Tap **'Cancel'** or **'Reschedule'**\n5. If rescheduling, select new date/time\n6. Confirm\n\n⚠️ **Note:** Free cancellation up to 24 hours before your appointment.\n\nNeed help with a specific booking?";
    }
    // Thank you
    else if (message.contains('thank') || message.contains('thanks') || message.contains('thx')) {
      response = "You're very welcome! 😊\n\nI'm glad I could help. Is there anything else you'd like to know about VMS or emission testing?\n\nHave a great day and drive safe! 🚗";
    }
    else if (message.contains('شكر')) {
      response = "عفواً! 😊 سعيد أنني استطعت المساعدة.\n\nهل هناك شيء آخر تود معرفته؟";
    }
    // Goodbye
    else if (message.contains('bye') || message.contains('goodbye') || message.contains('see you')) {
      response = "Goodbye! 👋 Thank you for chatting with VMS Support.\n\nRemember:\n• Keep your emission test up to date\n• Enable notifications for reminders\n• We're here 24/7 if you need help\n\nDrive safe! 🚗💨";
    }
    // App features
    else if (message.contains('feature') || message.contains('what can') || message.contains('how does')) {
      response = "📱 **VMS App Features:**\n\n🚗 **Vehicle Management**\n• Add unlimited vehicles\n• Track test status & history\n• Get expiry reminders\n\n📅 **Easy Booking**\n• Book tests online\n• Choose from multiple centers\n• Reschedule anytime\n\n🔔 **Smart Notifications**\n• Automatic reminders\n• Booking confirmations\n• Test results\n\n🌙 **Personalization**\n• Dark mode\n• Arabic & English\n• Customizable reminders\n\nWhat would you like to know more about?";
    }
    // Default response
    else {
      if (isArabic) {
        response = "شكراً على رسالتك! 🤔\n\nيمكنني مساعدتك في:\n• حجز فحص الانبعاثات\n• إضافة أو إدارة المركبات\n• الأسعار ومواعيد العمل\n• مشاكل التطبيق\n• إعادة تعيين كلمة المرور\n\nكيف يمكنني مساعدتك اليوم؟";
      } else {
        response = "Thanks for your message! 🤔\n\nI can help you with:\n• Booking emission tests\n• Adding/managing vehicles\n• Prices & center hours\n• App troubleshooting\n• Password reset\n• General questions\n\nCould you tell me more about what you need help with?";
      }
    }

    // Add to history
    _conversationHistory.add(ChatMessage(role: 'assistant', content: response));
    
    return response;
  }

  /// Clear conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }

  /// Get conversation history
  List<ChatMessage> get history => List.unmodifiable(_conversationHistory);

  /// Get quick reply suggestions based on context
  List<String> getQuickReplies(String? lastMessage) {
    if (lastMessage == null || lastMessage.isEmpty) {
      return [
        '📅 Book a test',
        '💰 Test prices',
        '🚗 Add vehicle',
        '🔔 Notifications',
        '📞 Contact support',
      ];
    }
    
    final message = lastMessage.toLowerCase();
    
    if (message.contains('book') || message.contains('appointment')) {
      return ['Show test centers', 'Available dates', 'Cancel booking', 'Reschedule'];
    } else if (message.contains('price') || message.contains('cost')) {
      return ['Book now', 'Payment methods', 'Express service'];
    } else if (message.contains('vehicle') || message.contains('car')) {
      return ['Add vehicle', 'Edit vehicle', 'Vehicle status'];
    } else if (message.contains('fail')) {
      return ['Find a garage', 'Re-test booking', 'Common issues'];
    } else if (message.contains('notification')) {
      return ['Enable notifications', 'Reminder settings', 'Not receiving alerts'];
    } else if (message.contains('thank') || message.contains('bye')) {
      return ['Start new chat', 'Rate this chat', 'Contact support'];
    }
    
    return ['Book a test', 'Check prices', 'Help with app', 'Contact support'];
  }
}

/// Chat message model
class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  
  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };
}