import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/insurance_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/insurance.dart';
import '../../../shared/widgets/support_chat_button.dart';
import '../../auth/screens/login_screen.dart';
import '../../vehicles/screens/add_vehicle_screen.dart';
import '../../vehicles/screens/vehicle_detail_screen.dart';
import '../../booking/screens/booking_screen.dart';
import '../../booking/screens/create_booking_screen.dart';
import '../../profile/screens/edit_profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../insurance/screens/insurance_booking_screen.dart';
import '../../../shared/widgets/booking_options_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  List<Vehicle> _vehicles = [];
  List<Insurance> _insurances = [];
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; _error = null; });
    
    // Load vehicles
    final vehicleResult = await VehicleService.getAll();
    
    // Load insurance
    final insuranceResult = await InsuranceService.getAll();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (vehicleResult.isSuccess) {
          _vehicles = vehicleResult.data ?? [];
        } else {
          _error = vehicleResult.message;
        }
        if (insuranceResult.isSuccess) {
          _insurances = insuranceResult.data ?? [];
        }
      });
    }
  }

  // Stats
  int get _totalVehicles => _vehicles.length;
  int get _compliantVehicles => _vehicles.where((v) => v.nextTestDue != null && !v.isTestDue && !v.isTestExpiringSoon).length;
  int get _expiringTests => _vehicles.where((v) => v.isTestExpiringSoon).length;
  int get _activeInsurance => _insurances.where((i) => i.isActive).length;
  int get _expiringInsurance => _insurances.where((i) => i.isExpiringSoon).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          _buildBody(),
          const SupportChatButton(), // 24/7 AI Chat
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentIndex == 0 ? _buildFAB() : null,
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return _buildVehiclesContent();
      case 2:
        return BookingScreen(vehicles: _vehicles);
      case 3:
        return _buildProfileContent();
      default:
        return _buildHomeContent();
    }
  }

  // ==========================================
  // FAB - Book Button with Options
  // ==========================================
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => BookingOptionsDialog.show(context, vehicles: _vehicles),
      icon: const Icon(Icons.add),
      label: const Text('Book'),
    );
  }

  // ==========================================
  // HOME CONTENT
  // ==========================================
  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
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
                  // Stats Section
                  _buildStatsSection(),
                  const SizedBox(height: 24),
                  
                  // Quick Actions with Book Options
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  
                  // Insurance Status (NEW!)
                  _buildInsuranceSection(),
                  const SizedBox(height: 24),
                  
                  // Recent Vehicles
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
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
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
        Text('Manage your vehicles, insurance & bookings', style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
      ],
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
            Expanded(child: _buildStatCard(Icons.directions_car, 'Vehicles', _totalVehicles.toString(), _primaryColor)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'Compliant', _compliantVehicles.toString(), AppColors.success)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.shield, 'Insured', _activeInsurance.toString(), AppColors.secondary)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.warning_amber, 'Expiring', '${_expiringTests + _expiringInsurance}', AppColors.warning)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textPrimary)),
          Text(label, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
        ],
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
            Expanded(child: _buildActionButton(Icons.add_circle, 'Add Vehicle', _primaryColor, _navigateToAddVehicle)),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.speed, 'Book Test', AppColors.success, () => _showBookingOptions(type: 'test'))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionButton(Icons.shield, 'Insurance', AppColors.secondary, () => _showBookingOptions(type: 'insurance'))),
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

  // ==========================================
  // INSURANCE SECTION (NEW!)
  // ==========================================
  Widget _buildInsuranceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('Insurance', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            TextButton(
              onPressed: () => _showBookingOptions(type: 'insurance'),
              child: const Text('Get Quote'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        if (_insurances.isEmpty)
          _buildNoInsuranceCard()
        else
          ..._insurances.take(2).map((insurance) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildInsuranceCard(insurance),
          )),
      ],
    );
  }

  Widget _buildNoInsuranceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withOpacity(0.1),
            _primaryColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Protect Your Vehicle', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                const SizedBox(height: 4),
                Text('Get insurance from our partner companies', style: AppTheme.bodySm.copyWith(color: _textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildPartnerLogo('🏢'),
                    _buildPartnerLogo('🕌'),
                    _buildPartnerLogo('🔵'),
                    Text(' +3 more', style: TextStyle(color: _textSecondary, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showBookingOptions(type: 'insurance'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Get Quote'),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerLogo(String emoji) {
    return Container(
      width: 28,
      height: 28,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _borderColor),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 14))),
    );
  }

  Widget _buildInsuranceCard(Insurance insurance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insurance.companyName, style: AppTheme.titleMd.copyWith(color: _textPrimary)),
                Text(insurance.type.displayName, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildInsuranceStatusBadge(insurance),
              const SizedBox(height: 4),
              Text(
                insurance.isExpired 
                    ? 'Expired' 
                    : '${insurance.daysUntilExpiry} days left',
                style: TextStyle(color: _textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceStatusBadge(Insurance insurance) {
    Color color;
    String text;
    
    if (insurance.isExpired) {
      color = AppColors.error;
      text = 'Expired';
    } else if (insurance.isExpiringSoon) {
      color = AppColors.warning;
      text = 'Expiring';
    } else if (insurance.isActive) {
      color = AppColors.success;
      text = 'Active';
    } else {
      color = _textSecondary;
      text = insurance.status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
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
          _buildEmptyVehicleState()
        else
          ..._vehicles.take(3).map((v) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildVehicleCard(v),
          )),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    // Find insurance for this vehicle
    final insurance = _insurances.where((i) => i.vehicleId == vehicle.id && i.isActive).firstOrNull;
    
    return InkWell(
      onTap: () => _navigateToVehicleDetail(vehicle),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
        ),
        child: Column(
          children: [
            Row(
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
                      Text(vehicle.fullPlate, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: _textSecondary),
              ],
            ),
            const SizedBox(height: 12),
            // Status Row
            Row(
              children: [
                // Test Status
                Expanded(child: _buildVehicleStatusChip(
                  icon: Icons.speed,
                  label: 'Test',
                  status: vehicle.isTestDue ? 'Overdue' : vehicle.isTestExpiringSoon ? 'Expiring' : 'OK',
                  color: vehicle.isTestDue ? AppColors.error : vehicle.isTestExpiringSoon ? AppColors.warning : AppColors.success,
                )),
                const SizedBox(width: 8),
                // Insurance Status
                Expanded(child: _buildVehicleStatusChip(
                  icon: Icons.shield,
                  label: 'Insurance',
                  status: insurance == null ? 'None' : insurance.isExpiringSoon ? 'Expiring' : 'Active',
                  color: insurance == null ? _textSecondary : insurance.isExpiringSoon ? AppColors.warning : AppColors.success,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleStatusChip({
    required IconData icon,
    required String label,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: _textSecondary, fontSize: 10)),
                Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyVehicleState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_outlined, size: 48, color: _textSecondary),
          const SizedBox(height: 16),
          Text('No vehicles yet', style: AppTheme.titleMd.copyWith(color: _textPrimary)),
          const SizedBox(height: 8),
          Text('Add your first vehicle to get started', style: TextStyle(color: _textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _navigateToAddVehicle, icon: const Icon(Icons.add), label: const Text('Add Vehicle')),
        ],
      ),
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
          ElevatedButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  // ==========================================
  // VEHICLES CONTENT
  // ==========================================
  Widget _buildVehiclesContent() {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        title: Text('My Vehicles', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.refresh, color: _textPrimary), onPressed: _loadData),
          IconButton(icon: Icon(Icons.add, color: _textPrimary), onPressed: _navigateToAddVehicle),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? Center(child: _buildEmptyVehicleState())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _vehicles.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildVehicleCard(_vehicles[index]),
                    ),
                  ),
                ),
    );
  }

  // ==========================================
  // PROFILE CONTENT
  // ==========================================
  Widget _buildProfileContent() {
    final userName = AuthService.userFullName ?? 'User';
    final userEmail = AuthService.userEmail ?? '';
    final initials = AuthService.userInitials;

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
            // Profile Header
            Container(
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
                        Text(userEmail, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats
            Row(
              children: [
                Expanded(child: _buildProfileStat('Vehicles', _totalVehicles.toString(), Icons.directions_car)),
                const SizedBox(width: 12),
                Expanded(child: _buildProfileStat('Insured', _activeInsurance.toString(), Icons.shield)),
                const SizedBox(width: 12),
                Expanded(child: _buildProfileStat('Bookings', '0', Icons.calendar_today)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Menu Items
            _buildMenuItem(Icons.person_outline, 'Edit Profile', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _buildMenuItem(Icons.shield_outlined, 'My Insurance', () => _showBookingOptions(type: 'insurance')),
            _buildMenuItem(Icons.notifications_outlined, 'Notifications', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
            const SizedBox(height: 16),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: _primaryColor),
          const SizedBox(height: 8),
          Text(value, style: AppTheme.titleLg.copyWith(color: _textPrimary)),
          Text(label, style: TextStyle(color: _textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: _textSecondary),
        title: Text(title, style: TextStyle(color: _textPrimary)),
        trailing: Icon(Icons.chevron_right, color: _textSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: AppColors.error),
        label: const Text('Logout', style: TextStyle(color: AppColors.error)),
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.directions_car_outlined), activeIcon: Icon(Icons.directions_car), label: 'Vehicles'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  // ==========================================
  // NAVIGATION METHODS
  // ==========================================
  void _showBookingOptions({String? type}) {
    if (type == 'insurance' && _vehicles.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => InsuranceBookingScreen(vehicle: _vehicles.first)));
    } else if (type == 'test' && _vehicles.isNotEmpty) {
     Navigator.push(context, MaterialPageRoute(builder: (_) => CreateBookingScreen(vehicles: _vehicles)));
    } else {
      BookingOptionsDialog.show(context, vehicles: _vehicles);
    }
  }

  void _navigateToAddVehicle() async {
    final result = await Navigator.push<Vehicle>(context, MaterialPageRoute(builder: (_) => AddVehicleScreen(onVehicleAdded: (v) {})));
    if (result != null) _loadData();
  }

  void _navigateToVehicleDetail(Vehicle vehicle) async {
    await Navigator.push(context, MaterialPageRoute(
      builder: (_) => VehicleDetailScreen(
        vehicle: vehicle,
        onVehicleUpdated: (v) => _loadData(),
        onVehicleDeleted: (id) => _loadData(),
      ),
    ));
    _loadData();
  }

  void _navigateToSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}