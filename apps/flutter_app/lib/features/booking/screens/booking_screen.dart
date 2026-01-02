import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/booking.dart';
import '../../../shared/models/vehicle.dart';
import 'create_booking_screen.dart';

// ============================================
// BOOKING SCREEN
// Lists all bookings with tabs for upcoming/past
// ============================================
class BookingScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const BookingScreen({
    super.key,
    required this.vehicles,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Demo bookings
  final List<Booking> _bookings = [
    Booking(
      id: '1',
      vehicleId: '1',
      testCenterId: '1',
      bookingDate: DateTime.now().add(const Duration(days: 3)),
      timeSlot: '10:00 AM',
      status: 'confirmed',
      confirmationCode: 'VMS-2024-001',
      price: 120,
      vehicleName: 'Toyota Land Cruiser',
      vehiclePlate: 'Dubai A 12345',
      testCenterName: 'Tasjeel Deira',
      testCenterAddress: 'Al Khabaisi, Deira',
    ),
    Booking(
      id: '2',
      vehicleId: '2',
      testCenterId: '2',
      bookingDate: DateTime.now().add(const Duration(days: 7)),
      timeSlot: '02:30 PM',
      status: 'pending',
      confirmationCode: 'VMS-2024-002',
      price: 120,
      vehicleName: 'Nissan Patrol',
      vehiclePlate: 'Dubai B 98765',
      testCenterName: 'ADNOC Service Station',
      testCenterAddress: 'Sheikh Zayed Road',
    ),
    Booking(
      id: '3',
      vehicleId: '1',
      testCenterId: '1',
      bookingDate: DateTime.now().subtract(const Duration(days: 30)),
      timeSlot: '09:00 AM',
      status: 'completed',
      confirmationCode: 'VMS-2024-000',
      price: 120,
      vehicleName: 'Toyota Land Cruiser',
      vehiclePlate: 'Dubai A 12345',
      testCenterName: 'Tasjeel Deira',
      testCenterAddress: 'Al Khabaisi, Deira',
    ),
  ];

  List<Booking> get _upcomingBookings =>
      _bookings.where((b) => b.isUpcoming && !b.isCancelled).toList()
        ..sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

  List<Booking> get _pastBookings =>
      _bookings.where((b) => !b.isUpcoming || b.isCancelled).toList()
        ..sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ==========================================
  // ACTIONS
  // ==========================================

  void _navigateToCreateBooking() async {
    if (widget.vehicles.isEmpty) {
      _showSnackBar('Please add a vehicle first');
      return;
    }

    final result = await Navigator.of(context).push<Booking>(
      MaterialPageRoute(
        builder: (_) => CreateBookingScreen(vehicles: widget.vehicles),
      ),
    );

    if (result != null) {
      setState(() {
        _bookings.insert(0, result);
      });
      _showSnackBar('Booking created successfully! 🎉');
    }
  }

  void _cancelBooking(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text(
          'Are you sure you want to cancel this booking?\n\n'
          '${booking.vehicleName}\n'
          '${booking.formattedDate} at ${booking.timeSlot}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _bookings.indexWhere((b) => b.id == booking.id);
                if (index != -1) {
                  _bookings[index] = booking.copyWith(status: 'cancelled');
                }
              });
              _showSnackBar('Booking cancelled');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${_upcomingBookings.length})'),
            Tab(text: 'Past (${_pastBookings.length})'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateBooking,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(_upcomingBookings, isUpcoming: true),
          _buildBookingList(_pastBookings, isUpcoming: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateBooking,
        icon: const Icon(Icons.add),
        label: const Text('Book Test'),
      ),
    );
  }

  // ==========================================
  // BOOKING LIST
  // ==========================================

  Widget _buildBookingList(List<Booking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBookingCard(bookings[index]),
        );
      },
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getStatusColor(booking.status).withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(booking.status),
                  color: _getStatusColor(booking.status),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _getStatusText(booking.status),
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (booking.confirmationCode != null)
                  Text(
                    booking.confirmationCode!,
                    style: AppTheme.bodySm.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle info
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.vehicleName ?? 'Vehicle',
                            style: AppTheme.titleMd,
                          ),
                          Text(
                            booking.vehiclePlate ?? '',
                            style: AppTheme.bodySm,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        Icons.calendar_today,
                        'Date',
                        booking.formattedDate,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoRow(
                        Icons.access_time,
                        'Time',
                        booking.timeSlot,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Location
                _buildInfoRow(
                  Icons.location_on_outlined,
                  'Location',
                  '${booking.testCenterName}\n${booking.testCenterAddress}',
                ),
                const SizedBox(height: 12),

                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: AppTheme.bodyMd),
                    Text(
                      booking.formattedPrice,
                      style: AppTheme.titleLg.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          if (booking.canCancel)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _cancelBooking(booking),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _showSnackBar('Reschedule coming soon!');
                      },
                      child: const Text('Reschedule'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.gray),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.bodySm),
              Text(value, style: AppTheme.bodyMd.copyWith(color: AppColors.dark)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.calendar_today,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isUpcoming ? 'No Upcoming Bookings' : 'No Past Bookings',
              style: AppTheme.titleLg,
            ),
            const SizedBox(height: 8),
            Text(
              isUpcoming
                  ? 'Book your emission test now'
                  : 'Your completed bookings will appear here',
              style: AppTheme.bodyMd,
              textAlign: TextAlign.center,
            ),
            if (isUpcoming) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _navigateToCreateBooking,
                icon: const Icon(Icons.add),
                label: const Text('Book Test'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPERS
  // ==========================================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.gray;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.verified;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending Confirmation';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}