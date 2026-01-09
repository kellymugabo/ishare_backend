import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../models/trip_model.dart';
import '../../models/booking_model.dart';
import '../../services/api_service.dart';

final tripBookingsProvider = FutureProvider.family<List<BookingModel>, int>(
  (ref, tripId) async {
    final apiService = ref.watch(apiServiceProvider);
    return await apiService.getBookingsForTrip(tripId);
  },
);

class DriverTripDetailsScreen extends ConsumerWidget {
  final TripModel trip;

  const DriverTripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(tripBookingsProvider(trip.id));
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, l10n),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRouteInfoCard(context, l10n),
                  const SizedBox(height: 30),
                  _buildBookingsSection(bookingsAsync, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryBlue,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
        child: const BackButton(color: Colors.black),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)]),
          child: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref, l10n),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          l10n.tripDetails,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20, shadows: [Shadow(color: Colors.black87, blurRadius: 12, offset: Offset(0, 2))]),
        ),
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    final hasCarPhoto = trip.carPhotoUrl != null && trip.carPhotoUrl!.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasCarPhoto)
          Image.network(
            _getValidUrl(trip.carPhotoUrl!), 
            fit: BoxFit.cover, 
            errorBuilder: (c, e, s) => _buildCarPlaceholder()
          )
        else
          _buildCarPlaceholder(),
        Container(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.6)], stops: const [0.0, 0.8]))),
      ],
    );
  }

  Widget _buildCarPlaceholder() {
    return Container(color: AppTheme.primaryBlue, child: const Center(child: Icon(Icons.directions_car, size: 80, color: Colors.white24)));
  }

  Widget _buildRouteInfoCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(children: [_buildRouteHeader(context, l10n), const Divider(height: 30), _buildRouteLocations()]),
    );
  }

  Widget _buildRouteHeader(BuildContext context, AppLocalizations l10n) {
    String formattedDate;
    try {
      final localeCode = Localizations.localeOf(context).languageCode;
      formattedDate = DateFormat('MMM d, yyyy • HH:mm', localeCode).format(trip.departureTime);
    } catch (e) {
      formattedDate = DateFormat('MMM d, yyyy • HH:mm', 'en').format(trip.departureTime);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(formattedDate, style: const TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Text(l10n.seatsLeft(trip.availableSeats), style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildRouteLocations() {
    return Column(children: [_buildLocationRow(icon: Icons.my_location, color: AppTheme.primaryBlue, location: trip.startLocationName), Container(margin: const EdgeInsets.only(left: 9), height: 20, width: 2, color: Colors.grey[300]), _buildLocationRow(icon: Icons.location_on, color: Colors.red, location: trip.destinationName)]);
  }

  Widget _buildLocationRow({required IconData icon, required Color color, required String location}) {
    return Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 12), Expanded(child: Text(location, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)))]);
  }

  Widget _buildBookingsSection(AsyncValue<List<BookingModel>> bookingsAsync, AppLocalizations l10n) {
    return bookingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('${l10n.errorLoadingBookings}$error')),
      data: (bookings) => _buildBookingsContent(bookings, l10n),
    );
  }

  Widget _buildBookingsContent(List<BookingModel> bookings, AppLocalizations l10n) {
    final totalEarnings = bookings.length * trip.pricePerSeat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEarningsSummary(totalEarnings, l10n),
        const SizedBox(height: 30),
        _buildPassengerHeader(bookings.length, l10n),
        const SizedBox(height: 16),
        _buildPassengerList(bookings, l10n),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildEarningsSummary(double totalEarnings, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.green[400]!, Colors.green[700]!]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.estimatedEarnings, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 4), Text(l10n.totalRevenue, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]), Text("${totalEarnings.toStringAsFixed(0)} RWF", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24))]),
    );
  }

  Widget _buildPassengerHeader(int bookingCount, AppLocalizations l10n) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.passengerManifest, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)), Text(l10n.bookedCount(bookingCount), style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.bold))]);
  }

  Widget _buildPassengerList(List<BookingModel> bookings, AppLocalizations l10n) {
    if (bookings.isEmpty) return Center(child: Text(l10n.noPassengers, style: TextStyle(color: Colors.grey[400])));
    return ListView.separated(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: bookings.length, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (context, index) => _buildPassengerCard(bookings[index], l10n));
  }

  Widget _buildPassengerCard(BookingModel booking, AppLocalizations l10n) {
    final passengerName = booking.passenger?.username ?? "Passenger #${booking.id}";
    final passengerPic = booking.passenger?.profilePicture;
    
    // ✅ SAFE IMAGE LOADING LOGIC
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipOval(
          child: SizedBox(
            width: 48, 
            height: 48,
            child: (passengerPic != null && passengerPic.isNotEmpty)
                ? Image.network(
                    _getValidUrl(passengerPic),
                    fit: BoxFit.cover,
                    // If image is missing (404), show initial
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        alignment: Alignment.center,
                        child: Text(
                          passengerName.isNotEmpty ? passengerName[0].toUpperCase() : '?',
                          style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)
                        ),
                      );
                    },
                  )
                : Container(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    alignment: Alignment.center,
                    child: Text(
                      passengerName.isNotEmpty ? passengerName[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)
                    ),
                  ),
          ),
        ),
        title: Text(passengerName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${booking.seatsBooked} ${l10n.seats} - ${l10n.paidStatus}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
        trailing: IconButton(icon: const Icon(Icons.phone, color: Colors.green), onPressed: () {}),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    showDialog(context: context, builder: (ctx) => AlertDialog(title: Text(l10n.cancelTripTitle), content: Text(l10n.cancelTripMessage), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.keepTrip)), ElevatedButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), child: Text(l10n.yesCancel))]));
  }

  // ✅ UPDATED URL VALIDATOR (Forces HTTPS)
  String _getValidUrl(String url) {
    if (url.startsWith('http')) {
      if (url.contains('127.0.0.1') || url.contains('localhost')) {
        return url;
      }
      return url.replaceFirst('http://', 'https://');
    }
    return url.startsWith('/') ? "http://127.0.0.1:8000$url" : "http://127.0.0.1:8000/$url";
  }
}