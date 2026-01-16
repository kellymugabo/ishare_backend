import random
import uuid 
from datetime import timedelta
from rest_framework import viewsets, status, permissions, generics, views, filters
from rest_framework.exceptions import ValidationError as DRFValidationError, PermissionDenied
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework_simplejwt.views import TokenObtainPairView
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.db.models import Count, Q 
from django.core.exceptions import ValidationError 
from django.core.mail import send_mail
from django.conf import settings

# ✅ Import Models from CORE
from .models import (
    UserProfile, Trip, Booking, Rating, PaymentTransaction,
    DriverVerification, VerificationStatus
)

# ✅ Import Models from SUBSCRIPTIONS
from subscriptions.models import UserSubscription, SubscriptionPlan

# ✅ Import Permissions
from .permissions import IsDriverOrReadOnly

# ✅ Import Serializers
from .serializers import (
    UserSerializer, RegisterSerializer, UserProfileSerializer,
    TripSerializer, BookingSerializer, RatingSerializer,
    PaymentSerializer, DriverVerificationSerializer
)

# ✅ Email Fallbacks
try:
    from .emails import send_booking_confirmation, send_otp_email
except ImportError:
    def send_booking_confirmation(user, details): print("Simulating Email: Booking Confirmed")
    def send_otp_email(email, code): print(f"Simulating Email: OTP is {code}")

User = get_user_model()

# =====================================================
#  REGISTER & AUTH
# =====================================================

class RegisterViewSet(viewsets.ViewSet):
    permission_classes = [AllowAny]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def create(self, request):
        serializer = RegisterSerializer(data=request.data, context={'request': request})
        if serializer.is_valid():
            user = serializer.save()
            
            # ✅ SEND WELCOME EMAIL
            try:
                user_role = user.profile.role.capitalize() if hasattr(user, 'profile') else "Member"
                subject = f"Welcome to iShare, {user.username}!"
                action_text = "Post your first trip!" if user_role == "Driver" else "Book your first ride!"
                
                message = f"""
Hello {user.username},

Welcome to iShare! We are thrilled to have you join our community as a {user_role}.

Next Steps:
1. Log in to the app.
2. Complete your profile.
3. {action_text}

Safe travels,
The iShare Team
"""
                send_mail(subject, message, settings.EMAIL_HOST_USER, [user.email], fail_silently=True)
            except Exception as e:
                print(f"❌ Failed to send welcome email: {str(e)}")
            
            # Return Profile Data
            profile_data = UserProfileSerializer(user.profile, context={'request': request}).data
            
            return Response(
                {
                    "message": "Registration successful.", 
                    "user": UserSerializer(user).data,
                    "profile": profile_data 
                },
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        data = request.data.copy()
        login_input = data.get("username", "")

        # Allow Login with Email
        if '@' in login_input:
            user = User.objects.filter(email=login_input).first()
            if user:
                data['username'] = user.username 
        
        serializer = self.get_serializer(data=data)

        try:
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({"detail": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

        # Ensure Profile Exists
        user = serializer.user
        if not hasattr(user, "profile"):
            UserProfile.objects.create(user=user)

        return Response(serializer.validated_data, status=status.HTTP_200_OK)

# =====================================================
#  PASSWORD RESET (OTP)
# =====================================================
class ForgotPasswordView(views.APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        user = User.objects.filter(email=email).first()

        if user:
            if not hasattr(user, 'profile'):
                UserProfile.objects.create(user=user)

            code = str(random.randint(100000, 999999))
            user.profile.reset_code = code
            user.profile.save()
            send_otp_email(email, code)
            
        return Response({"message": "Reset code sent to your email."}, status=status.HTTP_200_OK)

class ResetPasswordView(views.APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        code = request.data.get('code')
        new_password = request.data.get('new_password')

        user = User.objects.filter(email=email).first()

        if user and user.profile.reset_code == code:
            if len(new_password) < 8:
                return Response({"error": "Password must be at least 8 characters."}, status=400)
            
            user.set_password(new_password)
            user.save()
            user.profile.reset_code = None 
            user.profile.save()
            return Response({"message": "Password reset successful! You can now login."}, status=200)
        
        return Response({"error": "Invalid reset code or email."}, status=400)

# =====================================================
#  USER PROFILE
# =====================================================
class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_queryset(self):
        return UserProfile.objects.select_related("user").all()

    @action(detail=False, methods=['get', 'patch'], url_path='me', url_name='me')
    def me(self, request):
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        
        if request.method == "GET":
            serializer = self.get_serializer(profile, context={'request': request})
            return Response(serializer.data)
        
        serializer = self.get_serializer(
            profile, data=request.data, partial=True, context={'request': request}
        )
        if serializer.is_valid():
            updated_profile = serializer.save()
            response_serializer = self.get_serializer(updated_profile, context={'request': request})
            return Response(response_serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

# =====================================================
#  TRIPS (Fixed Security Logic)
# =====================================================
class TripViewSet(viewsets.ModelViewSet):
    serializer_class = TripSerializer
    parser_classes = [MultiPartParser, FormParser, JSONParser]
    permission_classes = [IsAuthenticated, IsDriverOrReadOnly]
    
    filter_backends = [filters.SearchFilter]
    search_fields = ['start_location_name', 'destination_name']

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated(), IsDriverOrReadOnly()]

    def get_queryset(self):
        return Trip.objects.select_related('driver', 'driver__profile').all().order_by('-departure_time')

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset().filter(is_active=True)
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)
        
    @action(detail=False, methods=['get'], url_path='my_trips')
    def my_trips(self, request):
        queryset = self.get_queryset().filter(driver=request.user)
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data)

    def create(self, request, *args, **kwargs):
        try:
            # 1. SUBSCRIPTION CHECK (Secure & Crash Proof)
            has_active_sub = UserSubscription.objects.filter(
                user=request.user, 
                is_active=True
            ).exists()
            
            # 🛑 STOP HERE if no subscription
            if not has_active_sub:
                 return Response({
                    'error': 'You must have an active subscription to post a ride.'
                 }, status=status.HTTP_403_FORBIDDEN)

            # 2. Proceed if valid
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            # This catches crashes and shows you the error instead of 500
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    def perform_create(self, serializer):
        # Optional: Update Vehicle info if provided
        new_car_name = self.request.data.get('new_car_name')
        new_car_photo = self.request.FILES.get('new_car_photo')
        
        if hasattr(self.request.user, 'profile'):
            profile = self.request.user.profile
            if new_car_name: profile.vehicle_model = new_car_name
            if new_car_photo: profile.vehicle_photo = new_car_photo
            if new_car_name or new_car_photo: profile.save()

        serializer.save(driver=self.request.user)

# =====================================================
#  BOOKINGS
# =====================================================
class BookingViewSet(viewsets.ModelViewSet):
    serializer_class = BookingSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        queryset = Booking.objects.select_related(
            "passenger", "trip", "trip__driver", "trip__driver__profile"
        ).filter(
            Q(passenger=user) | Q(trip__driver=user)
        ).order_by('-created_at')

        trip_id = self.request.query_params.get('trip_id')
        if trip_id:
            queryset = queryset.filter(trip_id=trip_id)
        return queryset

    def create(self, request, *args, **kwargs):
        try:
            # ✅ SUBSCRIPTION CHECK
            has_active_sub = UserSubscription.objects.filter(
                user=request.user, 
                is_active=True
            ).exists()
            
            if not has_active_sub:
                 return Response({
                    'error': 'Your subscription has expired. Please renew to book trips.'
                 }, status=status.HTTP_403_FORBIDDEN)

            serializer = self.get_serializer(data=request.data, context={'request': request})
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
            
        except ValidationError as e:
            return Response({'detail': e.messages}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    def perform_create(self, serializer):
        trip = serializer.validated_data['trip']
        seats_requested = serializer.validated_data['seats_booked']
        
        if trip.available_seats < seats_requested:
            raise ValidationError({"detail": "Not enough seats available."})

        if Booking.objects.filter(trip=trip, passenger=self.request.user).exists():
            raise ValidationError({"detail": "You have already booked this trip."})

        booking = serializer.save(passenger=self.request.user, status='pending')
        trip.available_seats -= booking.seats_booked
        trip.save()
        
        try:
            details = {
                'start': trip.start_location_name,
                'end': trip.destination_name,
                'date': trip.departure_time.strftime("%Y-%m-%d %H:%M"),
                'price': float(booking.total_price)
            }
            send_booking_confirmation(self.request.user, details)
        except: pass

    @action(detail=False, methods=['get'], url_path='my_tickets')
    def my_tickets(self, request):
        bookings = self.get_queryset().filter(passenger=request.user)
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='driver-requests') 
    def driver_requests(self, request):
        bookings = Booking.objects.filter(trip__driver=request.user).exclude(passenger=request.user)
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        booking = self.get_object()
        if booking.trip.driver != request.user:
            return Response({'error': 'Not authorized'}, status=403)
            
        booking.status = 'approved'
        booking.save()
        return Response({'message': 'Booking approved.', 'status': booking.status})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        booking = self.get_object()
        if booking.trip.driver != request.user:
            return Response({'error': 'Not authorized'}, status=403)
            
        booking.status = 'cancelled'
        booking.save()
        
        trip = booking.trip
        trip.available_seats += booking.seats_booked
        trip.save()
        return Response({'message': 'Booking rejected.', 'status': booking.status})

# =====================================================
#  RATINGS
# =====================================================
class RatingViewSet(viewsets.ModelViewSet):
    queryset = Rating.objects.all()
    serializer_class = RatingSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(rater=self.request.user)

# =====================================================
#  PAYMENTS
# =====================================================
class PaymentViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    def create(self, request):
        try:
            booking_id = request.data.get('booking_id')
            amount = request.data.get('amount')
            
            booking = get_object_or_404(Booking, id=booking_id, passenger=request.user)
            
            if hasattr(booking, 'payment'):
                return Response({'status': 'error', 'message': 'Already paid'}, status=400)
            
            transaction_ref = f"MANUAL-{uuid.uuid4().hex[:8].upper()}"

            PaymentTransaction.objects.create(
                booking=booking,
                amount=amount or booking.total_price,
                provider='mobile_money_transfer',
                provider_transaction_id=transaction_ref,
                status='confirmed',
                paid_at=timezone.now()
            )

            booking.status = 'confirmed'
            booking.save()
            
            return Response({
                'status': 'success', 
                'message': 'Payment recorded',
                'driver_phone': booking.trip.driver.profile.phone_number
            }, status=201)
            
        except Exception as e:
            return Response({'status': 'error', 'message': str(e)}, status=400)

    def list(self, request):
        payments = PaymentTransaction.objects.filter(booking__passenger=request.user)
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data)

# =====================================================
#  DRIVER VERIFICATION
# =====================================================
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_driver_verification(request):
    existing = DriverVerification.objects.filter(
        user=request.user,
        status__in=[VerificationStatus.PENDING, VerificationStatus.APPROVED]
    ).first()
    if existing:
        return Response({'error': f'Request already {existing.status}'}, status=400)
    
    serializer = DriverVerificationSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        serializer.save()
        return Response({'message': 'Submitted successfully'}, status=201)
    return Response(serializer.errors, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def check_verification_status(request):
    try:
        verification = DriverVerification.objects.filter(user=request.user).latest('submitted_at')
        return Response({
            'is_verified': verification.status == VerificationStatus.APPROVED,
            'status': verification.status,
            'rejection_reason': verification.rejection_reason
        })
    except DriverVerification.DoesNotExist:
        return Response({'is_verified': False, 'status': None})

# =====================================================
#  🚑 EMERGENCY REPAIR TOOL (Use to fix broken Users)
# =====================================================
@api_view(['GET'])
@permission_classes([AllowAny])
def fix_all_profiles(request):
    """
    Visits every user. If they are missing a Profile, creates one.
    """
    users = User.objects.all()
    fixed_count = 0
    log = []

    for user in users:
        try:
            if not hasattr(user, 'profile'):
                UserProfile.objects.create(user=user, role='passenger')
                fixed_count += 1
                log.append(f"Fixed: {user.username}")
        except Exception as e:
            log.append(f"Error on {user.username}: {str(e)}")
            
    return Response({
        "message": f"Operation Complete. Fixed {fixed_count} broken profiles.",
        "details": log
    })

    # --- Add to bottom of core/views.py ---

@api_view(['GET'])
@permission_classes([AllowAny])
def force_delete_user(request, username):
    """
    Deletes a user by username, bypassing the Admin Panel crash.
    Usage: /force-delete/username/
    """
    try:
        # 1. Find the user
        target_user = User.objects.get(username=username)
        user_id = target_user.id
        
        # 2. Manual Cleanup (Safety First)
        # We manually delete the subscription first to prevent signal crashes
        if hasattr(target_user, 'driver_subscription'):
            target_user.driver_subscription.delete()
            
        # 3. Delete the User
        target_user.delete()
        
        return Response({
            "status": "success", 
            "message": f"User '{username}' (ID: {user_id}) has been permanently deleted."
        }, status=200)

    except User.DoesNotExist:
        return Response({
            "status": "error", 
            "message": f"User '{username}' not found."
        }, status=404)
        
    except Exception as e:
        return Response({
            "status": "crash", 
            "error": str(e)
        }, status=500)