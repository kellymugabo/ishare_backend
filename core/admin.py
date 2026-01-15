from django.contrib import admin
from .models import UserProfile, Trip, Booking, DriverVerification, PaymentTransaction

# 1. User Profile Admin
@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ('user', 'phone_number', 'role', 'rating')
    list_filter = ('role',)

# 2. Driver Verification Admin (UPDATED LOGIC)
@admin.register(DriverVerification)
class DriverVerificationAdmin(admin.ModelAdmin):
    list_display = ('user', 'full_name', 'status', 'submitted_at')
    list_filter = ('status',)
    actions = ['approve_driver', 'reject_driver']

    # ✅ THIS IS THE MAGIC PART
    def approve_driver(self, request, queryset):
        # 1. Update the Verification Status to 'Approved'
        queryset.update(status='approved')
        
        # 2. Loop through all selected users and upgrade their role to 'Driver'
        for verification in queryset:
            user_profile = verification.user  # Get the user
            user_profile.role = 'driver'      # Switch role
            user_profile.save()               # Save the change
            
    approve_driver.short_description = "Approve selected drivers (And upgrade Role)"

    def reject_driver(self, request, queryset):
        queryset.update(status='rejected')
    reject_driver.short_description = "Reject selected drivers"

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