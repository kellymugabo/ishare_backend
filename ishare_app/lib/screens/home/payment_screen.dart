import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; 
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

// Payment Method Enum
enum PaymentMethod {
  mobileMoney,
  card,
  bankTransfer,
}

class PaymentScreen extends ConsumerStatefulWidget {
  final double totalAmount;
  final int bookingId;

  const PaymentScreen({
    super.key, 
    required this.totalAmount,
    required this.bookingId,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  PaymentMethod _selectedMethod = PaymentMethod.mobileMoney;
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  // 🛠 HELPER: Format Currency for RWF (e.g., 5000 -> 5,000)
  String formatRWF(double amount) {
    int value = amount.toInt();
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
  }

  // 🔄 MAIN PAYMENT HANDLER
  Future<void> _initiatePayment() async {
    final l10n = AppLocalizations.of(context)!;

    // Validate phone number only if Mobile Money is selected
    if (_selectedMethod == PaymentMethod.mobileMoney) {
       if (!_formKey.currentState!.validate()) {
         return;
       }
    }

    try {
      switch (_selectedMethod) {
        case PaymentMethod.mobileMoney:
          await _processMobileMoneyPayment(l10n);
          break;
        case PaymentMethod.card:
          setState(() => _isProcessing = true);
          await _processCardPayment(l10n);
          break;
        case PaymentMethod.bankTransfer:
          setState(() => _isProcessing = true);
          await _processBankTransfer(l10n);
          break;
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        String serverMessage = "";
        
        if (e.response != null && e.response?.data != null) {
          final data = e.response!.data;
          if (data is Map) {
             serverMessage = data['message'] ?? data['error'] ?? "";
          }
        }

        if (serverMessage.contains("Payment already exists")) {
          _showPaymentAlreadyExistsDialog(l10n);
        } else if (serverMessage.contains("You cannot book your own trip")) {
          _showPaymentError(l10n, "You cannot book your own trip.");
        } else {
          _showPaymentError(l10n, serverMessage.isNotEmpty ? serverMessage : e.message ?? "Unknown Error");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showPaymentError(l10n, e.toString());
      }
    } finally {
      // Safety check to ensure loader is off if method didn't handle it
      if (mounted && _selectedMethod != PaymentMethod.mobileMoney) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // --- 1. MOBILE MONEY LOGIC (MANUAL PAY TO DRIVER) ---
  Future<void> _processMobileMoneyPayment(AppLocalizations l10n) async {
    setState(() => _isProcessing = true);
    
    final apiService = ref.read(apiServiceProvider);

    try {
      // 1. Fetch Booking Details to find Driver's Phone Number
      final bookings = await apiService.fetchMyBookings();
      
      final currentBooking = bookings.firstWhere(
        (b) => b.id == widget.bookingId,
        orElse: () => throw Exception("Booking not found"),
      );
      
      // Extract Driver's Phone from the Trip model
      final driverPhone = currentBooking.trip?.driverPhone ?? "07XX XXX XXX";

      // Stop loading so we can show the dialog
      if (mounted) setState(() => _isProcessing = false);

      // 2. Show the "Pay to Driver" Dialog
      final userConfirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.phone_android, color: AppTheme.primaryBlue),
              SizedBox(width: 10),
              Text("Pay to Driver", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Please send mobile money to this number:"),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    SelectableText( // Allows user to copy the number
                      driverPhone, 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppTheme.primaryBlue)
                    ),
                    const SizedBox(height: 5),
                    const Text("Driver's Number", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // --- UPDATED: RWF DISPLAY ---
              Text(
                "Amount: ${formatRWF(widget.totalAmount)} RWF", 
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
              ),
              
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "1. Dial *182# or use your SIM Toolkit.\n2. Send the exact amount to the number above.\n3. Come back here and click 'I have Paid'.",
                style: TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textDark),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // Cancel
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), // Confirm
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, 
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text("I have Paid"),
            ),
          ],
        ),
      );

      // 3. If User Confirms, Tell Backend to Confirm Ticket
      if (userConfirmed == true) {
        if (mounted) setState(() => _isProcessing = true);
        
        final response = await apiService.simulatePayment(
          bookingId: widget.bookingId,
          amount: widget.totalAmount,
          phoneNumber: _phoneController.text, // Just for record keeping
        );

        final transactionId = response['transaction_id'] ?? "MANUAL-CONFIRM";
        
        if (mounted) {
           _showPaymentSuccess(l10n, transactionId);
        }
      }

    } catch (e) {
      if (mounted) _showPaymentError(l10n, e.toString());
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _processCardPayment(AppLocalizations l10n) async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.cardPayment),
          content: Text(l10n.cardPaymentComingSoon),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))],
        ),
      );
    }
  }

  Future<void> _processBankTransfer(AppLocalizations l10n) async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.bankTransfer),
          content: Text(l10n.bankTransferDetails),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok))],
        ),
      );
    }
  }

  void _showPaymentSuccess(AppLocalizations l10n, String transactionId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text("Payment Confirmed!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Your booking has been confirmed.", style: TextStyle(fontSize: 15)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${l10n.transactionId}: $transactionId", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  
                  // --- UPDATED: RWF DISPLAY ---
                  Text(
                    "${l10n.amount}: ${formatRWF(widget.totalAmount)} RWF", 
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark)
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return 'true' to go to My Trips
            },
            child: Text(l10n.done, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentAlreadyExistsDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.paymentAlreadyPaidTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.paymentAlreadyPaidMsg,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return 'true' to go to My Trips
            },
            child: Text(l10n.viewTrips, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPaymentError(AppLocalizations l10n, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Text(l10n.paymentFailed),
          ],
        ),
        // Clean up any remaining "Exception:" text just in case
        content: Text(message.replaceAll("Exception:", "").trim()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  // --- 3. UI BUILD ---

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        title: Text(l10n.paymentTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Display
              Text(l10n.totalAmount, style: const TextStyle(fontSize: 16, color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              
              // --- UPDATED: RWF DISPLAY ---
              Text(
                "${formatRWF(widget.totalAmount)} RWF",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              
              const SizedBox(height: 32),

              // Payment Method Selection
              Text(
                l10n.selectPaymentMethod,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 16),

              _buildPaymentMethodOption(
                PaymentMethod.mobileMoney,
                l10n.mobileMoney,
                Icons.phone_android,
                l10n.mobileMoneySubtitle,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodOption(
                PaymentMethod.card,
                l10n.cardPayment,
                Icons.credit_card,
                l10n.cardSubtitle,
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodOption(
                PaymentMethod.bankTransfer,
                l10n.bankTransfer,
                Icons.account_balance,
                l10n.bankTransferSubtitle,
              ),
              const SizedBox(height: 24),

              // Phone Number Input (Only for Mobile Money)
              if (_selectedMethod == PaymentMethod.mobileMoney) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppTheme.textDark),
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    hintText: l10n.phoneHint,
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.enterPhoneError;
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.paymentPromptMsg,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                ),
                const SizedBox(height: 24),
              ],

              // Pay Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppTheme.primaryBlue.withOpacity(0.4),
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(
                          l10n.payNow,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodOption(PaymentMethod method, String title, IconData icon, String subtitle) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = method),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: isSelected ? AppTheme.primaryBlue : Colors.grey[400]),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryBlue),
          ],
        ),
      ),
    );
  }
}