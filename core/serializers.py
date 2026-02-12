from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.conf import settings
import os
import re
from django.db.models import Sum, Avg 
from .models import (
    UserProfile, Trip, Booking, Rating, PaymentTransaction,
    DriverVerification, VerificationStatus
)

User = get_user_model()

# -------------------- DRIVER VERIFICATION --------------------
class DriverVerificationSerializer(serializers.ModelSerializer):
    user_username = serializers.CharField(source='user.username', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    
    national_id_photo = serializers.ImageField(required=False, allow_null=True)
    license_photo = serializers.ImageField(required=False, allow_null=True)

    class Meta:
        model = DriverVerification
        fields = [
            'id', 'user_id', 'user_username', 'user_email',
            'full_name', 'national_id', 'phone_number',
            'national_id_photo', 'license_photo',
            'status', 'submitted_at', 'reviewed_at', 'rejection_reason'
        ]
        read_only_fields = ['id', 'status', 'submitted_at', 'reviewed_at']

    def validate_full_name(self, value):
        name = value.strip()
        if len(name) < 3:
            raise serializers.ValidationError('Full name must be at least 3 characters.')
        if len(name.split()) < 2:
            raise serializers.ValidationError('Please provide first and last name.')
        return name

    def validate_national_id(self, value):
        clean_id = value.replace(' ', '')
        if len(clean_id) != 16 or not clean_id.isdigit():
            raise serializers.ValidationError('National ID must be exactly 16 numeric digits.')
        
        user = self.context['request'].user
        if DriverVerification.objects.filter(
            national_id=clean_id,
            status=VerificationStatus.APPROVED
        ).exclude(user=user).exists():
            raise serializers.ValidationError('This National ID is already registered.')
        return clean_id

    def validate_phone_number(self, value):
        clean = re.sub(r'[^\d+]', '', value)
        if clean.startswith('+250'):
            clean = '0' + clean[4:]
        elif clean.startswith('250'):
            clean = '0' + clean[3:]
        
        if not clean.startswith('07') or len(clean) != 10:
             raise serializers.ValidationError('Phone number must be a valid Rwanda number (e.g., 078XXXXXXX).')

        formatted = f'+250{clean[1:]}'
        
        user = self.context['request'].user
        if DriverVerification.objects.filter(
            phone_number=formatted,
            status=VerificationStatus.APPROVED
        ).exclude(user=user).exists():
            raise serializers.ValidationError('This phone number is already registered.')
        return formatted

    def create(self, validated_data):
        # Extract user and status from kwargs (passed from view)
        user = validated_data.pop('user', None) or self.context['request'].user
        status = validated_data.pop('status', VerificationStatus.PENDING)
        
        # Delete any existing verification for this user
        DriverVerification.objects.filter(user=user).delete()
        
        # Create new verification with user, status, and all validated data
        return DriverVerification.objects.create(
            user=user, 
            status=status, 
            **validated_data
        )

# -------------------- USER + AUTH --------------------
class UserSerializer(serializers.ModelSerializer):
    is_verified = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name', 'is_verified']

    def get_is_verified(self, obj):
        # Checks if the driver is verified
        return hasattr(obj, 'driver_verification') and obj.driver_verification.status == 'APPROVED'


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={'input_type': 'password'})
    password2 = serializers.CharField(write_only=True, style={'input_type': 'password'})
    
    role = serializers.CharField(required=False, default='passenger')
    vehicle_model = serializers.CharField(required=False, allow_blank=True)
    plate_number = serializers.CharField(required=False, allow_blank=True)
    vehicle_photo = serializers.ImageField(required=False)

    class Meta:
        model = User
        fields = [
            'username', 'email', 'password', 'password2',
            'first_name', 'last_name',
            'role', 'vehicle_model', 'plate_number', 'vehicle_photo'
        ]

    def validate_password(self, value):
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
        if not re.search(r'\d', value):
            raise serializers.ValidationError("Password must contain at least one number.")
        return value

    def validate_email(self, value):
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("This email address is already registered.")
        return value

    def validate(self, data):
        if data.get('password') != data.get('password2'):
            raise serializers.ValidationError({"password": "Passwords must match."})

        role = data.get('role', 'passenger')
        plate = data.get('plate_number')

        if role == 'driver':
            if not plate:
                raise serializers.ValidationError({"plate_number": "Drivers must provide a plate number."})
            if UserProfile.objects.filter(vehicle_plate_number=plate).exists():
                raise serializers.ValidationError({"plate_number": "This vehicle plate number is already registered."})
        return data

    def create(self, validated_data):
        role = validated_data.pop('role', 'passenger')
        vehicle_model = validated_data.pop('vehicle_model', None)
        plate_number = validated_data.pop('plate_number', None)
        vehicle_photo = validated_data.pop('vehicle_photo', None)
        validated_data.pop('password2')

        if not vehicle_photo and self.context.get('request'):
            vehicle_photo = self.context['request'].FILES.get('vehicle_photo')

        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
            first_name=validated_data.get('first_name', ''),
            last_name=validated_data.get('last_name', '')
        )

        profile, created = UserProfile.objects.get_or_create(user=user)
        profile.role = role
        if role == 'driver':
            if vehicle_model: profile.vehicle_model = vehicle_model
            if plate_number: profile.vehicle_plate_number = plate_number
            if vehicle_photo: profile.vehicle_photo = vehicle_photo
        elif vehicle_photo:
            profile.vehicle_photo = vehicle_photo
        
        profile.save()
        return user


# -------------------- REVIEWS (HELPER) --------------------
class SimpleReviewSerializer(serializers.ModelSerializer):
    rater_name = serializers.ReadOnlyField(source='rater.username')
    rater_avatar = serializers.SerializerMethodField()

    class Meta:
        model = Rating
        fields = ['id', 'rater_name', 'rater_avatar', 'score', 'comment', 'created_at']

    def get_rater_avatar(self, obj):
        if hasattr(obj.rater, 'profile') and obj.rater.profile.profile_picture:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.rater.profile.profile_picture.url)
            return obj.rater.profile.profile_picture.url
        return None

# -------------------- PROFILES --------------------
class UserProfileSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    first_name = serializers.CharField(write_only=True, required=False)
    last_name = serializers.CharField(write_only=True, required=False)
    email = serializers.EmailField(write_only=True, required=False)
    
    rating = serializers.SerializerMethodField()
    reviews = SimpleReviewSerializer(source='user.received_ratings', many=True, read_only=True)
    
    class Meta:
        model = UserProfile
        fields = [
            'id', 'user', 'role', 
            'phone_number', 
            'profile_picture', 'bio',
            'rating', 'reviews',
            'vehicle_plate_number', 'vehicle_model',
            'vehicle_seats', 'vehicle_photo', 'created_at',
            'first_name', 'last_name', 'email'
        ]
        read_only_fields = ['id', 'user', 'rating', 'reviews', 'created_at']

    def get_rating(self, obj):
        ratings = obj.user.received_ratings.all()
        if ratings.exists():
            return round(ratings.aggregate(Avg('score'))['score__avg'], 1)
        return 5.0 
    
    def to_representation(self, instance):
        representation = super().to_representation(instance)
        request = self.context.get('request')
        
        def build_absolute_url(url_path):
            if not url_path: return None
            url_str = str(url_path)
            if request:
                return request.build_absolute_uri(url_str)
            return url_str
        
        vehicle_url = representation.get('vehicle_photo')
        if vehicle_url:
            representation['vehicle_photo'] = build_absolute_url(vehicle_url)
        
        profile_url = representation.get('profile_picture')
        if profile_url:
            representation['profile_picture'] = build_absolute_url(profile_url)
        
        return representation

    def update(self, instance, validated_data):
        user_data = {}
        if 'first_name' in validated_data: user_data['first_name'] = validated_data.pop('first_name')
        if 'last_name' in validated_data: user_data['last_name'] = validated_data.pop('last_name')
        if 'email' in validated_data: user_data['email'] = validated_data.pop('email')
        
        vehicle_photo = None
        if 'vehicle_photo' in validated_data:
            vehicle_photo = validated_data['vehicle_photo']
        elif self.context.get('request') and self.context['request'].FILES.get('vehicle_photo'):
            vehicle_photo = self.context['request'].FILES.get('vehicle_photo')
            validated_data['vehicle_photo'] = vehicle_photo
        
        profile_picture = None
        if 'profile_picture' in validated_data:
            profile_picture = validated_data['profile_picture']
        elif self.context.get('request') and self.context['request'].FILES.get('profile_picture'):
            profile_picture = self.context['request'].FILES.get('profile_picture')
            validated_data['profile_picture'] = profile_picture
        
        if user_data:
            user = instance.user
            for attr, value in user_data.items():
                setattr(user, attr, value)
            user.save()

        instance = super().update(instance, validated_data)
        
        if vehicle_photo: instance.vehicle_photo = vehicle_photo
        if profile_picture: instance.profile_picture = profile_picture
        if vehicle_photo or profile_picture: instance.save()
        
        return instance


# -------------------- TRIPS (UPDATED TO FIX 500 ERROR) --------------------
class TripSerializer(serializers.ModelSerializer):
    driver = UserSerializer(read_only=True)
    driver_name = serializers.SerializerMethodField()
    driver_phone = serializers.CharField(source='driver.profile.phone_number', read_only=True)
    driver_rating = serializers.SerializerMethodField()
    
    # ✅ FIX: Added this field safely so the frontend knows if driver is subscribed
    is_subscription_active = serializers.SerializerMethodField()

    car_name = serializers.SerializerMethodField()
    car_photo_url = serializers.SerializerMethodField()
    
    new_car_name = serializers.CharField(write_only=True, required=False) 
    new_car_photo = serializers.ImageField(write_only=True, required=False)

    departure_time = serializers.DateTimeField(
        format="%Y-%m-%dT%H:%M:%S", 
        input_formats=['%Y-%m-%dT%H:%M:%S', '%Y-%m-%dT%H:%M:%SZ', 'iso-8601']
    )

    booked_seats = serializers.SerializerMethodField()
    total_seats = serializers.IntegerField(source='available_seats', read_only=True)

    class Meta:
        model = Trip
        fields = [
            'id', 'driver', 'driver_name', 'driver_phone', 'driver_rating',
            'is_subscription_active', # ✅ Added here
            'start_location_name', 'start_lat', 'start_lng', 
            'destination_name', 'dest_lat', 'dest_lng', 'departure_time',
            'available_seats', 'price_per_seat', 'created_at', 'is_active',
            'car_name', 'car_photo_url',
            'new_car_name', 'new_car_photo',
            'total_seats', 'booked_seats',
            'has_ac', 'allows_luggage', 'no_smoking', 'has_music'
        ]
        read_only_fields = ['id', 'driver', 'driver_name', 'driver_phone', 'created_at']
    
    # ✅ FIX: Safe method to check subscription using the NEW name 'driver_subscription'
    def get_is_subscription_active(self, obj):
        try:
            # We use 'driver_subscription' because we changed the related_name in models.py
            if hasattr(obj.driver, 'driver_subscription'):
                return obj.driver.driver_subscription.is_active
            return False
        except:
            return False

    def get_booked_seats(self, obj):
        try:
            booked = obj.bookings.filter(status='ACCEPTED').aggregate(total=Sum('seats_booked'))['total']
        except AttributeError:
            booked = obj.booking_set.filter(status='ACCEPTED').aggregate(total=Sum('seats_booked'))['total']
        return booked or 0

    def get_driver_rating(self, obj):
        ratings = obj.driver.received_ratings.all()
        if ratings.exists():
            return round(ratings.aggregate(Avg('score'))['score__avg'], 1)
        return None

    def validate_available_seats(self, value):
        if value < 1:
            raise serializers.ValidationError("Available seats must be at least 1.")
        return value
    
    def validate_price_per_seat(self, value):
        if value <= 0:
            raise serializers.ValidationError("Price per seat must be greater than 0.")
        return value

    def create(self, validated_data):
        validated_data.pop('new_car_name', None)
        validated_data.pop('new_car_photo', None)
        return super().create(validated_data)

    def get_driver_name(self, obj):
        full_name = obj.driver.get_full_name()
        return full_name if full_name else obj.driver.username

    def get_car_name(self, obj):
        try:
            return obj.driver.profile.vehicle_model or "Standard Ride"
        except:
            return "Standard Ride"

    def get_car_photo_url(self, obj):
        try:
            if hasattr(obj.driver, 'profile') and obj.driver.profile.vehicle_photo:
                request = self.context.get('request')
                if request:
                    return request.build_absolute_uri(obj.driver.profile.vehicle_photo.url)
                return obj.driver.profile.vehicle_photo.url
        except:
            pass
        return None

# -------------------- BOOKINGS --------------------
class BookingSerializer(serializers.ModelSerializer):
    passenger = UserSerializer(read_only=True)
    passenger_name = serializers.CharField(source='passenger.username', read_only=True)
    trip = TripSerializer(read_only=True)

    trip_id = serializers.PrimaryKeyRelatedField(
        queryset=Trip.objects.all(),
        source='trip',
        write_only=True,
        required=True
    )

    class Meta:
        model = Booking
        fields = [
            'id', 'trip', 'trip_id', 'passenger', 'passenger_name','seats_booked',
            'status', 'total_price', 'created_at'
        ]
        read_only_fields = ['id', 'passenger', 'trip', 'status', 'created_at']

    def validate(self, data):
        trip = data.get('trip')
        user = self.context['request'].user
        if trip.driver == user:
            raise serializers.ValidationError({"detail": "You cannot book your own trip."})

        # Calculate seats
        try:
            booked = trip.bookings.filter(status='ACCEPTED').aggregate(total=Sum('seats_booked'))['total']
        except AttributeError:
            booked = trip.booking_set.filter(status='ACCEPTED').aggregate(total=Sum('seats_booked'))['total']
        
        booked = booked or 0
        current_available = trip.available_seats - booked
        
        if current_available < data.get('seats_booked', 1):
            raise serializers.ValidationError({"seats_booked": f"Not enough seats. Only {current_available} left."})
        return data

# -------------------- RATINGS --------------------
class RatingSerializer(serializers.ModelSerializer):
    rater = UserSerializer(read_only=True)
    ratee = UserSerializer(read_only=True)
    ratee_id = serializers.PrimaryKeyRelatedField(
        queryset=User.objects.all(),
        source='ratee',
        write_only=True
    )
    trip = serializers.PrimaryKeyRelatedField(read_only=True)
    trip_id = serializers.PrimaryKeyRelatedField(
        queryset=Trip.objects.all(),
        source='trip',
        write_only=True
    )

    class Meta:
        model = Rating
        fields = ['id', 'trip', 'trip_id', 'rater', 'ratee', 'ratee_id', 'score', 'comment', 'created_at']
        read_only_fields = ['id', 'rater', 'created_at']

# -------------------- PAYMENTS --------------------
class PaymentSerializer(serializers.ModelSerializer):
    user = serializers.SerializerMethodField()

    def get_user(self, obj):
        return UserSerializer(obj.booking.passenger).data

    class Meta:
        model = PaymentTransaction
        fields = [
            'id', 'booking', 'user', 'amount', 'provider',
            'provider_transaction_id', 'status',
            'created_at', 'paid_at'
        ]
        read_only_fields = ['id', 'user', 'provider', 'provider_transaction_id', 'created_at', 'paid_at']