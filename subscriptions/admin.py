from django.contrib import admin
from django.utils import timezone
from datetime import timedelta
from .models import SubscriptionPlan, UserSubscription, SubscriptionTransaction

@admin.register(SubscriptionPlan)
class SubscriptionPlanAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'duration_days', 'target_role')

@admin.register(UserSubscription)
class UserSubscriptionAdmin(admin.ModelAdmin):
    list_display = ('user', 'plan', 'is_active', 'end_date')

@admin.register(SubscriptionTransaction)
class SubscriptionTransactionAdmin(admin.ModelAdmin):
    list_display = ('user', 'plan', 'amount', 'transaction_id', 'status', 'created_at')
    list_filter = ('status', 'created_at')
    actions = ['approve_payment', 'reject_payment']

    def approve_payment(self, request, queryset):
        for trans in queryset:
            if trans.status != 'pending':
                continue # Skip if already processed

            # 1. Update Transaction Status
            trans.status = 'approved'
            trans.save()

            # 2. ACTIVATE THE SUBSCRIPTION (Crash-Proof Logic)
            # Calculate dates first
            new_start_date = timezone.now()
            new_end_date = timezone.now() + timedelta(days=trans.plan.duration_days)

            # Use update_or_create to handle both "New" and "Renewal" safely
            UserSubscription.objects.update_or_create(
                user=trans.user,
                defaults={
                    'plan': trans.plan,
                    'start_date': new_start_date,
                    'end_date': new_end_date,
                    'is_active': True
                }
            )

        self.message_user(request, "Selected payments approved & subscriptions activated!")
    
    approve_payment.short_description = "✅ Approve Payment & Activate Subscription"

    def reject_payment(self, request, queryset):
        queryset.update(status='rejected')
    reject_payment.short_description = "❌ Reject Payment"