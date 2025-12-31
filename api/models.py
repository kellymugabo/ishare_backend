from django.db import models
from django.contrib.auth import get_user_model
from django.core.validators import RegexValidator
from django.core.exceptions import ValidationError 

User = get_user_model()


class VerificationStatus(models.TextChoices):
    PENDING = 'pending', 'Pending'
    APPROVED = 'approved', 'Approved'
    REJECTED = 'rejected', 'Rejected'


class DriverVerification(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='driver_verification')
    full_name = models.CharField(max_length=255)
    national_id = models.CharField(
        max_length=16,
        unique=True,
        validators=[RegexValidator(regex=r'^\d{16}$', message='National ID must be exactly 16 digits')]
    )
    phone_number = models.CharField(
        max_length=13,
        validators=[RegexValidator(regex=r'^\+250\d{9}$', message='Phone number must be in format +250XXXXXXXXX')]
    )
    
    # ✅ ADDED THESE LINES (Optional Photos)
    national_id_photo = models.ImageField(upload_to='verification/', null=True, blank=True)
    license_photo = models.ImageField(upload_to='verification/', null=True, blank=True)

    status = models.CharField(max_length=20, choices=VerificationStatus.choices, default=VerificationStatus.PENDING)
    submitted_at = models.DateTimeField(auto_now_add=True)
    reviewed_at = models.DateTimeField(null=True, blank=True)
    reviewed_by = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='reviewed_verifications'
    )
    rejection_reason = models.TextField(null=True, blank=True)

    class Meta:
        db_table = 'driver_verifications'
        ordering = ['-submitted_at']

    def __str__(self):
        return f"{self.user.email} - {self.status}"


class UserProfile(models.Model):
    USER_ROLES = (
        ('driver', 'Driver'),
        ('passenger', 'Passenger'),
    )
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='profile')
    role = models.CharField(max_length=10, choices=USER_ROLES, default='passenger')
    
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    reset_code = models.CharField(max_length=6, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', null=True, blank=True)
    
    bio = models.TextField(blank=True)
    rating = models.FloatField(default=5.0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    # --- VEHICLE DETAILS ---
    vehicle_plate_number = models.CharField(
        max_length=20, 
        blank=True, 
        null=True,
        validators=[
            RegexValidator(
                regex=r'^R[A-Z]{2} \d{3} [A-Z]$', 
                message='Plate must be in Rwandan format (e.g., RAD 123 A)'
            )
        ]
    )
    
    vehicle_model = models.CharField(max_length=100, blank=True, null=True)
    vehicle_seats = models.PositiveSmallIntegerField(blank=True, null=True)
    vehicle_photo = models.ImageField(upload_to='vehicle_photos/', null=True, blank=True)

    def __str__(self):
        return f"{self.user.username} ({self.role})"


class Trip(models.Model):
    driver = models.ForeignKey(User, on_delete=models.CASCADE, related_name='driven_trips')
    start_location_name = models.CharField(max_length=255)
    start_lat = models.FloatField()
    start_lng = models.FloatField()
    destination_name = models.CharField(max_length=255)
    dest_lat = models.FloatField()
    dest_lng = models.FloatField()
    departure_time = models.DateTimeField()
    available_seats = models.PositiveSmallIntegerField()
    price_per_seat = models.DecimalField(max_digits=8, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    # Amenities & Preferences
    has_ac = models.BooleanField(default=False, verbose_name="Air Conditioning")
    allows_luggage = models.BooleanField(default=False, verbose_name="Large Luggage Allowed")
    no_smoking = models.BooleanField(default=True, verbose_name="No Smoking")
    has_music = models.BooleanField(default=False, verbose_name="Music Available")

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Trip {self.id} by {self.driver.username} {self.start_location_name} -> {self.destination_name}"


class Booking(models.Model):
    STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('approved', 'Approved'),
        ('confirmed', 'Confirmed'),
        ('canceled', 'Canceled'),
        ('completed', 'Completed'),
    )

    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='bookings')
    passenger = models.ForeignKey(User, on_delete=models.CASCADE, related_name='bookings')
    seats_booked = models.PositiveSmallIntegerField(default=1)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    total_price = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def save(self, *args, **kwargs):
        if not self.total_price:
            self.total_price = self.seats_booked * self.trip.price_per_seat
        super().save(*args, **kwargs)

    def __str__(self):
        return f"Booking {self.id} by {self.passenger.username} for trip {self.trip.id}"


class Rating(models.Model):
    trip = models.ForeignKey(Trip, on_delete=models.CASCADE, related_name='ratings')
    rater = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='given_ratings')
    ratee = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='received_ratings')
    score = models.PositiveSmallIntegerField()
    comment = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Rating {self.id} - {self.score}/5"


class PaymentTransaction(models.Model):
    PAYMENT_STATUS_CHOICES = (
        ('pending', 'Pending'),
        ('success', 'Success'),
        ('failed', 'Failed'),
    )

    booking = models.OneToOneField(Booking, on_delete=models.CASCADE, related_name='payment')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    provider = models.CharField(max_length=50, default='MoMo-Simulated')
    provider_transaction_id = models.CharField(max_length=255, blank=True, null=True)
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    paid_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Payment {self.id} - {self.amount} RWF - {self.status}"