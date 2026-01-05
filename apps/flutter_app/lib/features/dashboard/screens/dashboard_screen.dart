import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/vehicle_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/widgets/responsive.dart';
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

  @override
  Widget build(BuildContext context) {
    // Use responsive layout
    if (Responsive.isDesktop(context)) {
      return _buildDesktopLayout();
    } else if (Responsive.isTablet(context)) {
      return _buildTabletLayout();
    }
    return _buildMobileLayout();
  }

  // ==========================================
  // DESKTOP LAYOUT - Sidebar Navigation
  // ==========================================
  Widget _buildDesktopLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(expanded: true),
          
          // Vertical Divider
          VerticalDivider(width: 1, color: _borderColor),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TABLET LAYOUT - Rail Navigation
  // ==========================================
  Widget _buildTabletLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Row(
        children: [
          // Navigation Rail
          _buildSidebar(expanded: false),
          
          // Vertical Divider
          VerticalDivider(width: 1, color: _borderColor),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // MOBILE LAYOUT - Bottom Navigation
  // ==========================================
  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _bgColor,
      body: _buildMainContent(),
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

  // ==========================================
  // SIDEBAR (Desktop & Tablet)
  // ==========================================
  Widget _buildSidebar({required bool expanded}) {
    final items = [
      _NavItem(Icons.home_outlined, Icons.home, 'Home'),
      _NavItem(Icons.directions_car_outlined, Icons.directions_car, 'Vehicles'),
      _NavItem(Icons.calendar_today_outlined, Icons.calendar_today, 'Bookings'),
      _NavItem(Icons.person_outline, Icons.person, 'Profile'),
    ];

    return Container(
      width: expanded ? 250 : 80,
      color: _cardColor,
      child: Column(
        children: [
          // Logo Header
          Container(
            height: 80,
            padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 16),
            child: Row(
              mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.directions_car, color: _primaryColor, size: 22),
                ),
                if (expanded) ...[
                  const SizedBox(width: 12),
                  Text('VMS', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
                ],
              ],
            ),
          ),
          
          Divider(height: 1, color: _borderColor),
          
          const SizedBox(height: 16),
          
          // Navigation Items
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;
            
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: expanded ? 12 : 8,
                vertical: 4,
              ),
              child: Material(
                color: isSelected ? _primaryColor.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => setState(() => _currentIndex = index),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 0),
                    child: Row(
                      mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? _primaryColor : _textSecondary,
                          size: 24,
                        ),
                        if (expanded) ...[
                          const SizedBox(width: 12),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected ? _primaryColor : _textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          
          const Spacer(),
          
          // Add Vehicle Button
          Padding(
            padding: EdgeInsets.all(expanded ? 16 : 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddVehicle,
                icon: const Icon(Icons.add, size: 20),
                label: expanded ? const Text('Add Vehicle') : const SizedBox.shrink(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: expanded ? 14 : 14),
                ),
              ),
            ),
          ),
          
          Divider(height: 1, color: _borderColor),
          
          // Settings & Logout
          Padding(
            padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 8, vertical: 8),
            child: Column(
              children: [
                _buildSidebarAction(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  expanded: expanded,
                  onTap: _navigateToSettings,
                ),
                _buildSidebarAction(
                  icon: Icons.logout,
                  label: 'Logout',
                  expanded: expanded,
                  onTap: _handleLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidebarAction({
    required IconData icon,
    required String label,
    required bool expanded,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.error : _textSecondary;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 16 : 0),
          child: Row(
            mainAxisAlignment: expanded ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              if (expanded) ...[
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // MAIN CONTENT
  // ==========================================
  Widget _buildMainContent() {
    Widget content;
    switch (_currentIndex) {
      case 0:
        content = _buildHomeContent();
        break;
      case 1:
        content = _buildVehiclesContent();
        break;
      case 2:
        content = BookingScreen(vehicles: _vehicles);
        break;
      case 3:
        content = _buildProfileContent();
        break;
      default:
        content = _buildHomeContent();
    }
    return content;
  }

  Widget _buildHomeContent() {
    final isDesktopOrTablet = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return RefreshIndicator(
      onRefresh: _loadVehicles,
      child: CustomScrollView(
        slivers: [
          // App Bar (only for mobile, desktop/tablet has sidebar)
          if (!isDesktopOrTablet) _buildSliverAppBar(),
          
          SliverPadding(
            padding: Responsive.padding(context),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header for desktop/tablet
                if (isDesktopOrTablet) ...[
                  _buildDesktopHeader(),
                  const SizedBox(height: 24),
                ],
                
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

  Widget _buildDesktopHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Dashboard', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
        Row(
          children: [
            IconButton(
              icon: Badge(smallSize: 8, child: Icon(Icons.notifications_outlined, color: _textPrimary)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: _textPrimary),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
      ],
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

  Widget _buildStatsSection() {
    final columns = Responsive.value(context, mobile: 2, tablet: 4, desktop: 4);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTheme.titleLg.copyWith(color: _textPrimary)),
        const SizedBox(height: 16),
        ResponsiveGrid(
          columns: columns,
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildStatCard(Icons.directions_car, 'Total', _totalVehicles.toString(), _primaryColor),
            _buildStatCard(Icons.check_circle, 'Compliant', _compliantVehicles.toString(), AppColors.success),
            _buildStatCard(Icons.warning_amber, 'Expiring', _expiringVehicles.toString(), AppColors.warning),
            _buildStatCard(Icons.help_outline, 'No Test', _noTestVehicles.toString(), _textSecondary),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _textPrimary)),
            const SizedBox(height: 4),
            Text(label, style: AppTheme.bodySm.copyWith(color: _textSecondary)),
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
        ResponsiveGrid(
          columns: Responsive.value(context, mobile: 3, tablet: 3, desktop: 3),
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildActionButton(Icons.add_circle_outline, 'Add Vehicle', _primaryColor, _navigateToAddVehicle),
            _buildActionButton(Icons.calendar_month, 'Book Test', AppColors.secondary, () => setState(() => _currentIndex = 2)),
            _buildActionButton(Icons.history, 'History', AppColors.accent, () => _showSnackBar('History coming soon!')),
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
    final columns = Responsive.value(context, mobile: 1, tablet: 2, desktop: 3);
    
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
          ResponsiveGrid(
            columns: columns,
            spacing: 12,
            runSpacing: 12,
            children: _vehicles.take(columns == 1 ? 3 : 6).map((v) => _buildVehicleCard(v, tappable: true)).toList(),
          ),
      ],
    );
  }

  Widget _buildVehiclesContent() {
    final columns = Responsive.value(context, mobile: 1, tablet: 2, desktop: 3);
    final isDesktopOrTablet = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: isDesktopOrTablet ? null : AppBar(
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
              ? Center(child: _buildEmptyState())
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: SingleChildScrollView(
                    padding: Responsive.padding(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktopOrTablet) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('My Vehicles', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
                              ElevatedButton.icon(
                                onPressed: _navigateToAddVehicle,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Vehicle'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        ResponsiveGrid(
                          columns: columns,
                          spacing: 16,
                          runSpacing: 16,
                          children: _vehicles.map((v) => _buildVehicleCard(v, tappable: true)).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(height: 4),
                    Text(vehicle.fullPlate, style: AppTheme.bodyMd.copyWith(color: _textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(vehicle),
              if (tappable) Icon(Icons.chevron_right, color: _textSecondary),
            ],
          ),
        ],
      ),
    );
    return tappable 
        ? InkWell(onTap: () => _navigateToVehicleDetail(vehicle), borderRadius: BorderRadius.circular(16), child: card) 
        : card;
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
        mainAxisSize: MainAxisSize.min,
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

  Widget _buildProfileContent() {
    final isDesktopOrTablet = Responsive.isDesktop(context) || Responsive.isTablet(context);
    
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: isDesktopOrTablet ? null : AppBar(
        title: Text('Profile', style: TextStyle(color: _textPrimary)),
        backgroundColor: _cardColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: _textPrimary), onPressed: _navigateToSettings),
        ],
      ),
      body: SingleChildScrollView(
        padding: Responsive.padding(context),
        child: CenteredContent(
          maxWidth: 600,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (isDesktopOrTablet) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Profile', style: AppTheme.headingMd.copyWith(color: _textPrimary)),
                ),
                const SizedBox(height: 24),
              ],
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
          _buildMenuItem(Icons.notifications_outlined, 'Notifications', () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          )),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.security, 'Privacy & Security', () => _showSnackBar('Privacy settings coming soon!')),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () => _showSnackBar('Help & Support coming soon!')),
          Divider(height: 1, color: _borderColor),
          _buildMenuItem(Icons.info_outline, 'About', _showAboutDialog),
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

  // ==========================================
  // NAVIGATION METHODS
  // ==========================================
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

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem(this.icon, this.activeIcon, this.label);
}