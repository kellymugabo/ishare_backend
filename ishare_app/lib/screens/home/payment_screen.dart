import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; 
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../services/api_service.dart';

enum PaymentMethod {
  mobileMoney,
  card,
  bankTransfer,
}

class PaymentScreen extends ConsumerStatefulWidget {
  final double totalAmount;
  final int bookingId; // If -1, this is a SUBSCRIPTION payment.
  final int? planId;   // ✅ REQUIRED for Subscriptions

  const PaymentScreen({
    super.key, 
    required this.totalAmount,
    required this.bookingId,
    this.planId, 
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;
  PaymentMethod _selectedMethod = PaymentMethod.mobileMoney;
  
  // ✅ UPDATED: Setting your number as the default controller value
  final _phoneController = TextEditingController(text: "0793487065");
  final _transactionIdController = TextEditingController(); 
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  String formatRWF(double amount) {
    int value = amount.toInt();
    return value.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},'
    );
  }

  Future<void> _initiatePayment() async {
    final l10n = AppLocalizations.of(context)!;

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

        if (serverMessage.contains("Payment already exists") || serverMessage.contains("transaction ID")) {
          _showPaymentAlreadyExistsDialog(l10n);
        } else {
          _showPaymentError(l10n, serverMessage.isNotEmpty ? serverMessage : "Connection Error");
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _showPaymentError(l10n, e.toString());
      }
    } finally {
      if (mounted && _selectedMethod != PaymentMethod.mobileMoney) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _processMobileMoneyPayment(AppLocalizations l10n) async {
    final userConfirmed = await _showInstructionDialog();

    if (userConfirmed == true) {
      setState(() => _isProcessing = true);
      final apiService = ref.read(apiServiceProvider);

      try {
        if (widget.bookingId == -1) {
           if (widget.planId == null) throw Exception("Plan ID is missing");

           await apiService.submitSubscriptionPayment(
             widget.planId!, 
             _transactionIdController.text.trim()
           );

           if (mounted) {
             _showPaymentSuccess(l10n, _transactionIdController.text.trim());
           }
        } 
        else {
          final response = await apiService.simulatePayment(
            bookingId: widget.bookingId,
            amount: widget.totalAmount,
            phoneNumber: _phoneController.text,
          );

          final transactionId = response['transaction_id'] ?? "MANUAL-CONFIRM";
          
          if (mounted) {
              _showPaymentSuccess(l10n, transactionId);
          }
        }
      } catch (e) {
        rethrow;
      } finally {
        if (mounted) setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _showInstructionDialog() async {
    // ✅ UPDATED: Target phone for the user instructions
    String targetPhone = "0793487065"; 
    String titleText = "Pay to ISHARE";
    
    if (widget.bookingId != -1) {
       titleText = "Pay to Driver"; 
    }

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Dial *182#"),
            const SizedBox(height: 5),
            Text("2. Send ${formatRWF(widget.totalAmount)} RWF to:", style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 5),
            SelectableText(
              targetPhone,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
            ),
            const SizedBox(height: 15),
            const Text("3. Copy the Transaction ID (Ref) from SMS.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const Text("4. Paste it in the box on the previous screen.", style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("I have Paid"),
          ),
        ],
      ),
    );
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
            Text("Submitted!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          widget.bookingId == -1 
              ? "Your payment is under review. Your subscription will be active shortly."
              : "Your booking has been confirmed.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context, true); 
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  void _showPaymentAlreadyExistsDialog(AppLocalizations l10n) {
     showDialog(
       context: context,
       builder: (_) => AlertDialog(
         title: const Text("Duplicate Payment"),
         content: const Text("This Transaction ID has already been used."),
         actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("OK"))],
       )
     );
  }

  void _showPaymentError(AppLocalizations l10n, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(title: Text(l10n.paymentTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.totalAmount, style: const TextStyle(fontSize: 16, color: AppTheme.textGrey)),
              const SizedBox(height: 8),
              Text(
                "${formatRWF(widget.totalAmount)} RWF",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.primaryBlue),
              ),
              const SizedBox(height: 32),

              Text(l10n.selectPaymentMethod, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              _buildPaymentMethodOption(
                PaymentMethod.mobileMoney, 
                l10n.mobileMoney, 
                Icons.phone_android, 
                l10n.mobileMoneySubtitle
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodOption(
                PaymentMethod.card, 
                l10n.cardPayment, 
                Icons.credit_card, 
                l10n.cardSubtitle
              ),
              const SizedBox(height: 12),
              _buildPaymentMethodOption(
                PaymentMethod.bankTransfer, 
                l10n.bankTransfer, 
                Icons.account_balance, 
                l10n.bankTransferSubtitle
              ),

              const SizedBox(height: 24),

              if (_selectedMethod == PaymentMethod.mobileMoney) ...[
                TextFormField(
                  controller: _transactionIdController,
                  style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    labelText: "Transaction ID / Ref Number",
                    hintText: "e.g. 8842...",
                    prefixIcon: const Icon(Icons.receipt_long, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Please enter the Transaction ID from SMS";
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumber,
                    prefixIcon: const Icon(Icons.phone),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter your phone number for record keeping.",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _initiatePayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l10n.payNow, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppTheme.primaryBlue.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryBlue : Colors.grey, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppTheme.primaryBlue : Colors.black)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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