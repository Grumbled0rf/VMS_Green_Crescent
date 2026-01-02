import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/vehicle.dart';
import '../../auth/screens/login_screen.dart';
import '../../vehicles/screens/add_vehicle_screen.dart';
import '../../vehicles/screens/vehicle_detail_screen.dart';
import '../../booking/screens/booking_screen.dart';

// ============================================
// DASHBOARD SCREEN
// Main home screen with tabs
// ============================================
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Vehicle> _vehicles = [
    Vehicle(
      id: '1',
      plateNumber: 'A 12345',
      emirate: 'Dubai',
      make: 'Toyota',
      model: 'Land Cruiser',
      year: 2022,
      fuelType: 'Petrol',
      color: 'White',
      lastTestDate: DateTime.now().subtract(const Duration(days: 200)),
      nextTestDue: DateTime.now().add(const Duration(days: 165)),
    ),
    Vehicle(
      id: '2',
      plateNumber: 'B 98765',
      emirate: 'Dubai',
      make: 'Nissan',
      model: 'Patrol',
      year: 2021,
      fuelType: 'Petrol',
      color: 'Black',
      lastTestDate: DateTime.now().subtract(const Duration(days: 340)),
      nextTestDue: DateTime.now().add(const Duration(days: 25)),
    ),
  ];

  int get _totalVehicles => _vehicles.length;
  int get _compliantVehicles => _vehicles.where((v) => 
    v.nextTestDue != null && !v.isTestDue && !v.isTestExpiringSoon).length;
  int get _expiringVehicles => _vehicles.where((v) => v.isTestExpiringSoon).length;
  int get _noTestVehicles => _vehicles.where((v) => v.lastTestDate == null).length;

  void _navigateToAddVehicle() async {
    final result = await Navigator.of(context).push<Vehicle>(
      MaterialPageRoute(builder: (_) => AddVehicleScreen(onVehicleAdded: (v) {})),
    );
    if (result != null) {
      setState(() => _vehicles.add(result));
      _showSnackBar('Vehicle added successfully! 🎉');
    }
  }

  void _navigateToVehicleDetail(Vehicle vehicle) async {
    final result = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => VehicleDetailScreen(
          vehicle: vehicle,
          onVehicleUpdated: (v) {
            setState(() {
              final i = _vehicles.indexWhere((x) => x.id == v.id);
              if (i != -1) _vehicles[i] = v;
            });
          },
          onVehicleDeleted: (id) {
            setState(() => _vehicles.removeWhere((v) => v.id == id));
          },
        ),
      ),
    );
    if (result == 'deleted') {
      setState(() => _vehicles.removeWhere((v) => v.id == vehicle.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildVehiclesTab();
      case 2:
        return BookingScreen(vehicles: _vehicles);
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentVehicles(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _navigateToAddVehicle),
        ],
      ),
      body: _vehicles.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _vehicles.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildVehicleCard(_vehicles[index], tappable: true),
              ),
            ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_car, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('VMS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.dark)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Badge(smallSize: 8, child: Icon(Icons.notifications_outlined)),
          onPressed: () => _showSnackBar('Notifications coming soon!'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$greeting! 👋', style: AppTheme.headingMd),
        const SizedBox(height: 4),
        Text('Manage your vehicles and bookings', style: AppTheme.bodyMd),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTheme.titleLg),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.directions_car, 'Total', _totalVehicles.toString(), AppColors.primary, () => setState(() => _currentIndex = 1))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.check_circle, 'Compliant', _compliantVehicles.toString(), AppColors.success, () => setState(() => _currentIndex = 1))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard(Icons.warning_amber, 'Expiring', _expiringVehicles.toString(), AppColors.warning, () => setState(() => _currentIndex = 1))),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(Icons.help_outline, 'No Test', _noTestVehicles.toString(), AppColors.gray, () => setState(() => _currentIndex = 1))),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.dark)),
                Text(label, style: AppTheme.bodySm),
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
        Text('Quick Actions', style: AppTheme.titleLg),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildActionButton(Icons.add_circle_outline, 'Add Vehicle', AppColors.primary, _navigateToAddVehicle)),
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
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
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
            Text('My Vehicles', style: AppTheme.titleLg),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.directions_car, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vehicle.displayName, style: AppTheme.titleMd),
                const SizedBox(height: 4),
                Text(vehicle.fullPlate, style: AppTheme.bodyMd),
              ],
            ),
          ),
          _buildStatusBadge(vehicle),
          if (tappable) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.chevron_right, color: AppColors.lightGray)),
        ],
      ),
    );
    return tappable ? InkWell(onTap: () => _navigateToVehicleDetail(vehicle), borderRadius: BorderRadius.circular(16), child: card) : card;
  }

  Widget _buildStatusBadge(Vehicle vehicle) {
    String text;
    Color color;
    if (vehicle.lastTestDate == null) {
      text = 'No Test';
      color = AppColors.gray;
    } else if (vehicle.isTestDue) {
      text = 'Overdue';
      color = AppColors.error;
    } else if (vehicle.isTestExpiringSoon) {
      text = 'Expiring';
      color = AppColors.warning;
    } else {
      text = 'Compliant';
      color = AppColors.success;
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.directions_car_outlined, size: 40, color: AppColors.lightGray),
          ),
          const SizedBox(height: 16),
          Text('No vehicles yet', style: AppTheme.titleMd),
          const SizedBox(height: 8),
          Text('Add your first vehicle to get started', style: AppTheme.bodyMd, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _navigateToAddVehicle, icon: const Icon(Icons.add), label: const Text('Add Vehicle')),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () => _showSnackBar('Settings coming soon!'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(18)),
            child: const Center(child: Text('JD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('John Doe', style: AppTheme.titleLg),
                const SizedBox(height: 4),
                Text('john.doe@email.com', style: AppTheme.bodyMd),
                const SizedBox(height: 4),
                Text('+971 50 123 4567', style: AppTheme.bodySm),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _showSnackBar('Edit profile coming soon!')),
        ],
      ),
    );
  }

  Widget _buildProfileMenu() {
    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          _buildMenuItem(Icons.person_outline, 'My Account', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.notifications_outlined, 'Notifications', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.security, 'Privacy & Security', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.help_outline, 'Help & Support', () {}),
          const Divider(height: 1),
          _buildMenuItem(Icons.info_outline, 'About', () {}),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.gray, size: 20),
      ),
      title: Text(title, style: AppTheme.bodyMd.copyWith(color: AppColors.dark)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.lightGray),
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
        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 14)),
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

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}