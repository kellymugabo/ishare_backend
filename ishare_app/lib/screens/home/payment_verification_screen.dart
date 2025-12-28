import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// 🌍 LOCALIZATION IMPORT
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../constants/app_theme.dart'; // ✅ Using shared theme
import 'create_trips_screen.dart';

// =====================================================
// API SERVICE FOR PAYMENT VERIFICATION
// =====================================================
class PaymentVerificationService {
  static const String baseUrl = 'YOUR_BACKEND_URL'; // Replace with your backend URL
  
  // Verify user identity and process payment
  static Future<Map<String, dynamic>> verifyAndPay({
    required String fullName,
    required String nationalId,
    required String phoneNumber,
    String? userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/verify'),
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'full_name': fullName,
          'national_id': nationalId,
          'phone_number': phoneNumber,
          'user_id': userId,
          'payment_method': 'mobile_money',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Verification failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Server error: ${e.toString()}',
      };
    }
  }

  // Check verification status
  static Future<Map<String, dynamic>> checkVerificationStatus(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/payment/status/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to check status',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

// =====================================================
// VERIFICATION SCREEN
// =====================================================
class VerificationScreen extends ConsumerStatefulWidget {
  final String? userId; // Pass user ID from previous screen
  
  const VerificationScreen({
    super.key,
    this.userId,
  });

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isProcessing = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enterFullName; // "Enter your full name"
    }
    if (value.trim().split(' ').length < 2) {
      return l10n.enterTwoNames; // "Enter at least two names"
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return l10n.invalidNameChars; // "Names must contain letters only"
    }
    return null;
  }

  String? _validateNationalId(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enterNationalId; // "Enter your National ID"
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    if (cleaned.length != 16) {
      return l10n.invalidIdLength; // "National ID must be 16 digits"
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(cleaned)) {
      return l10n.invalidIdChars; // "ID must contain numbers only"
    }
    return null;
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) {
      return l10n.enterPhoneNumber; // "Enter your phone number"
    }
    final cleaned = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (!RegExp(r'^(\+?250|0)?7[2-9][0-9]{7}$').hasMatch(cleaned)) {
      return l10n.invalidPhone; // "Enter a valid Rwanda number"
    }
    return null;
  }

  Future<void> _processPayment() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      _showSnackBar(l10n.acceptTerms, Colors.orange); // "Accept terms before continuing"
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // Clean phone number for backend
      String cleanedPhone = _phoneController.text.replaceAll(RegExp(r'[\s-]'), '');
      if (!cleanedPhone.startsWith('+')) {
        cleanedPhone = cleanedPhone.startsWith('0') 
            ? '+250${cleanedPhone.substring(1)}' 
            : '+250$cleanedPhone';
      }

      // Call backend API
      final result = await PaymentVerificationService.verifyAndPay(
        fullName: _fullNameController.text.trim(),
        nationalId: _nationalIdController.text.replaceAll(RegExp(r'[\s-]'), ''),
        phoneNumber: cleanedPhone,
        userId: widget.userId,
      );

      if (!mounted) return;

      if (result['success'] == true) {
        _showSuccessDialog(result['data'], l10n);
      } else {
        _showSnackBar(
          result['error'] ?? l10n.paymentFailed, // "Payment failed"
          Colors.red,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(Map<String, dynamic>? data, AppLocalizations l10n) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green[100], shape: BoxShape.circle),
                child: Icon(Icons.check_circle, size: 48, color: Colors.green[700]),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.verificationSuccess, // "Verification Successful!"
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.verificationSuccessMsg, // "Your identity has been verified..."
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700]),
              ),
              if (data != null && data['verification_id'] != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    children: [
                      Text(l10n.transactionId, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Text(
                        data['verification_id'].toString(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateTripScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(l10n.continueText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.verifyIdentity, style: const TextStyle(fontWeight: FontWeight.bold)), // "Verify Identity"
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue,
                        AppTheme.primaryBlue.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.verified_user, size: 48, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.verifyIdentityTitle, // "Confirm Your Identity"
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.verifyIdentitySubtitle, // "We need to verify..."
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Full Name
                Text(l10n.fullName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _fullNameController,
                  validator: (val) => _validateFullName(val, l10n),
                  decoration: InputDecoration(
                    hintText: l10n.fullNameHint,
                    prefixIcon: const Icon(Icons.person, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                  ),
                  textCapitalization: TextCapitalization.words,
                  keyboardType: TextInputType.name,
                ),

                const SizedBox(height: 24),

                // National ID
                Text(l10n.nationalIdLabel, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nationalIdController,
                  validator: (val) => _validateNationalId(val, l10n),
                  decoration: InputDecoration(
                    hintText: '1 19XX 8 XXXXXXX X XX',
                    prefixIcon: const Icon(Icons.badge, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                    helperText: l10n.idHelperText, // "16 digits (e.g., ...)"
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
                ),

                const SizedBox(height: 24),

                // Phone
                Text(l10n.phoneNumber, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _phoneController,
                  validator: (val) => _validatePhone(val, l10n),
                  decoration: InputDecoration(
                    hintText: '0788 123 456',
                    prefixIcon: const Icon(Icons.phone, color: AppTheme.primaryBlue),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2)),
                    helperText: 'MTN, Airtel',
                  ),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
                ),

                const SizedBox(height: 24),

                // Info Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.softBlue, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3))),
                  child: Row(
                    children: [
                      const Icon(Icons.mobile_friendly, color: AppTheme.primaryBlue, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(l10n.paymentMethodsAccepted, style: const TextStyle(color: AppTheme.deepBlue, fontSize: 14, fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Terms Checkbox
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
                        activeColor: AppTheme.primaryBlue,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(color: Colors.grey[800], fontSize: 14),
                                children: [
                                  TextSpan(text: l10n.iAgreeTo), // "I agree to "
                                  TextSpan(text: l10n.termsAndConditions, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                  TextSpan(text: l10n.and), // " and "
                                  TextSpan(text: l10n.privacyPolicy, style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                  child: _isProcessing
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 12),
                            Text(l10n.confirmAndContinue, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),

                const SizedBox(height: 16),

                // Security Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.grey[600], size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.secureInfoMsg, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}