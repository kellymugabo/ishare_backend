import logging
from django.db.models.signals import post_save
from django.dispatch import receiver
from django.conf import settings
from .models import UserProfile

logger = logging.getLogger(__name__)

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        try:
            # ✅ Use get_or_create to check existence before creating
            if not UserProfile.objects.filter(user=instance).exists():
                UserProfile.objects.create(user=instance, role='passenger')
                print(f"✅ Core: Profile created for {instance.username}")
        except Exception as e:
            # 🛑 Log error but DO NOT CRASH the server
            print(f"⚠️ Core Signal Warning: {e}")
            logger.error(f"Profile creation error: {e}")

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def save_user_profile(sender, instance, **kwargs):
    try:
        if hasattr(instance, 'profile'):
            instance.profile.save()
    except Exception:
        # If profile doesn't exist during delete, ignore it
        pass