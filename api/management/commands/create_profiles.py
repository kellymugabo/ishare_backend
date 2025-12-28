from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from api.models import UserProfile

class Command(BaseCommand):
    help = 'Create UserProfile for all users who dont have one'

    def handle(self, *args, **kwargs):
        for user in User.objects.all():
            profile, created = UserProfile.objects.get_or_create(user=user)
            if created:
                self.stdout.write(
                    self.style.SUCCESS(f'Created profile for {user.username}')
                )
        
        self.stdout.write(self.style.SUCCESS('Done!'))