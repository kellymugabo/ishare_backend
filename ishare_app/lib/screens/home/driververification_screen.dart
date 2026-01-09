import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../services/api_service.dart';
import '../../constants/app_theme.dart';

class DriverVerificationScreen extends ConsumerStatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  ConsumerState<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState
    extends ConsumerState<DriverVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isCheckingStatus = true;
  bool _termsAccepted = false;
  String? _verificationStatus; // 'approved', 'pending', or null (no verification)

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final statusData = await apiService.checkDriverVerification();
      
      // Debug: Print the actual response
      debugPrint('🔍 Verification Status Response: $statusData');
      debugPrint('   - is_verified: ${statusData['is_verified']} (type: ${statusData['is_verified'].runtimeType})');
      debugPrint('   - status: ${statusData['status']} (type: ${statusData['status'].runtimeType})');
      
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
          
          // Check status string first (most reliable)
          final statusStr = statusData['status']?.toString().toLowerCase();
          if (statusStr == 'approved') {
            _verificationStatus = 'approved';
            debugPrint('✅ Status set to APPROVED based on status field');
          } else if (statusStr == 'pending') {
            _verificationStatus = 'pending';
            debugPrint('⚠️ Status set to PENDING based on status field');
          } else if (statusData['is_verified'] == true || statusData['is_verified'] == 'true') {
            // Fallback to is_verified flag
            _verificationStatus = 'approved';
            debugPrint('✅ Status set to APPROVED based on is_verified flag');
          } else if (statusData['has_pending'] == true || statusData['has_pending'] == 'true') {
            _verificationStatus = 'pending';
            debugPrint('⚠️ Status set to PENDING based on has_pending flag');
          } else {
            _verificationStatus = null; // No verification exists
            debugPrint('ℹ️ Status set to null (no verification)');
          }
        });
      }
    } catch (e) {
      debugPrint('❌ Error checking verification status: $e');
      if (mounted) {
        setState(() {
          _isCheckingStatus = false;
          _verificationStatus = null; // Assume no verification if error
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        title: Text(
          l10n.driverVerificationTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: AppTheme.surfaceGrey,
        foregroundColor: AppTheme.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isCheckingStatus
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Header Banner
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryDark,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                            ),
                            child: Icon(
                              _verificationStatus == 'approved'
                                  ? Icons.verified_user
                                  : _verificationStatus == 'pending'
                                      ? Icons.pending_actions
                                      : Icons.verified_user,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            _verificationStatus == 'approved'
                                ? 'Verification Approved!'
                                : _verificationStatus == 'pending'
                                    ? 'Verification Pending'
                                    : l10n.verifyIdentityTitle,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _verificationStatus == 'approved'
                                ? 'Your driver verification has been approved. You can now publish rides.'
                                : _verificationStatus == 'pending'
                                    ? 'Your verification request is being reviewed. Please wait for approval.'
                                    : l10n.verifyIdentitySubtitle,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content based on status
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: _verificationStatus == 'approved'
                        ? _buildApprovedView(l10n)
                        : _verificationStatus == 'pending'
                            ? _buildPendingView(l10n)
                            : _buildVerificationForm(l10n),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildApprovedView(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Approved!',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'You are now verified as a driver. You can publish rides and start offering transportation services.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Go Back', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingView(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pending_actions, color: Colors.orange, size: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Verification Under Review',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your verification request has been submitted and is currently being reviewed by our team. You will be notified once the review is complete.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textGrey,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go Back', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isCheckingStatus = true;
                    });
                    _checkVerificationStatus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Refresh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationForm(AppLocalizations l10n) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Why Verification Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.softBlue,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppTheme.primaryBlue, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.whyVerification,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.verificationDesc,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textGrey, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Full Name
          _buildLabel(l10n.fullName),
          _buildTextField(
            controller: _fullNameController,
            hint: l10n.fullNameHint,
            icon: Icons.person_outline,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.enterFullName;
              if (value.trim().split(' ').length < 2) return l10n.enterTwoNames;
              return null;
            },
          ),

          const SizedBox(height: 20),

          // National ID
          _buildLabel(l10n.nationalIdLabel),
          _buildTextField(
            controller: _nationalIdController,
            hint: '1 19XX 8 XXXXXXX X XX',
            icon: Icons.badge_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
              LengthLimitingTextInputFormatter(20),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.enterNationalId;
              final cleanId = value.replaceAll(' ', '');
              if (cleanId.length != 16) return l10n.invalidIdLength;
              return null;
            },
          ),

          const SizedBox(height: 20),

          // Phone Number
          _buildLabel(l10n.phoneNumber),
          _buildTextField(
            controller: _phoneController,
            hint: '078X XXX XXX',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            prefixText: '+250 ',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) return l10n.enterPhoneNumber;
              if (value.length != 9) return l10n.invalidPhone;
              return null;
            },
          ),

          const SizedBox(height: 32),

          // Terms Checkbox
          InkWell(
            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _termsAccepted ? AppTheme.primaryBlue : Colors.grey[300]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _termsAccepted ? Icons.check_circle : Icons.circle_outlined,
                    color: _termsAccepted ? AppTheme.primaryBlue : Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: AppTheme.textDark),
                        children: [
                          TextSpan(text: l10n.iAgreeTo),
                          TextSpan(
                            text: l10n.termsAndConditions,
                            style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading || !_termsAccepted ? null : _submitVerification,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: _termsAccepted ? 4 : 0,
              ),
              child: _isLoading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                  : Text(
                      l10n.submitVerification,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required TextInputType keyboardType,
    String? prefixText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    required String? Function(String?) validator,
  }) {
    return Container(
      decoration: AppTheme.inputDecoration, // ✅ Now valid
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixText: prefixText,
          prefixStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textDark),
          prefixIcon: Icon(icon, color: AppTheme.primaryBlue),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: validator,
      ),
    );
  }

  Future<void> _submitVerification() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    // Double-check status before submitting to prevent duplicate submissions
    try {
      final apiService = ref.read(apiServiceProvider);
      final statusData = await apiService.checkDriverVerification();
      
      if (statusData['is_verified'] == true) {
        if (mounted) {
          setState(() => _verificationStatus = 'approved');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are already verified!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return;
      }
      
      if (statusData['status'] == 'pending' || statusData['has_pending'] == true) {
        if (mounted) {
          setState(() => _verificationStatus = 'pending');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already have a pending verification request. Please wait for review.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // If status check fails, continue with submission (backend will validate)
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final verificationData = {
        'full_name': _fullNameController.text.trim(),
        'national_id': _nationalIdController.text.replaceAll(' ', ''),
        'phone_number': '+250${_phoneController.text}',
      };

      await apiService.submitDriverVerification(verificationData);

      if (mounted) {
        // Update status to pending after successful submission
        setState(() => _verificationStatus = 'pending');
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 64),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.verificationSubmitted,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.verificationReviewMsg,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textGrey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(l10n.done),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to submit verification';
        
        // Check if it's the "already have pending" error
        if (e.toString().contains('already have') || e.toString().contains('pending')) {
          errorMessage = 'You already have a pending verification request. Please wait for review.';
          setState(() => _verificationStatus = 'pending');
        } else if (e.toString().contains('approved') || e.toString().contains('verified')) {
          errorMessage = 'You are already verified!';
          setState(() => _verificationStatus = 'approved');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        
        // Refresh status after error to update UI
        _checkVerificationStatus();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}