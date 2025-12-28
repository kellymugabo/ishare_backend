from django.contrib import admin
from django.utils.html import format_html
from .models import (
    UserProfile,
    Trip,
    Booking,
    Rating,
    PaymentTransaction,
    DriverVerification,
    VerificationStatus,
)


# =====================================================
#  USER PROFILE ADMIN
# =====================================================
@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = (
        'user',
        'role_badge',
        'vehicle_photo_preview', 
        'vehicle_info',
        'rating_display',
        'verification_badge',
        'created_at',
    )
    list_filter = ('role', 'created_at')
    
    # ✅ FIXED: Changed 'phone' -> 'phone_number'
    search_fields = ('user__username', 'user__email', 'phone_number', 'vehicle_plate_number')
    readonly_fields = ('created_at', 'updated_at', 'rating')

    fieldsets = (
        ('User Information', {
            # ✅ FIXED: Changed 'phone' -> 'phone_number' and 'avatar' -> 'profile_picture'
            'fields': ('user', 'role', 'phone_number', 'profile_picture', 'rating')
        }),
        ('Vehicle Information (For Drivers)', {
            'fields': ('vehicle_plate_number', 'vehicle_model', 'vehicle_seats', 'vehicle_photo'),
            'classes': ('collapse', 'show') 
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )

    def role_badge(self, obj):
        color = '#007bff' if obj.role == 'driver' else '#6c757d'
        icon = '🚗' if obj.role == 'driver' else '👤'
        return format_html(
            '<span style="background-color: {}; color: white; padding: 5px 10px; '
            'border-radius: 12px; font-weight: bold; font-size: 11px;">{} {}</span>',
            color, icon, obj.role.upper()
        )
    role_badge.short_description = 'Role'

    def vehicle_photo_preview(self, obj):
        if obj.vehicle_photo:
            return format_html(
                '<img src="{}" style="width: 50px; height: 35px; object-fit: cover; border-radius: 4px;" />',
                obj.vehicle_photo.url
            )
        if obj.role == 'driver':
            return format_html('<span style="color: #dc3545; font-size: 10px;">No Photo</span>')
        return "-"
    vehicle_photo_preview.short_description = 'Car Photo'

    def rating_display(self, obj):
        if obj.rating:
            try:
                stars = '⭐' * int(obj.rating)
            except Exception:
                stars = '⭐'
            rating_value = f"{obj.rating:.1f}" if isinstance(obj.rating, (int, float)) else str(obj.rating)
            return format_html(
                '{} <span style="color: #ffc107;">{}</span>',
                stars,
                rating_value
            )
        return format_html('<span style="color: #6c757d;">No rating</span>')
    rating_display.short_description = 'Rating'

    def verification_badge(self, obj):
        try:
            verification = DriverVerification.objects.get(user=obj.user)

            if verification.status == VerificationStatus.APPROVED:
                return format_html('<span style="color: #28a745; font-weight: bold;">✅ Verified</span>')
            elif verification.status == VerificationStatus.PENDING:
                return format_html('<span style="color: #ffc107; font-weight: bold;">⏱️ Pending</span>')
            else:
                return format_html('<span style="color: #dc3545; font-weight: bold;">❌ Rejected</span>')
        except DriverVerification.DoesNotExist:
            return format_html('<span style="color: #6c757d;">-</span>')
    verification_badge.short_description = 'Verification'

    def vehicle_info(self, obj):
        if obj.vehicle_plate_number:
            return format_html(
                '<strong>{}</strong><br><small>{} ({} seats)</small>',
                obj.vehicle_plate_number,
                obj.vehicle_model or 'N/A',
                obj.vehicle_seats or 'N/A'
            )
        return format_html('<span style="color: #6c757d;">No vehicle</span>')
    vehicle_info.short_description = 'Vehicle'


# =====================================================
#  TRIP ADMIN
# =====================================================
@admin.register(Trip)
class TripAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'driver_display',
        'route_display',
        'departure_time',
        'seats_display',
        'price_display',
        'status_badge'
    )
    list_filter = ('is_active', 'departure_time')
    search_fields = ('start_location_name', 'destination_name', 'driver__username')
    list_filter = ('is_active', 'has_ac', 'allows_luggage', 'no_smoking')
    def driver_display(self, obj):
        driver = getattr(obj, 'driver', None)
        if driver:
            return format_html(
                '<a href="/admin/api/userprofile/?user__id__exact={}">{}</a>',
                driver.id,
                driver.username
            )
        return format_html('<span style="color: #6c757d;">(no driver)</span>')
    driver_display.short_description = 'Driver'

    def route_display(self, obj):
        start = obj.start_location_name or '(no start)'
        dest = obj.destination_name or '(no destination)'
        return f"{start} → {dest}"
    route_display.short_description = 'Route'

    def seats_display(self, obj):
        seats = obj.available_seats
        if seats is None:
            return format_html('<span style="color: #6c757d;">N/A</span>')

        color = '#28a745' if seats > 2 else '#dc3545'
        return format_html('<span style="color: {};">{} available</span>', color, seats)
    seats_display.short_description = 'Seats'

    def price_display(self, obj):
        price = obj.price_per_seat
        if price is None:
            return format_html('<span style="color: #6c757d;">N/A</span>')
        return format_html('<strong style="color: #007bff;">{} RWF</strong>', f"{int(price):,}")
    price_display.short_description = 'Price/Seat'

    def status_badge(self, obj):
        if obj.is_active:
            return format_html(
                '<span style="background-color: #28a745; color: white; padding: 5px 10px; '
                'border-radius: 12px; font-weight: bold; font-size: 11px;">✅ ACTIVE</span>'
            )
        return format_html(
            '<span style="background-color: #6c757d; color: white; padding: 5px 10px; '
            'border-radius: 12px; font-weight: bold; font-size: 11px;">❌ INACTIVE</span>'
        )
    status_badge.short_description = 'Status'


# =====================================================
#  BOOKING ADMIN
# =====================================================
@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'trip_info',
        'passenger_display',
        'seats_booked',
        'status_badge',
        'total_price_display',
        'created_at'
    )
    list_filter = ('status', 'created_at')
    search_fields = ('trip__start_location_name', 'passenger__username')

    def trip_info(self, obj):
        trip = obj.trip
        if not trip:
            return format_html('<span style="color: #6c757d;">(no trip)</span>')
        return format_html(
            '<a href="/admin/api/trip/{}/change/">Trip #{}</a><br><small>{} → {}</small>',
            trip.id,
            trip.id,
            trip.start_location_name,
            trip.destination_name
        )
    trip_info.short_description = 'Trip'

    def passenger_display(self, obj):
        passenger = obj.passenger
        if passenger:
            return format_html(
                '<a href="/admin/api/userprofile/?user__id__exact={}">{}</a>',
                passenger.id,
                passenger.username
            )
        return format_html('<span style="color: #6c757d;">(no passenger)</span>')
    passenger_display.short_description = 'Passenger'

    def status_badge(self, obj):
        colors = {
            'pending': '#ffc107',
            'confirmed': '#28a745',
            'completed': '#007bff',
            'canceled': '#dc3545'
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 5px 10px; '
            'border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>',
            colors.get(obj.status, '#6c757d'),
            obj.status.upper()
        )
    status_badge.short_description = 'Status'

    def total_price_display(self, obj):
        total = obj.total_price
        if total is None:
            return format_html('<span style="color: #6c757d;">N/A</span>')
        return format_html('<strong style="color: #28a745;">{} RWF</strong>', f"{int(total):,}")
    total_price_display.short_description = 'Total'


# =====================================================
#  RATING ADMIN
# =====================================================
@admin.register(Rating)
class RatingAdmin(admin.ModelAdmin):
    list_display = ('id', 'trip', 'rater', 'ratee', 'score_display', 'created_at')
    search_fields = ('rater__username', 'ratee__username')
    list_filter = ('score', 'created_at')

    def score_display(self, obj):
        return format_html(
            '<span style="color: #ffc107; font-size: 16px;">{}</span>',
            '⭐' * int(obj.score)
        )
    score_display.short_description = 'Rating'


# =====================================================
#  PAYMENT TRANSACTION ADMIN
# =====================================================
@admin.register(PaymentTransaction)
class PaymentTransactionAdmin(admin.ModelAdmin):
    list_display = (
        'id',
        'booking_info',
        'passenger_display',
        'amount_display',
        'provider',
        'status_badge',
        'created_at',
        'paid_at'
    )
    list_filter = ('status', 'provider', 'created_at')
    search_fields = ('booking__passenger__username', 'provider_transaction_id', 'booking__id')
    readonly_fields = ['created_at', 'paid_at', 'provider_transaction_id']
    
    fieldsets = (
        ('Payment Information', {
            'fields': ('booking', 'amount', 'provider', 'provider_transaction_id', 'status')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'paid_at'),
            'classes': ('collapse',)
        }),
    )

    def booking_info(self, obj):
        booking = obj.booking
        if not booking:
            return format_html('<span style="color: #6c757d;">(no booking)</span>')
        return format_html(
            '<a href="/admin/api/booking/{}/change/">Booking #{}</a><br>'
            '<small>Trip: {} → {}</small>',
            booking.id,
            booking.id,
            booking.trip.start_location_name if booking.trip else 'N/A',
            booking.trip.destination_name if booking.trip else 'N/A'
        )
    booking_info.short_description = 'Booking'
    
    def passenger_display(self, obj):
        """Display the passenger who made the payment"""
        booking = obj.booking
        if not booking or not booking.passenger:
            return format_html('<span style="color: #6c757d;">(no passenger)</span>')
        
        passenger = booking.passenger
        return format_html(
            '<a href="/admin/auth/user/{}/change/">{}</a>',
            passenger.id,
            passenger.username
        )
    passenger_display.short_description = 'Passenger'

    def amount_display(self, obj):
        amount = obj.amount
        if amount is None:
            return format_html('<span style="color: #6c757d;">N/A</span>')
        return format_html('<strong style="color: #28a745;">{} RWF</strong>', f"{int(amount):,}")
    amount_display.short_description = 'Amount'

    def status_badge(self, obj):
        colors = {
            'pending': '#ffc107',
            'success': '#28a745',
            'failed': '#dc3545',
            'refunded': '#6c757d'
        }
        icons = {
            'pending': '⏱️',
            'success': '✅',
            'failed': '❌',
            'refunded': '↩️'
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 5px 10px; '
            'border-radius: 12px; font-weight: bold; font-size: 11px;">{} {}</span>',
            colors.get(obj.status, '#6c757d'),
            icons.get(obj.status, ''),
            obj.status.upper()
        )
    status_badge.short_description = 'Status'


# =====================================================
#  DRIVER VERIFICATION ADMIN
# =====================================================
@admin.register(DriverVerification)
class DriverVerificationAdmin(admin.ModelAdmin):
    list_display = (
        'user',
        'full_name',
        'national_id',
        'phone_number',
        'status_badge',
        'submitted_at',
        'reviewed_at'
    )
    list_filter = ('status', 'submitted_at')
    search_fields = ('user__username', 'user__email', 'national_id', 'phone_number')
    readonly_fields = ('submitted_at',)
    
    def status_badge(self, obj):
        colors = {
            'pending': '#ffc107',
            'approved': '#28a745',
            'rejected': '#dc3545'
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 5px 10px; '
            'border-radius: 12px; font-weight: bold; font-size: 11px;">{}</span>',
            colors.get(obj.status, '#6c757d'),
            obj.status.upper()
        )
    status_badge.short_description = 'Status'