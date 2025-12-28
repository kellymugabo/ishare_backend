import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// --- Imports ---
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/trip_model.dart';

// --- Screens ---
import '../driver_trip_details_screen.dart'; 
import '../ticket_screen.dart';

class MyTripsScreen extends ConsumerWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Initialize Localization Helper
    final l10n = AppLocalizations.of(context)!; 

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.surfaceGrey,
        appBar: AppBar(
          // ✅ 1. Localized Title
          title: Text(
            l10n.myTripsTitle, 
            style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.textDark)
          ),
          backgroundColor: AppTheme.surfaceGrey,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false, 
          bottom: TabBar(
            labelColor: AppTheme.primaryBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppTheme.primaryBlue,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              // ✅ 2. Localized Tabs
              Tab(text: l10n.bookedTab), 
              Tab(text: l10n.offeredTab), 
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _BookedTripsList(),  
            _OfferedTripsList(), 
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// 1. PASSENGER VIEW LIST (Booked Trips)
// ----------------------------------------------------
class _BookedTripsList extends ConsumerWidget {
  const _BookedTripsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsAsync = ref.watch(bookingsProvider); 
    final l10n = AppLocalizations.of(context)!; 

    return RefreshIndicator(
      // ✅ 1. PULL TO REFRESH LOGIC
      onRefresh: () async {
        return ref.refresh(bookingsProvider);
      },
      child: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          // Allow refresh even on error
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(height: 500, child: Center(child: Text("Error: $e"))),
          )
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            // ✅ 2. Allow refresh on empty state
            return Stack(
              children: [
                ListView(physics: const AlwaysScrollableScrollPhysics()), // Invisible list to allow pull
                _EmptyState(message: l10n.noBookingsMessage),
              ],
            );
          }
          
          return ListView.separated(
            // ✅ 3. Always scrollable ensures Pull-to-Refresh works even with few items
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final booking = bookings[index];
              
              if (booking.trip == null) return const SizedBox.shrink();

              return _TripCard(
                trip: booking.trip!, 
                status: booking.status,
                isPassenger: true,
                onTap: () async {
                  // ✅ 4. Refresh list when returning from Ticket Screen
                  await Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => TicketScreen(booking: booking))
                  );
                  ref.refresh(bookingsProvider);
                },
              );
            },
          );
        },
      ),
    );
  }
}
// ----------------------------------------------------
// 2. DRIVER VIEW LIST (Offered Trips)
// ----------------------------------------------------
class _OfferedTripsList extends ConsumerWidget {
  const _OfferedTripsList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myTripsAsync = ref.watch(myTripsProvider); 
    final l10n = AppLocalizations.of(context)!; 

    return myTripsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text("Error: $e")),
      data: (trips) {
        // ✅ 4. Localized Empty State
        if (trips.isEmpty) return _EmptyState(message: l10n.noOffersMessage);

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: trips.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final trip = trips[index];
            return _TripCard(
              trip: trip,
              status: "My Offer", 
              isPassenger: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => DriverTripDetailsScreen(trip: trip)));
              },
            );
          },
        );
      },
    );
  }
}

// ----------------------------------------------------
// HELPER WIDGETS
// ----------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[500]))
        ]
      )
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final String status;
  final bool isPassenger;
  final VoidCallback onTap;

  const _TripCard({
    required this.trip, 
    required this.status, 
    required this.isPassenger, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final DateTime date = trip.departureTime; 
    final currentLocale = Localizations.localeOf(context).languageCode;

    // ✅ SAFETY FIX: Try-Catch block to handle Kinyarwanda date issues gracefully
    String formattedDate;
    try {
      formattedDate = DateFormat('MMM d, HH:mm', currentLocale).format(date);
    } catch (e) {
      // Fallback to English if the locale is not supported for dates
      formattedDate = DateFormat('MMM d, HH:mm', 'en').format(date);
    }

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header: Time & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate, // ✅ Using the safe variable
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPassenger 
                            ? (status == 'confirmed' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1))
                            : Colors.blue.withOpacity(0.1), 
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        status.toUpperCase(), 
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold, 
                          color: isPassenger 
                              ? (status == 'confirmed' ? Colors.green : Colors.orange)
                              : Colors.blue
                        )
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                
                // Route Visuals
                Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppTheme.primaryBlue), 
                    const SizedBox(width: 8), 
                    // ✅ FIXED: Wrapped in Expanded to prevent Overflow
                    Expanded(
                      child: Text(
                        trip.startLocationName, 
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ]
                ),
                Container(
                  margin: const EdgeInsets.only(left: 4), 
                  height: 12, 
                  width: 2, 
                  color: Colors.grey[300]
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.red), 
                    const SizedBox(width: 6), 
                    // ✅ FIXED: Wrapped in Expanded to prevent Overflow
                    Expanded(
                      child: Text(
                        trip.destinationName, 
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ]
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}