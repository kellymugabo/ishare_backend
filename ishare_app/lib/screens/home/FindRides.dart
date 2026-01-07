import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// ✅ REQUIRED to read specific server errors
import 'package:dio/dio.dart';

// ✅ OPENSTREETMAP IMPORTS
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// 🌍 LOCALIZATION IMPORT
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../models/trip_model.dart';
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../widgets/verification_badge.dart';

// ✅ SCREENS
import 'create_trips_screen.dart';
import '../public_profile_screen.dart'; 

// =====================================================
// FIND RIDES SCREEN
// =====================================================
class FindRidesScreen extends ConsumerStatefulWidget {
  const FindRidesScreen({super.key});

  @override
  ConsumerState<FindRidesScreen> createState() => _FindRidesScreenState();
}

class _FindRidesScreenState extends ConsumerState<FindRidesScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  String _searchQueryFrom = "";
  String _searchQueryTo = "";

  bool _isMapView = false;
  // 📍 Kigali Center Coordinates
  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(tripsProvider);
    });
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // =====================================================
  // 1. HELPER METHODS
  // =====================================================

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to book a ride.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _processBooking(BuildContext context, WidgetRef ref, TripModel trip, int seats) async {
    // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      final apiService = ref.read(apiServiceProvider);
      
      // 1. Create the booking
      await apiService.createBooking({
        'trip_id': trip.id,
        'seats_booked': seats,
      });

      // ✅ Force the app to re-download the trips immediately
      ref.invalidate(tripsProvider); 

      if (context.mounted) {
        Navigator.pop(context); // Close Loader
        Navigator.pop(context); // Close Booking Dialog
        
        // 2. Success Message
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: const Text(
              "Booking Successful! \n\nThe seat availability has been updated.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close Loader
        
        String errorMessage = "Request failed. Please try again.";
        bool isUserError = false;

        if (e is DioException) {
          if (e.response != null && e.response?.data != null) {
            final data = e.response?.data;
            if (data is Map<String, dynamic>) {
              if (data.containsKey('detail')) {
                errorMessage = data['detail'].toString();
                if (errorMessage.toLowerCase().contains("already booked")) {
                   errorMessage = "You have already booked this ride.";
                   isUserError = true;
                }
              } else if (data.containsKey('non_field_errors')) {
                 errorMessage = data['non_field_errors'][0].toString();
                 isUserError = true;
              }
            } else {
              errorMessage = data.toString();
            }
          }
        } 

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(
            children: [
              Icon(isUserError ? Icons.cancel : Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMessage)),
            ],
          ),
          backgroundColor: isUserError ? Colors.red.shade700 : Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _showBookingDialog(BuildContext context, WidgetRef ref, TripModel trip) async {
    final l10n = AppLocalizations.of(context)!;
    final apiService = ref.read(apiServiceProvider);
    final isLoggedIn = await apiService.isLoggedIn();

    if (!isLoggedIn && context.mounted) {
      _showLoginDialog(context);
      return;
    }

    int selectedSeats = 1;

    // Helper for Date Display in Dialog
    String dateText = "";
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(trip.departureTime.year, trip.departureTime.month, trip.departureTime.day);
    if(tripDate == today) {
      dateText = "Today";
    } else if (tripDate == today.add(const Duration(days: 1))) {
      dateText = "Tomorrow";
    } else {
      dateText = DateFormat('MMM d').format(trip.departureTime);
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(l10n.bookNow, style: const TextStyle(fontWeight: FontWeight.w800)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text("$dateText • ${DateFormat('h:mm a').format(trip.departureTime)}", style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),
                Text(
                  '${l10n.totalPrice}: ${AppConstants.formatCurrency(trip.pricePerSeat * selectedSeats)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove),
                      onPressed: selectedSeats > 1 ? () => setState(() => selectedSeats--) : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$selectedSeats', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add),
                      onPressed: selectedSeats < trip.availableSeats ? () => setState(() => selectedSeats++) : null,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(l10n.seatsLeft(trip.availableSeats),
                    style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
              ElevatedButton(
                onPressed: () => _processBooking(context, ref, trip, selectedSeats),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Request Booking'),
              ),
            ],
          ),
        ),
      );
    }
  }

  // =====================================================
  // 2. UI BUILD METHOD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      resizeToAvoidBottomInset: false,
      body: CustomScrollView(
        physics: _isMapView ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
        slivers: [
          // --- 1. PROFESSIONAL VALUE BANNER ---
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Color.fromRGBO(33, 150, 243, 0.08), blurRadius: 20, offset: Offset(0, 10))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // WELCOME BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryBlue, Color(0xFF1E88E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryBlue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Connect. Split Costs.\nEnjoy the Ride.",
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.2),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Find travelers heading your way and travel comfortably for less.",
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    l10n.findRide,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 16),

                  // Search Inputs
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: AppTheme.cardDecoration.copyWith(borderRadius: BorderRadius.circular(16)),
                          child: TextField(
                            controller: _fromController,
                            decoration: InputDecoration(
                              hintText: l10n.pickUp,
                              prefixIcon: const Icon(Icons.my_location_rounded, color: AppTheme.primaryBlue, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) => setState(() => _searchQueryFrom = value.toLowerCase()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: AppTheme.cardDecoration.copyWith(borderRadius: BorderRadius.circular(16)),
                          child: TextField(
                            controller: _toController,
                            decoration: InputDecoration(
                              hintText: l10n.dropOff,
                              prefixIcon: const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            ),
                            onChanged: (value) => setState(() => _searchQueryTo = value.toLowerCase()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        ref.invalidate(tripsProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(l10n.searchRides, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 2. Title & Toggle ---
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.recommended,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
                  ),
                  InkWell(
                    onTap: () => setState(() => _isMapView = !_isMapView),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(_isMapView ? Icons.list_rounded : Icons.map_rounded, size: 16, color: AppTheme.textDark),
                          const SizedBox(width: 6),
                          Text(
                            _isMapView ? l10n.listView : l10n.mapView,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 3. Results ---
          tripsAsync.when(
            data: (trips) {
              final filteredTrips = trips.where((trip) {
                if (trip.isActive == false) return false;
                final matchesFrom = trip.startLocationName.toLowerCase().contains(_searchQueryFrom);
                final matchesTo = trip.destinationName.toLowerCase().contains(_searchQueryTo);
                return matchesFrom && matchesTo;
              }).toList();

              if (filteredTrips.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(l10n),
                );
              }

              if (_isMapView) {
                return SliverFillRemaining(
                  hasScrollBody: true,
                  child: _buildOpenStreetMap(filteredTrips),
                );
              }

              // ✅ CATEGORIZATION LOGIC
              final economyRides = filteredTrips.where((t) => t.pricePerSeat <= 2500).toList();
              final standardRides = filteredTrips.where((t) => t.pricePerSeat > 2500 && t.pricePerSeat <= 5000).toList();
              final premiumRides = filteredTrips.where((t) => t.pricePerSeat > 5000).toList();

              // Sort lists internally
              int sortFunc(TripModel a, TripModel b) => a.pricePerSeat.compareTo(b.pricePerSeat);
              economyRides.sort(sortFunc);
              standardRides.sort(sortFunc);
              premiumRides.sort(sortFunc);

              return SliverPadding(
                padding: const EdgeInsets.only(bottom: 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    
                    if (premiumRides.isNotEmpty) 
                      _buildCategoryBlock(
                        title: "Premium Class",
                        subtitle: "Luxury & Speed",
                        icon: Icons.star_rounded,
                        color: Colors.orange[800]!,
                        rides: premiumRides,
                        l10n: l10n
                      ),

                    if (standardRides.isNotEmpty) 
                      _buildCategoryBlock(
                        title: "Standard Comfort",
                        subtitle: "Reliable daily rides",
                        icon: Icons.thumb_up_rounded,
                        color: AppTheme.primaryBlue,
                        rides: standardRides,
                        l10n: l10n
                      ),

                    if (economyRides.isNotEmpty) 
                      _buildCategoryBlock(
                        title: "Economy Saver",
                        subtitle: "Best prices for you",
                        icon: Icons.savings_rounded,
                        color: Colors.green[700]!,
                        rides: economyRides,
                        l10n: l10n
                      ),
                  ]),
                ),
              );
            },
            // ✅ PROFESSIONAL SKELETON LOADING
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildSkeletonCard(),
                  childCount: 4, // Show 4 fake loading cards
                ),
              ),
            ),
            error: (error, stack) => SliverFillRemaining(
              child: Center(child: Text("Error: $error")),
            ),
          ),
        ],
      ),
    );
  }

  // --- SKELETON LOADER WIDGET ---
  Widget _buildSkeletonCard() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 110, height: 110, decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(18))),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 20, width: 80, color: Colors.grey[100]),
                    const SizedBox(height: 10),
                    Container(height: 20, width: double.infinity, color: Colors.grey[100]),
                    const SizedBox(height: 10),
                    Container(height: 15, width: 100, color: Colors.grey[100]),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 40, width: double.infinity, decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12))),
        ],
      ),
    );
  }

  Widget _buildCategoryBlock({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required List<TripModel> rides,
    required AppLocalizations l10n,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),

        ...rides.map((trip) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _RideCardWithData(trip: trip, l10n: l10n),
        )),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Divider(color: Colors.grey[200], thickness: 8),
        ),
      ],
    );
  }

 Widget _buildOpenStreetMap(List<TripModel> trips) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ]
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: const MapOptions(
          initialCenter: _kigaliCenter,
          initialZoom: 13.0,
          interactionOptions: InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // 1. THE MAP TILES (Background)
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.ishare.app',
          ),

          // 2. THE ROUTE LINES (Blue Paths)
          PolylineLayer(
            polylines: trips.map((trip) {
              final random = Random(trip.id); // Seed with ID for consistency
              
              // Simulate Start (Car Location)
              final startLat = -1.9441 + (random.nextDouble() - 0.5) * 0.05;
              final startLng = 30.0619 + (random.nextDouble() - 0.5) * 0.05;
              
              // Simulate Destination (Slightly offset from start)
              // In real app: use double.parse(trip.destLat)
              final endLat = startLat + (random.nextBool() ? 0.02 : -0.02);
              final endLng = startLng + (random.nextBool() ? 0.02 : -0.02);

              return Polyline(
                points: [
                  LatLng(startLat, startLng),
                  LatLng(endLat, endLng),
                ],
                strokeWidth: 4.0,
                color: AppTheme.primaryBlue.withOpacity(0.7), // Semi-transparent blue
               
              );
            }).toList(),
          ),

          // 3. THE MARKERS (Pins on top)
          MarkerLayer(
            markers: trips.expand((trip) {
              final random = Random(trip.id);
              
              // Recalculate same random points to match the lines
              final startLat = -1.9441 + (random.nextDouble() - 0.5) * 0.05;
              final startLng = 30.0619 + (random.nextDouble() - 0.5) * 0.05;
              final endLat = startLat + (random.nextBool() ? 0.02 : -0.02);
              final endLng = startLng + (random.nextBool() ? 0.02 : -0.02);

              return [
                // Car Icon (Start)
                Marker(
                  point: LatLng(startLat, startLng),
                  width: 50,
                  height: 50,
                  child: GestureDetector(
                    onTap: () => _showBookingDialog(context, ref, trip),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)]
                      ),
                      child: const Icon(Icons.directions_car, color: AppTheme.primaryBlue, size: 28),
                    ),
                  ),
                ),
                
                // Destination Dot (End)
                Marker(
                  point: LatLng(endLat, endLng),
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4)]
                    ),
                  ),
                ),
              ];
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text('No rides found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextButton(
             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTripScreen())),
             child: const Text("Offer a Ride instead?"),
          )
        ],
      ),
    );
  }
}

// =====================================================
// 3. IMPROVED PROFESSIONAL RIDE CARD (WITH AMENITIES)
// =====================================================
class _RideCardWithData extends ConsumerWidget {
  final TripModel trip;
  final AppLocalizations l10n;

  const _RideCardWithData({required this.trip, required this.l10n});

  // Helper: Get Date String
  String _getDateString() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(trip.departureTime.year, trip.departureTime.month, trip.departureTime.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (tripDate == today) {
      return "Today";
    } else if (tripDate == tomorrow) {
      return "Tomorrow";
    } else {
      return DateFormat('EEE, MMM d').format(trip.departureTime);
    }
  }

  // ✅ HELPER: Build Amenity Icon
  Widget _buildAmenity(IconData icon, String label, bool isAvailable) {
    return Tooltip(
      message: isAvailable ? "Available: $label" : "Not Available: $label",
      triggerMode: TooltipTriggerMode.tap, 
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isAvailable ? AppTheme.surfaceGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isAvailable ? null : Border.all(color: Colors.grey[200]!),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isAvailable ? AppTheme.textDark : Colors.grey[300],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int seats = trip.availableSeats;
    final bool isFull = seats <= 0;
    final dateString = _getDateString();

    // 🔴 HARDCODED AMENITIES (Will be replaced by Backend data later)
    const bool hasAC = true; 
    const bool allowLuggage = true;
    const bool noSmoking = true;
    const bool hasMusic = false; 

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isFull ? null : () =>
            context.findAncestorStateOfType<_FindRidesScreenState>()?._showBookingDialog(context, ref, trip),
          borderRadius: BorderRadius.circular(24),
          child: Opacity(
            opacity: isFull ? 0.7 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- CAR IMAGE ---
                      Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: AppTheme.surfaceGrey,
                              image: (trip.carPhotoUrl != null && trip.carPhotoUrl!.isNotEmpty)
                                  ? DecorationImage(image: NetworkImage(trip.carPhotoUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: (trip.carPhotoUrl == null || trip.carPhotoUrl!.isEmpty)
                                ? Icon(Icons.directions_car_rounded, color: Colors.grey[400], size: 40)
                                : null,
                          ),
                          if (isFull)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: const Text(
                                    "SOLD OUT",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 1.0),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // --- MAIN DETAILS ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PRICE & DATE ROW
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isFull ? Colors.grey[200] : AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8)
                                  ),
                                  child: Text(
                                    AppConstants.formatCurrency(trip.pricePerSeat),
                                    style: TextStyle(
                                      fontSize: 16, 
                                      fontWeight: FontWeight.w800, 
                                      color: isFull ? Colors.grey : AppTheme.primaryBlue
                                    ),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      dateString,
                                      style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold, 
                                        color: dateString == "Today" ? Colors.green : Colors.grey[600]
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Text(
                                          DateFormat('h:mm a').format(trip.departureTime),
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textDark),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            
                            // SEAT BADGE
                            if (!isFull) 
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: seats == 1 ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: seats == 1 ? Colors.orange : Colors.green,
                                          width: 0.5
                                        )
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(seats == 1 ? Icons.local_fire_department : Icons.check_circle_outline, size: 10, color: seats == 1 ? Colors.orange[800] : Colors.green[800]),
                                          const SizedBox(width: 4),
                                          Text(
                                            seats == 1 ? "Only 1 left!" : "$seats seats",
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: seats == 1 ? Colors.orange[800] : Colors.green[800]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 8),
                            
                            // CAR NAME
                            Text(
                              trip.carName ?? "Standard Car",
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            
                            const SizedBox(height: 6),

                            // ✅ NEW: AMENITIES ROW (Professional Touch)
                            Row(
                              children: [
                                _buildAmenity(Icons.ac_unit_rounded, "AC", hasAC),
                                const SizedBox(width: 8),
                                _buildAmenity(Icons.luggage_rounded, "Luggage", allowLuggage),
                                const SizedBox(width: 8),
                                _buildAmenity(Icons.smoke_free_rounded, "No Smoking", noSmoking),
                                const SizedBox(width: 8),
                                _buildAmenity(Icons.music_note_rounded, "Music", hasMusic),
                              ],
                            ),

                            const SizedBox(height: 12),
                            
                            // DRIVER ROW
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => PublicProfileScreen(userId: trip.driver.id, userName: trip.driver.displayName.isNotEmpty ? trip.driver.displayName : trip.driver.username)));
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.grey[200],
                                    child: Text(trip.driver.displayName.isNotEmpty ? trip.driver.displayName[0] : 'U', style: const TextStyle(fontSize: 10)),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      trip.driver.displayName,
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (trip.driver.isVerified) const VerificationBadge(size: 14),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  
                  // --- FOOTER: ROUTE & BUTTON ---
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.circle, size: 8, color: Colors.grey),
                          Container(width: 2, height: 20, color: Colors.grey[200]),
                          const Icon(Icons.circle, size: 8, color: AppTheme.primaryBlue),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip.startLocationName, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 12),
                            Text(trip.destinationName, style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 80, maxHeight: 45),
                        child: ElevatedButton(
                          onPressed: isFull ? null : () =>
                              context.findAncestorStateOfType<_FindRidesScreenState>()?._showBookingDialog(context, ref, trip),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFull ? Colors.grey : AppTheme.textDark,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey[300],
                            disabledForegroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 40), 
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            isFull ? "SOLD OUT" : l10n.bookNow,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}