from django.db import migrations
from django.contrib.auth import get_user_model
import os

def create_superuser(apps, schema_editor):
    User = get_user_model()
    # Change these credentials to whatever you want
    USERNAME = 'admin'
    EMAIL = 'murenzicharles24@gmail.com'
    PASSWORD = 'Kadasarika10!' 

    if not User.objects.filter(username=USERNAME).exists():
        print(f"Creating superuser: {USERNAME}")
        User.objects.create_superuser(USERNAME, EMAIL, PASSWORD)
        print("Superuser created successfully!")
    else:
        print("Superuser already exists.")

class Migration(migrations.Migration):

    dependencies = [
        # This relies on the previous migration. 
        # Ensure 'core' matches your app name and the dependency is correct.
        ('core', '0002_alter_trip_options_and_more'), 
    ]

    operations = [
        migrations.RunPython(create_superuser),
    ]
