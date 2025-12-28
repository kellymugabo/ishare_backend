import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/booking_model.dart';

// =====================================================
// ✅ PROVIDER LOGIC
// =====================================================
final driverRequestsProvider = FutureProvider.autoDispose<List<BookingModel>>((ref) async {
  final api = ref.watch(apiServiceProvider);
  final allRequests = await api.getDriverRequests();

  // 1. Filter: Only show 'pending' requests
  final pendingRequests = allRequests.where((r) => r.status.toLowerCase() == 'pending').toList();

  // 2. Dedup: Remove duplicates based on ID
  final uniqueRequests = <int, BookingModel>{};
  for (var r in pendingRequests) {
    if (r.id != null) {
      uniqueRequests[r.id!] = r;
    }
  }
  
  return uniqueRequests.values.toList();
});

// =====================================================
// 📱 SCREEN UI
// =====================================================
class DriverRequestsScreen extends ConsumerWidget {
  const DriverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(driverRequestsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text(
          "Ride Requests", 
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark, fontSize: 18)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: AppTheme.textDark),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[200], height: 1.0),
        ),
        actions: [
           IconButton(
             icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryBlue),
             onPressed: () => ref.refresh(driverRequestsProvider),
           )
        ],
      ),
      body: requestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return _buildEmptyState(ref);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(driverRequestsProvider),
            color: AppTheme.primaryBlue,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: requests.length,
              separatorBuilder: (ctx, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _RequestCard(booking: requests[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, stack) => _buildErrorState(ref, e.toString()),
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 60, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            "No pending requests", 
            style: TextStyle(color: AppTheme.textDark, fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 8),
          Text(
            "You're all caught up! Check back later.", 
            style: TextStyle(color: Colors.grey[500], fontSize: 14)
          ),
          const SizedBox(height: 30),
          TextButton.icon(
            onPressed: () => ref.refresh(driverRequestsProvider),
            icon: const Icon(Icons.refresh, color: AppTheme.primaryBlue),
            label: const Text("Refresh", style: TextStyle(color: AppTheme.primaryBlue)),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            const Text("Unable to load requests", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.refresh(driverRequestsProvider), 
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue, // ✅ CHANGED TO BLUE
                foregroundColor: Colors.white,
              ),
              child: const Text("Try Again")
            )
          ],
        ),
      ),
    );
  }
}

// =====================================================
// 💳 PROFESSIONAL REQUEST CARD
// =====================================================
class _RequestCard extends ConsumerStatefulWidget {
  final BookingModel booking;
  const _RequestCard({required this.booking});

  @override
  ConsumerState<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends ConsumerState<_RequestCard> {
  bool _isLoading = false;

  Future<void> _handleAction(bool approve) async {
    if (widget.booking.id == null) return;

    setState(() => _isLoading = true);
    final api = ref.read(apiServiceProvider);
    
    try {
      if (approve) {
        await api.approveBooking(widget.booking.id!);
        if (mounted) _showToast("Request Approved", Colors.green);
      } else {
        await api.rejectBooking(widget.booking.id!);
        if (mounted) _showToast("Request Rejected", Colors.redAccent);
      }
      ref.invalidate(driverRequestsProvider); 
    } catch (e) {
      if (mounted) _showToast("Error: ${e.toString().split(':')[1]}", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.info, color: Colors.white, size: 20), const SizedBox(width: 8), Text(msg)]), 
        backgroundColor: color, 
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.booking.trip;
    final String nameToShow = widget.booking.displayName; 

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          // HEADER: Passenger Info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.surfaceGrey,
                  radius: 22,
                  child: Text(
                    nameToShow.isNotEmpty ? nameToShow[0].toUpperCase() : 'U', 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameToShow, 
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppTheme.textDark)
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Requesting ${widget.booking.seatsBooked} Seat(s)",
                          style: const TextStyle(fontSize: 11, color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                // Price
                 Text(
                   "\$${widget.booking.totalPrice}",
                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textDark),
                 ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),

          // BODY: Route Info (Visual Timeline)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Column(
                  children: [
                    const Icon(Icons.circle, size: 8, color: Colors.grey),
                    Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.5)),
                    const Icon(Icons.circle, size: 8, color: AppTheme.primaryBlue),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: trip != null ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(trip.startLocationName, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 16),
                      Text(trip.destinationName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ) : const Text("Route info unavailable", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          // FOOTER: Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _isLoading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
              : Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleAction(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red[400],
                          side: BorderSide(color: Colors.red.shade100),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleAction(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue, // ✅ CHANGED TO BLUE
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Accept Request"),
                      ),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }
}