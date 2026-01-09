import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ishare_app/l10n/app_localizations.dart';

import '../../constants/app_theme.dart';
import '../../services/api_service.dart';
import '../../models/subscription_model.dart';

// Provider for subscription status
final subscriptionProvider = FutureProvider<SubscriptionModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final data = await apiService.getSubscriptionStatus();
  return SubscriptionModel.fromJson(data);
});

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionAsync = ref.read(subscriptionProvider);

    if (!_phoneController.text.trim().isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterPhoneError)),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final subscription = await subscriptionAsync.value;
      
      await apiService.processSubscriptionPayment(
        phoneNumber: _phoneController.text.trim(),
        paymentMethod: 'mobile_money',
      );

      // Refresh subscription status
      ref.invalidate(subscriptionProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Subscription activated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final subscriptionAsync = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: AppTheme.surfaceGrey,
      appBar: AppBar(
        title: Text(l10n.subscriptionTitle),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: subscriptionAsync.when(
        data: (subscription) => _buildSubscriptionContent(subscription, l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading subscription: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(subscriptionProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionContent(SubscriptionModel subscription, AppLocalizations l10n) {
    final isTrial = subscription.isTrial;
    final isExpired = subscription.isExpired;
    final price = subscription.subscriptionPrice.toInt();
    final daysRemaining = subscription.daysRemaining;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    isExpired ? Icons.error_outline : (isTrial ? Icons.access_time : Icons.check_circle),
                    size: 64,
                    color: isExpired ? Colors.red : (isTrial ? Colors.orange : Colors.green),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isExpired 
                        ? l10n.subscriptionExpired
                        : (isTrial ? l10n.trialPeriod : l10n.activeSubscription),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (isTrial)
                    Text(
                      l10n.daysRemaining(daysRemaining),
                      style: TextStyle(
                        fontSize: 18,
                        color: daysRemaining <= 7 ? Colors.red : Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (isExpired)
                    Text(
                      l10n.pleaseRenewSubscription,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Pricing Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.subscriptionPlans,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    l10n.passengerLabel,
                    '5,000 RWF',
                    l10n.perMonth,
                    subscription.userRole == 'passenger',
                  ),
                  const SizedBox(height: 12),
                  _buildPlanCard(
                    l10n.driverLabel,
                    '10,000 RWF',
                    l10n.perMonth,
                    subscription.userRole == 'driver',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payment Section (if expired or trial ending soon)
          if (isExpired || (isTrial && daysRemaining <= 7))
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isExpired ? l10n.renewSubscription : l10n.subscribeNow,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: l10n.phoneNumber,
                        hintText: l10n.phoneHint,
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              l10n.payAmount(price.toStringAsFixed(0)),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.paymentPhoneNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '+250 785 701 277',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.paymentInstructions,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[700], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Trial Info
          if (isTrial && daysRemaining > 7)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.trialEndsIn(daysRemaining),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String period, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.primaryBlue : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
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
              Text(
                period,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
