import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../auth/screens/login_screen.dart';
import '../../vehicles/screens/add_vehicle_screen.dart';
import '../../vehicles/screens/vehicle_detail_screen.dart';
import '../../booking/screens/booking_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../notifications/screens/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _error;

  // Theme helpers
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _bgColor => _isDark ? AppColors.darkBackground : AppColors.background;
  Color get _cardColor => _isDark ? AppColors.darkCard : AppColors.white;
  Color get _borderColor => _isDark ? AppColors.darkBorder : AppColors.border;
  Color get _textPrimary => _isDark ? AppColors.darkTextPrimary : AppColors.dark;
  Color get _textSecondary => _isDark ? AppColors.darkTextSecondary : AppColors.gray;
  Color get _primaryColor => _isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get _primaryLight => _isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await VehicleService.getAll();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result.isSuccess) {
          _vehicles = result.data ?? [];
        } else {
          _error = result.message;
        }
      });
    }
  }

  int get _totalVehicles => _vehicles.length;
  int get _compliantVehicles => _vehicles.where((v) => v.nextTestDue != null && !v.isTestDue && !v.isTestExpiringSoon).length;
  int get _expiringVehicles => _vehicles.where((v) => v.isTestExpiringSoon).length;
  int get _noTestVehicles => _vehicles.where((v) => v.lastTestDate == null).length;

  void _navigateToAddVehicle() async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(builder: (_) => AddVehicleScreen(onVehicleAdded: (v) {})),
    );
    if (result != null) {
      _loadVehicles();
      _showSnackBar('Vehicle added successfully! 🎉');
    }
  }

  void _navigateToVehicleDetail(Vehicle vehicle) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => VehicleDetailScreen(
          vehicle: vehicle,
          onVehicleUpdated: (v) => _loadVehicles(),
          onVehicleDeleted: (id) => _loadVehicles(),
        ),
      ),
    );
    if (result == 'deleted') _loadVehicles();
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
    if (result == true) setState(() {});
  }

  void _navigateToSettings() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddVehicle,
              icon: const Icon(Icons.add),
              label: const Text('Add Vehicle'),
            )
          : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0: return _buildHomeTab();
      case 1: return _buildVehiclesTab();
      case 2: return BookingScreen(vehicles: _vehicles);
      case 3: return _buildProfileTab();
      default: return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                if (_isLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator()))
                else if (_error != null)
                  _buildErrorState()
                else ...[
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildRecentVehicles(),
                ],
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: _cardColor,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.directions_car, color: _primaryColor, size: 22),
          ),
          const SizedBox(width: 12),
          Text('VMS', style: TextStyle(fontWeight: FontWeight.bold, color: _textPrimary)),
        ],
      ),
      actions: [
        IconButton(
  icon: Badge(smallSize: 8, child: Icon(Icons.notifications_outlined, color: _textPrimary)),
  onPressed: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
  ),
),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    final userName = AuthService.userFullName ?? 'User';
    final firstName = userName.split(' ').first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting, $firstName! 👋', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
        const SizedBox(height: 4),
        Text('Manage your vehicles and bookings', style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
      ],
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _loadVehicles, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildVehiclesTab() {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('My Vehicles', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: _textPrimary), onPressed: _loadVehicles),
          IconButton(icon: Icon(Icons.add, color: _textPrimary), onPressed: _navigateToAddVehicle),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildVehicleCard(_vehicles[index], tappable: true),
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.directions_car, 'Total', _totalVehicles.toString(), _primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'Compliant', _compliantVehicles.toString(), AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.warning_amber, 'Expiring', _expiringVehicles.toString(), AppColors.warning)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.help_outline, 'No Test', _noTestVehicles.toString(), _textSecondary)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return InkWell(
      onTap: () => setState(() => _currentIndex = 1),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textPrimary)),
                Text(label, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionButton(Icons.add_circle_outline, 'Add Vehicle', _primaryColor, _navigateToAddVehicle)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.calendar_month, 'Book Test', AppColors.secondary, () => setState(() => _currentIndex = 2))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.history, 'History', AppColors.accent, () => _showSnackBar('History coming soon!'))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(_isDark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentVehicles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('My Vehicles', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
            TextButton(onPressed: () => setState(() => _currentIndex = 1), child: const Text('See All')),
          ],
        ),
        const SizedBox(height: 12),
        if (_vehicles.isEmpty)
          _buildEmptyState()
        else
          ...(_vehicles.take(3).map((v) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildVehicleCard(v, tappable: true),
              ))),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, {bool tappable = false}) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(14)),
            child: Icon(Icons.directions_car, color: _primaryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                const SizedBox(height: 4),
                Text(vehicle.fullPlate, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
              ],
            ),
          ),
          _buildStatusBadge(vehicle),
          if (tappable) Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Icon(Icons.chevron_right, color: _textSecondary),
          ),
        ],
      ),
    );
    return tappable ? InkWell(onTap: () => _navigateToVehicleDetail(vehicle), borderRadius: BorderRadius.circular(16), child: card) : card;
  }

  Widget _buildStatusBadge(Vehicle vehicle) {
    String text;
    Color color;
    if (vehicle.lastTestDate == null) {
      text = 'No Test'; color = _textSecondary;
    } else if (vehicle.isTestDue) {
      text = 'Overdue'; color = AppColors.error;
    } else if (vehicle.isTestExpiringSoon) {
      text = 'Expiring'; color = AppColors.warning;
    } else {
      text = 'Compliant'; color = AppColors.success;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
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
            width: 80, height: 80,
            decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(20)),
            child: Icon(Icons.directions_car_outlined, size: 40, color: _textSecondary),
          ),
          const SizedBox(height: 16),
          Text('No vehicles yet', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 8),
          Text('Add your first vehicle to get started', style: AppTheme.bodyMd.copyWith(color: _textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _navigateToAddVehicle, icon: const Icon(Icons.add), label: const Text('Add Vehicle')),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: _textPrimary), onPressed: _navigateToSettings),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 24),
            _buildProfileStats(),
            const SizedBox(height: 24),
            _buildProfileMenu(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final userName = AuthService.userFullName ?? 'User';
    final userEmail = AuthService.userEmail ?? '';
    final userPhone = AuthService.userPhone ?? '';
    final initials = AuthService.userInitials;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(18)),
            child: Center(child: Text(initials, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _primaryColor))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: AppTheme.titleLg.copyWith(color: _textPrimary)),
                const SizedBox(height: 4),
                Text(userEmail, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
                if (userPhone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(userPhone, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: _primaryColor),
            onPressed: _navigateToEditProfile,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Expanded(child: _buildProfileStat('Vehicles', _totalVehicles.toString(), Icons.directions_car)),
          Container(width: 1, height: 40, color: _borderColor),
          Expanded(child: _buildProfileStat('Compliant', _compliantVehicles.toString(), Icons.check_circle)),
          Container(width: 1, height: 40, color: _borderColor),
          Expanded(child: _buildProfileStat('Bookings', '0', Icons.calendar_today)),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: _primaryColor, size: 24),
        const SizedBox(height: 8),
        Text(value, style: AppTheme.titleLg.copyWith(color: _textPrimary)),
        Text(label, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
      ],
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'Edit Profile', _navigateToEditProfile),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications', () => _showSnackBar('Notifications coming soon!')),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.security, 'Privacy & Security', () => _showSnackBar('Privacy settings coming soon!')),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () => _showSnackBar('Help & Support coming soon!')),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.info_outline, 'About', () => _showAboutDialog()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: _bgColor, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: _textSecondary, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: _textPrimary)),
      trailing: Icon(Icons.chevron_right, color: _textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Logout', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: 'Vehicles'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(20)),
              child: Icon(Icons.directions_car, color: _primaryColor, size: 40),
            ),
            const SizedBox(height: 16),
            Text('VMS Green Crescent', style: AppTheme.headingSm.copyWith(color: _textPrimary)),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
            const SizedBox(height: 16),
            Text('Vehicle Management System for tracking emission tests.', style: AppTheme.bodySm.copyWith(color: _textSecondary), textAlign: TextAlign.center),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        title: Text('Logout', style: TextStyle(color: _textPrimary)),
        content: Text('Are you sure you want to logout?', style: TextStyle(color: _textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (mounted) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}