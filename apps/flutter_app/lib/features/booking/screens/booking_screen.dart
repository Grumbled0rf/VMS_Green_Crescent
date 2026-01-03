import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/booking_service.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/booking.dart';
import 'create_booking_screen.dart';

class BookingScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const BookingScreen({super.key, required this.vehicles});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _upcomingBookings = [];
  List<Booking> _pastBookings = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() { _isLoading = true; _error = null; });

    final upcomingResult = await BookingService.getUpcoming();
    final pastResult = await BookingService.getPast();

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (upcomingResult.isSuccess) {
          _upcomingBookings = upcomingResult.data ?? [];
        }
        if (pastResult.isSuccess) {
          _pastBookings = pastResult.data ?? [];
        }
        if (!upcomingResult.isSuccess && !pastResult.isSuccess) {
          _error = upcomingResult.message ?? pastResult.message;
        }
      });
    }
  }

  void _navigateToCreateBooking() async {
    if (widget.vehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a vehicle first')),
      );
      return;
    }

    final result = await Navigator.of(context).push<Booking>(
      MaterialPageRoute(builder: (_) => CreateBookingScreen(vehicles: widget.vehicles)),
    );

    if (result != null) {
      _loadBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking confirmed! Code: ${result.confirmationCode}')),
      );
    }
  }

  Future<void> _cancelBooking(Booking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel the booking for ${booking.vehicleName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await BookingService.cancel(booking.id!);
      if (result.isSuccess) {
        _loadBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? 'Failed to cancel')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookings'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadBookings),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Upcoming (${_upcomingBookings.length})'),
            Tab(text: 'Past (${_pastBookings.length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingsList(_upcomingBookings, isUpcoming: true),
                    _buildBookingsList(_pastBookings, isUpcoming: false),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateBooking,
        icon: const Icon(Icons.add),
        label: const Text('New Booking'),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred', style: AppTheme.titleMd),
          const SizedBox(height: 16),
          ElevatedButton.icon(onPressed: _loadBookings, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, {required bool isUpcoming}) {
    if (bookings.isEmpty) {
      return _buildEmptyState(isUpcoming);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildBookingCard(bookings[index], isUpcoming: isUpcoming),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isUpcoming) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.calendar_today_outlined, size: 40, color: AppColors.lightGray),
          ),
          const SizedBox(height: 16),
          Text(isUpcoming ? 'No upcoming bookings' : 'No past bookings', style: AppTheme.titleMd),
          const SizedBox(height: 8),
          Text(isUpcoming ? 'Book a test for your vehicle' : 'Your booking history will appear here', style: AppTheme.bodyMd),
          if (isUpcoming) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(onPressed: _navigateToCreateBooking, icon: const Icon(Icons.add), label: const Text('Book Now')),
          ],
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, {required bool isUpcoming}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today, color: _getStatusColor(booking.status)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.vehicleName ?? 'Vehicle', style: AppTheme.titleMd),
                    Text(booking.vehiclePlate ?? '', style: AppTheme.bodySm),
                  ],
                ),
              ),
              _buildStatusBadge(booking.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Details
          _buildDetailRow(Icons.location_on_outlined, booking.testCenterName ?? 'Test Center'),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_month, booking.formattedDate),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.access_time, booking.timeSlot),
          if (booking.confirmationCode != null) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.confirmation_number, booking.confirmationCode!),
          ],

          // Price
          if (booking.price != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: AppTheme.bodyMd),
                  Text('AED ${booking.price!.toStringAsFixed(0)}', style: AppTheme.titleMd.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],

          // Actions for upcoming bookings
          if (isUpcoming && !booking.isCancelled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cancelBooking(booking),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error)),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reschedule coming soon!'))),
                    child: const Text('Reschedule'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.gray),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTheme.bodyMd)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    final text = status[0].toUpperCase() + status.substring(1);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return AppColors.warning;
      case 'confirmed': return AppColors.primary;
      case 'completed': return AppColors.success;
      case 'cancelled': return AppColors.error;
      default: return AppColors.gray;
    }
  }
}