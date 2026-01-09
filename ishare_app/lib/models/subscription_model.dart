// lib/models/subscription_model.dart

class SubscriptionModel {
  final int id;
  final int userId;
  final String username;
  final String userRole;
  final String status; // 'trial', 'active', 'expired', 'cancelled'
  final DateTime? trialStartedAt;
  final DateTime? trialEndsAt;
  final DateTime? subscriptionStartedAt;
  final DateTime? subscriptionEndsAt;
  final double amountPaid;
  final String? paymentMethod;
  final String? paymentTransactionId;
  final DateTime? lastPaymentDate;
  final bool isActive;
  final int daysRemaining;
  final double subscriptionPrice;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userRole,
    required this.status,
    this.trialStartedAt,
    this.trialEndsAt,
    this.subscriptionStartedAt,
    this.subscriptionEndsAt,
    this.amountPaid = 0,
    this.paymentMethod,
    this.paymentTransactionId,
    this.lastPaymentDate,
    required this.isActive,
    required this.daysRemaining,
    required this.subscriptionPrice,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      userRole: json['user_role'] as String? ?? 'passenger',
      status: json['status'] as String,
      trialStartedAt: json['trial_started_at'] != null
          ? DateTime.parse(json['trial_started_at'])
          : null,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      subscriptionStartedAt: json['subscription_started_at'] != null
          ? DateTime.parse(json['subscription_started_at'])
          : null,
      subscriptionEndsAt: json['subscription_ends_at'] != null
          ? DateTime.parse(json['subscription_ends_at'])
          : null,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0,
      paymentMethod: json['payment_method'] as String?,
      paymentTransactionId: json['payment_transaction_id'] as String?,
      lastPaymentDate: json['last_payment_date'] != null
          ? DateTime.parse(json['last_payment_date'])
          : null,
      isActive: json['is_active'] as bool? ?? false,
      daysRemaining: json['days_remaining'] as int? ?? 0,
      subscriptionPrice: (json['subscription_price'] as num?)?.toDouble() ?? 5000,
    );
  }

  bool get isTrial => status == 'trial';
  bool get isPaid => status == 'active';
  bool get isExpired => status == 'expired' || !isActive;

  String get statusDisplay {
    switch (status) {
      case 'trial':
        return 'Trial';
      case 'active':
        return 'Active';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
