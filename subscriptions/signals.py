import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

# ✅ FIXED: Only import what belongs to this app
from subscriptions.models import UserSubscription, SubscriptionPlan

# Logger prevents the server from crashing on errors
logger = logging.getLogger(__name__)

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def assign_free_trial(sender, instance, created, **kwargs):
    """
    Safely assigns a 30-day Free Trial to new users.
    """
    if created:
        try:
            # 1. Ensure 'Free Trial' plan exists (Safe get_or_create)
            trial_plan, _ = SubscriptionPlan.objects.get_or_create(
                name="Free Trial",
                defaults={
                    'description': "First month free access.",
                    'price': 0.00,
                    'duration_days': 30,
                    'target_role': 'all'
                }
            )

            # 2. Prevent duplicates (Don't crash if they already have one)
            if UserSubscription.objects.filter(user=instance).exists():
                return

            # 3. Create Subscription
            UserSubscription.objects.create(
                user=instance,
                plan=trial_plan,
                start_date=timezone.now(),
                end_date=timezone.now() + timedelta(days=30),
                is_active=True
            )
            print(f"✅ Subscriptions: Assigned Free Trial to {instance.username}")

        except Exception as e:
            # 🛑 Catch error so Admin Delete/Create DOES NOT CRASH
            print(f"⚠️ Signal Warning: {e}")
            logger.error(f"Subscription signal error: {e}")