import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../models/booking_model.dart';
import 'rating_dialog.dart'; 
import 'home/payment_screen.dart' as payment;

class TicketScreen extends StatelessWidget {
  final BookingModel booking;

  const TicketScreen({super.key, required this.booking});

  // Helper: Call Driver
  Future<void> _callDriver(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  // Helper: Share Ride Details via WhatsApp
  Future<void> _shareRide(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final trip = booking.trip!;
    
    // Construct message using localized string with placeholders
    final String message = l10n.shareMessage(
      trip.driver.displayName.isNotEmpty ? trip.driver.displayName : trip.driver.username,
      "${trip.carName ?? 'Car'} (${trip.driver.phoneNumber ?? 'No Plate'})",
      trip.startLocationName,
      trip.destinationName
    );

    Uri url;
    if (kIsWeb) {
      // Web: Open WhatsApp Web
      url = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");
    } else {
      // Mobile: Open App
      url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to SMS on mobile if WhatsApp isn't installed
        if (!kIsWeb) {
          final Uri smsUrl = Uri.parse("sms:?body=${Uri.encodeComponent(message)}");
          if (await canLaunchUrl(smsUrl)) {
            await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Could not launch WhatsApp")),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Error sharing ride: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Safety Check: If trip details are missing
    if (booking.trip == null) {
      return Scaffold(
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
        body: Center(child: Text(l10n.tripUnavailable))
      );
    }
    
    final trip = booking.trip!; 
    final String driverName = trip.driver.displayName.isNotEmpty 
        ? trip.driver.displayName 
        : trip.driver.username;
    final String? driverPhone = trip.driver.phoneNumber; 

    // Date Formatting with Locale support
    String formattedDate;
    try {
      final localeCode = Localizations.localeOf(context).languageCode;
      formattedDate = DateFormat('MMM d, yyyy • HH:mm', localeCode).format(trip.departureTime);
    } catch (e) {
      formattedDate = DateFormat('MMM d, yyyy • HH:mm', 'en').format(trip.departureTime);
    }

    // --- DYNAMIC STATUS LOGIC ---
    Color statusColor;
    String statusText;
    IconData statusIcon;

    // Normalize status string to handle case sensitivity
    final status = booking.status.toLowerCase();

    if (status == 'confirmed' || status == 'paid') {
      statusColor = Colors.green;
      statusText = "CONFIRMED";
      statusIcon = Icons.check_circle;
    } else if (status == 'approved') {
      statusColor = AppTheme.primaryBlue;
      statusText = "APPROVED - PAY NOW";
      statusIcon = Icons.payment;
    } else if (status == 'pending') {
      statusColor = Colors.orange;
      statusText = "WAITING FOR DRIVER";
      statusIcon = Icons.hourglass_top;
    } else {
      statusColor = Colors.red;
      statusText = booking.status.toUpperCase();
      statusIcon = Icons.cancel;
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        title: Text(l10n.myTicket, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppTheme.textDark),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // --- TICKET CARD ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                children: [
                  // 1. DYNAMIC HEADER
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(statusIcon, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                  
                  // 2. QR CODE SECTION
                  Container(
                    width: double.infinity,
                    color: Colors.grey[50],
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        QrImageView(
                          data: "BOOKING-${booking.id}", // Unique data for QR
                          version: QrVersions.auto,
                          size: 180.0,
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppTheme.textDark,
                          ),
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${l10n.bookingId}: #${booking.id}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),

                  // 3. TEAR-OFF LINE VISUAL
                  _buildTearOffLine(),

                  // 4. DETAILS SECTION
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Route: From -> To
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.from, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(trip.startLocationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_forward, color: AppTheme.primaryBlue),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(l10n.to, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                  Text(trip.destinationName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),

                        // Trip Info Rows
                        _buildInfoRow(Icons.calendar_month, l10n.dateLabel, formattedDate),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.directions_car, l10n.vehicle, trip.carName ?? "Car details hidden"),
                        const SizedBox(height: 16),
                        _buildInfoRow(Icons.event_seat, l10n.seats, "${booking.seatsBooked} ${l10n.bookedStatus}"),

                        const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),

                        // Driver Info & Actions
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.surfaceGrey,
                              child: Text(
                                driverName.isNotEmpty ? driverName[0].toUpperCase() : '?', 
                                style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(l10n.driverLabel, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(driverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            
                            // Share Button
                            IconButton(
                              onPressed: () => _shareRide(context), 
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.share_rounded, color: Colors.blue, size: 20),
                              ),
                              tooltip: l10n.shareRide,
                            ),

                            // Call Button
                            IconButton(
                              onPressed: () => _callDriver(driverPhone), 
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.phone, color: Colors.green, size: 20),
                              ),
                            ),
                          ],
                        ),

                        // --- ACTION AREA (Pay Now or Waiting) ---
                        const SizedBox(height: 24),
                        if (status == 'approved') 
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                // Navigate to Payment
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => payment.PaymentScreen(
                                      totalAmount: (booking.trip!.pricePerSeat * booking.seatsBooked),
                                      bookingId: booking.id!,
                                    ),
                                  ),
                                );
                                // If payment was successful, result might be true. 
                                // You could trigger a refresh here if you wrap this in a Stateful Widget.
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.payment, color: Colors.white),
                              label: const Text("PAY NOW TO CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          )
                        else if (status == 'pending')
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withOpacity(0.3))
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.orange),
                                const SizedBox(width: 12),
                                const Expanded(child: Text("Waiting for driver approval...", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Rate Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => RateDriverDialog(trip: trip),
                  );
                },
                icon: const Icon(Icons.star_outline_rounded),
                label: const Text("Rate Driver"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Instruction Footer
            Text(
              l10n.ticketInstruction,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Info Rows
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  // Helper Widget for the "Tear-off" zig-zag line
  Widget _buildTearOffLine() {
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(width: 12, height: 24, decoration: const BoxDecoration(color: AppTheme.surfaceGrey, borderRadius: BorderRadius.horizontal(right: Radius.circular(12)))),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Flex(
                      direction: Axis.horizontal,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: List.generate(
                        (constraints.constrainWidth() / 10).floor(),
                        (index) => SizedBox(width: 5, height: 1, child: DecoratedBox(decoration: BoxDecoration(color: Colors.grey[300]))),
                      ),
                    );
                  },
                ),
              ),
              Container(width: 12, height: 24, decoration: const BoxDecoration(color: AppTheme.surfaceGrey, borderRadius: BorderRadius.horizontal(left: Radius.circular(12)))),
            ],
          ),
        ],
      ),
    );
  }
}