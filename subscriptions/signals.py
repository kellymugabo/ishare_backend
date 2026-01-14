from django.db.models.signals import post_save
from django.dispatch import receiver
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
from .models import UserSubscription, SubscriptionPlan

@receiver(post_save, sender=User)
def assign_free_trial(sender, instance, created, **kwargs):
    """
    Automatically gives a 30-day Free Trial to every new user.
    Also ensures the 'Monthly Premium' plan exists for later.
    """
    if created:
        # 1. Ensure the 'Free Trial' plan exists
        trial_plan, _ = SubscriptionPlan.objects.get_or_create(
            name="Free Trial",
            defaults={
                'description': "First month free access to all features.",
                'price': 0.00,
                'duration_days': 30,
                'is_active': True
            }
        )

        # 2. Ensure the 'Monthly Premium' plan exists (so they can pay later)
        SubscriptionPlan.objects.get_or_create(
            name="Monthly Premium",
            defaults={
                'description': "Unlimited access to ride requests.",
                'price': 5000.00,  # 5000 RWF
                'duration_days': 30,
                'is_active': True
            }
        )

        # 3. Assign the Free Trial to the new User
        UserSubscription.objects.create(
            user=instance,
            plan=trial_plan,
            start_date=timezone.now(),
            end_date=timezone.now() + timedelta(days=30),
            is_active=True
        )
        print(f"✅ Assigned 30-day Free Trial to {instance.username}")