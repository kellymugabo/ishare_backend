from django.contrib import admin
from .models import UserProfile, Trip, Booking, DriverVerification, PaymentTransaction

# 1. User Profile Admin
@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'phone_number', 'role', 'rating')
    list_filter = ('role',)

# 2. Driver Verification Admin (THIS IS WHAT YOU ARE MISSING)
@admin.register(DriverVerification)
class DriverVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'full_name', 'status', 'submitted_at')
    list_filter = ('status',)
    actions = ['approve_driver', 'reject_driver']

    def approve_driver(self, request, queryset):
        queryset.update(status='approved')
    approve_driver.short_description = "Approve selected drivers"

# 3. Trip Admin
@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = ('driver', 'start_location_name', 'destination_name', 'price_per_seat', 'is_active')
    list_filter = ('is_active', 'created_at')

# 4. Booking Admin
@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = ('trip', 'passenger', 'seats_booked', 'status', 'total_price')
    list_filter = ('status',)

# 5. Payment Admin
@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = ('booking', 'amount', 'status', 'provider', 'paid_at')
    list_filter = ('status',)