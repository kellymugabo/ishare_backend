from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta

class SubscriptionPlan(models.Model):
    ROLE_CHOICES = [
        ('driver', 'Driver'),
        ('passenger', 'Passenger'),
        ('all', 'All Users'),
    ]

    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    duration_days = models.IntegerField()
    description = models.TextField(blank=True)
    
    target_role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default='all',
        help_text="Who can see this plan?"
    )
    
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.price} RWF"

class UserSubscription(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='driver_subscription'
    )
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.SET_NULL, null=True)
    start_date = models.DateTimeField(auto_now_add=True)
    end_date = models.DateTimeField()
    is_active = models.BooleanField(default=True)

    def save(self, *args, **kwargs):
        if not self.end_date and self.plan:
            self.end_date = timezone.now() + timedelta(days=self.plan.duration_days)
        super().save(*args, **kwargs)

    @property
    def is_valid(self):
        return self.is_active and self.end_date > timezone.now()

    def __str__(self):
        # ✅ FIX: Handle case where user is deleted or None
        username = "Unknown User"
        if self.user:
            username = getattr(self.user, 'username', 'Unknown')
            
        plan_name = self.plan.name if self.plan else "No Plan"
        return f"{username} - {plan_name}"

class SubscriptionTransaction(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('rejected', 'Rejected'),
    ]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    plan = models.ForeignKey(SubscriptionPlan, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    transaction_id = models.CharField(max_length=50, unique=True)
    status = models.CharField(max_length=20, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        # ✅ FIX: Handle case where user is deleted
        username = "Unknown"
        if self.user:
            username = getattr(self.user, 'username', 'Unknown')
            
        return f"{username} - {self.amount} RWF ({self.status})"