import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildContactSection(context),
            const SizedBox(height: 24),
            _buildFAQSection(context),
            const SizedBox(height: 24),
            _buildQuickLinksSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: Colors.white, size: 28),
              SizedBox(width: 12),
              Text(
                'Need Help?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Our support team is available 24/7 to assist you.',
            style: TextStyle(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildContactButton(
                  context,
                  icon: Icons.phone,
                  label: 'Call Us',
                  value: '+971-50-123-4567',
                  onTap: () => _copyToClipboard(context, '+971501234567', 'Phone number copied!'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildContactButton(
                  context,
                  icon: Icons.email,
                  label: 'Email',
                  value: 'support@vms.ae',
                  onTap: () => _copyToClipboard(context, 'support@vms.ae', 'Email copied!'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final faqs = [
      {
        'question': 'How do I book an emission test?',
        'answer': 'Go to the Bookings tab, tap "New Booking", select your vehicle, choose a test center, pick a date and time, then confirm your booking.',
      },
      {
        'question': 'Can I cancel my booking?',
        'answer': 'Yes, you can cancel your booking from the Bookings tab. Find your upcoming booking and tap "Cancel". Cancellations are free up to 24 hours before the appointment.',
      },
      {
        'question': 'How do I add a new vehicle?',
        'answer': 'From the Dashboard or Vehicles tab, tap the "Add Vehicle" button. Fill in your vehicle details including plate number, make, model, and year.',
      },
      {
        'question': 'What is Green Crescent Onsite service?',
        'answer': 'Green Crescent Onsite is our mobile testing service where our certified technicians come to your location to perform the emission test. It\'s convenient and saves you time!',
      },
      {
        'question': 'How will I know when my test is due?',
        'answer': 'The app shows your test status on the Dashboard and Vehicle details. You can also enable reminders in Settings to get notified before your test expires.',
      },
      {
        'question': 'What payment methods are accepted?',
        'answer': 'Payment is collected at the test center. Most centers accept cash, credit/debit cards, and mobile payments like Apple Pay.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Frequently Asked Questions', style: AppTheme.titleLg),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final index = entry.key;
              final faq = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 1),
                  _buildFAQItem(context, faq['question']!, faq['answer']!),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Text(question, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600)),
      children: [
        Text(answer, style: AppTheme.bodyMd),
      ],
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Quick Links', style: AppTheme.titleLg),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildLinkItem(
                context,
                icon: Icons.description_outlined,
                title: 'User Guide',
                subtitle: 'Learn how to use the app',
                onTap: () => _showSnackBar(context, 'User Guide coming soon!'),
              ),
              const Divider(height: 1),
              _buildLinkItem(
                context,
                icon: Icons.video_library_outlined,
                title: 'Video Tutorials',
                subtitle: 'Watch step-by-step guides',
                onTap: () => _showSnackBar(context, 'Video Tutorials coming soon!'),
              ),
              const Divider(height: 1),
              _buildLinkItem(
                context,
                icon: Icons.chat_outlined,
                title: 'Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () => _showSnackBar(context, 'Live Chat coming soon!'),
              ),
              const Divider(height: 1),
              _buildLinkItem(
                context,
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                subtitle: 'Help us improve the app',
                onTap: () => _showReportBugDialog(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: AppTheme.bodySm),
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGray),
      onTap: onTap,
    );
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, message);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showReportBugDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please describe the issue you encountered:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Describe the bug...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Bug report submitted. Thank you! 🙏');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}