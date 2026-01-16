import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

# ✅ CORRECT IMPORTS (This fixes the crash)
from subscriptions.models import UserSubscription, SubscriptionPlan
from core.models import UserProfile  # <-- IMPORT FROM CORE, NOT .models

# Setup logger to see errors in Railway logs without crashing
logger = logging.getLogger(__name__)

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def assign_free_trial(sender, instance, created, **kwargs):
    """
    Safely assigns a 30-day Free Trial to every new user.
    Catches errors so the Admin Panel doesn't crash.
    """
    if created:
        try:
            # 1. Ensure the 'Free Trial' plan exists
            # We add 'target_role' because it is required by your model now
            trial_plan, _ = SubscriptionPlan.objects.get_or_create(
                name="Free Trial",
                defaults={
                    'description': "First month free access to all features.",
                    'price': 0.00,
                    'duration_days': 30,
                    'target_role': 'all' 
                }
            )

            # 2. Ensure the 'Monthly Premium' plan exists (for later)
            SubscriptionPlan.objects.get_or_create(
                name="Monthly Premium",
                defaults={
                    'description': "Unlimited access to ride requests.",
                    'price': 5000.00,
                    'duration_days': 30,
                    'target_role': 'driver'
                }
            )

            # 3. Check if subscription already exists (prevent duplicates)
            if UserSubscription.objects.filter(user=instance).exists():
                return

            # 4. Assign the Free Trial
            end_date = timezone.now() + timedelta(days=30)
            
            UserSubscription.objects.create(
                user=instance,
                plan=trial_plan,
                start_date=timezone.now(),
                end_date=end_date,
                is_active=True
            )
            print(f"✅ SUCCESS: Assigned Free Trial to {instance.username}")

        except Exception as e:
            # 🛑 THIS CATCHES THE ERROR SO ADMIN PANEL DOESN'T CRASH 500
            print(f"⚠️ SIGNAL WARNING: Could not assign subscription: {str(e)}")
            logger.error(f"Signal Error for user {instance.id}: {e}")