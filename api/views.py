import random 
from datetime import timedelta
from rest_framework import viewsets, status, permissions, generics, views
from rest_framework.exceptions import ValidationError as DRFValidationError
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.permissions import IsAuthenticated, AllowAny, IsAdminUser
from rest_framework_simplejwt.views import TokenObtainPairView
from django.shortcuts import get_object_or_404
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.db.models import Count, Q 
from django.core.exceptions import ValidationError # ✅ Added for logic checks

from .models import (
    UserProfile, Trip, Booking, Rating, PaymentTransaction,
    DriverVerification, VerificationStatus, Subscription
)
from .serializers import (
    UserSerializer, RegisterSerializer, UserProfileSerializer,
    TripSerializer, BookingSerializer, RatingSerializer,
    PaymentSerializer, DriverVerificationSerializer, SubscriptionSerializer
)
from .utils import PaypackPayment 
from .emails import send_booking_confirmation, send_welcome_email, send_otp_email

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
            
            # ✅ Create subscription with 1 month trial
            Subscription.objects.create(
                user=user,
                status='trial',
                trial_ends_at=timezone.now() + timedelta(days=30)
            )
            
            # ✅ Send Welcome Email
            send_welcome_email(user)
            
            # ✅ Get profile with vehicle_photo included
            from .serializers import UserProfileSerializer
            profile = user.profile
            profile_data = UserProfileSerializer(profile, context={'request': request}).data
            
            return Response(
                {
                    "message": "Registration successful.", 
                    "user": UserSerializer(user).data,
                    "profile": profile_data  # ✅ Include profile with vehicle_photo
                },
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def perform_create(self, serializer):
        user = serializer.save()
        
        # ✅ Create subscription with 1 month trial
        Subscription.objects.create(
            user=user,
            status='trial',
            trial_ends_at=timezone.now() + timedelta(days=30)
        )
        
        send_welcome_email(user)

class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        # 1. Get the data safely
        data = request.data.copy()
        login_input = data.get("username", "")

        # 2. Check if user typed an EMAIL instead of a username
        if '@' in login_input:
            user = User.objects.filter(email=login_input).first()
            if user:
                data['username'] = user.username # Swap email for username
        
        # 3. Process Login
        serializer = self.get_serializer(data=data)

        try:
            serializer.is_valid(raise_exception=True)
        except Exception:
            return Response({"detail": "Invalid credentials"}, status=status.HTTP_401_UNAUTHORIZED)

        # 4. Success! Check profile existence
        user = serializer.user
        if not hasattr(user, "profile"):
            UserProfile.objects.create(user=user)

        return Response(serializer.validated_data, status=status.HTTP_200_OK)

# =====================================================
#  PASSWORD RESET (OTP FLOW)
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
            
        return Response({"message": "Reset code sent to your email."}, status=status.HTTP_200_OK)

class ResetPasswordView(views.APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email')
        code = request.data.get('code')
        new_password = request.data.get('new_password')

        user = User.objects.filter(email=email).first()

        if user:
            if user.profile.reset_code == code:
                if len(new_password) < 8:
                      return Response({"error": "Password must be at least 8 characters."}, status=400)
                
                user.set_password(new_password)
                user.save()
                
                user.profile.reset_code = None 
                user.profile.save()
                
                return Response({"message": "Password reset successful! You can now login."}, status=200)
            else:
                return Response({"error": "Invalid reset code."}, status=400)
        
        return Response({"error": "Invalid email."}, status=400)

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
            # ✅ Return the updated profile with absolute URLs
            response_serializer = self.get_serializer(updated_profile, context={'request': request})
            return Response(response_serializer.data)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @action(detail=False, methods=['get'])
    def user_profile(self, request):
        user_id = request.query_params.get('user_id')
        if not user_id:
            return Response({'error': 'User ID required'}, status=400)
            
        profile = get_object_or_404(UserProfile, user_id=user_id)
        # ✅ Ensure request context is passed for absolute URLs
        serializer = self.get_serializer(profile, context={'request': request})
        return Response(serializer.data)

# =====================================================
#  TRIPS
# =====================================================
class TripViewSet(viewsets.ModelViewSet):
    serializer_class = TripSerializer
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]

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

    def perform_create(self, serializer):
        try:
            DriverVerification.objects.filter(
                user=self.request.user,
                status=VerificationStatus.APPROVED
            ).exists()
        except Exception:
             pass 

        new_car_name = self.request.data.get('new_car_name')
        new_car_photo = self.request.FILES.get('new_car_photo')
        profile = self.request.user.profile
        
        if new_car_name: profile.vehicle_model = new_car_name
        if new_car_photo: profile.vehicle_photo = new_car_photo
        if new_car_name or new_car_photo: profile.save()

        serializer.save(driver=self.request.user)
    
    def create(self, request, *args, **kwargs):
        try:
            # ✅ Check subscription status before allowing trip creation
            subscription, _ = Subscription.objects.get_or_create(
                user=request.user,
                defaults={
                    'status': 'trial',
                    'trial_ends_at': timezone.now() + timedelta(days=30)
                }
            )
            
            if not subscription.is_active():
                return Response({
                    'error': 'Your subscription has expired. Please renew your subscription to create trips.',
                    'subscription_status': subscription.status,
                    'days_remaining': subscription.get_days_remaining(),
                    'subscription_price': subscription.get_subscription_price()
                }, status=status.HTTP_403_FORBIDDEN)
            
            serializer = self.get_serializer(data=request.data)
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        except PermissionError as e:
            return Response({'error': str(e)}, status=status.HTTP_403_FORBIDDEN)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

# =====================================================
#  BOOKINGS (✅ FIXED: Deducts Seats & Sends Email)
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
            # ✅ Validate trip_id is present in request
            if 'trip_id' not in request.data and 'trip' not in request.data:
                return Response(
                    {'trip_id': ['This field is required.']},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # ✅ Check subscription status before allowing booking
            subscription, _ = Subscription.objects.get_or_create(
                user=request.user,
                defaults={
                    'status': 'trial',
                    'trial_ends_at': timezone.now() + timedelta(days=30)
                }
            )
            
            if not subscription.is_active():
                return Response({
                    'error': 'Your subscription has expired. Please renew your subscription to book trips.',
                    'subscription_status': subscription.status,
                    'days_remaining': subscription.get_days_remaining(),
                    'subscription_price': subscription.get_subscription_price()
                }, status=status.HTTP_403_FORBIDDEN)
            
            # ✅ Pass request context to serializer
            serializer = self.get_serializer(data=request.data, context={'request': request})
            serializer.is_valid(raise_exception=True)
            self.perform_create(serializer)
            headers = self.get_success_headers(serializer.data)
            return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)
        except ValidationError as e:
            return Response(e.message_dict if hasattr(e, 'message_dict') else {'detail': e.messages}, status=status.HTTP_400_BAD_REQUEST)
        except DRFValidationError as e:
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'detail': str(e)}, status=status.HTTP_400_BAD_REQUEST)

    # 1. CREATE LOGIC: Validation + Math + Email
    def perform_create(self, serializer):
        # A. Check Seats
        trip = serializer.validated_data['trip']
        seats_requested = serializer.validated_data['seats_booked']
        
        if trip.available_seats < seats_requested:
            raise ValidationError({"detail": "Not enough seats available for this booking."})

        # B. Check Double Booking
        existing_booking = Booking.objects.filter(
            trip=trip, 
            passenger=self.request.user
        ).exists()
        
        if existing_booking:
            raise ValidationError({"detail": "You have already booked a seat on this trip."})

        # C. Save Booking
        booking = serializer.save(passenger=self.request.user, status='pending')
        
        # D. ✅ UPDATE SEATS (The Fix)
        trip.available_seats -= booking.seats_booked
        trip.save()
        
        # E. ✅ SEND EMAIL
        try:
            details = {
                'start': booking.trip.start_location_name,
                'end': booking.trip.destination_name,
                'date': booking.trip.departure_time.strftime("%Y-%m-%d %H:%M"),
                'price': float(booking.total_price)
            }
            send_booking_confirmation(self.request.user, details)
        except Exception as e:
            print(f"Email failed to send: {e}")

    # 2. CUSTOM ACTIONS
    @action(detail=False, methods=['get'], url_path='my_tickets')
    def my_tickets(self, request):
        user = request.user
        bookings = Booking.objects.select_related(
            "passenger", "trip", "trip__driver", "trip__driver__profile"
        ).filter(passenger=user).order_by('-created_at')
        
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'], url_path='driver-requests') 
    def driver_requests(self, request):
        bookings = Booking.objects.filter(
            trip__driver=request.user
        ).exclude(
            passenger=request.user
        ).select_related('passenger', 'trip').order_by('-created_at')
        
        serializer = self.get_serializer(bookings, many=True)
        return Response(serializer.data)

    @action(detail=True, methods=['post'])
    def approve(self, request, pk=None):
        booking = self.get_object()
        
        if booking.trip.driver != request.user:
            return Response({'error': 'Only the driver can approve this request'}, status=403)
            
        if booking.status != 'pending':
            return Response({'error': f'Booking is already {booking.status}'}, status=400)

        booking.status = 'approved'
        booking.save()
        return Response({'message': 'Booking approved.', 'status': booking.status})

    @action(detail=True, methods=['post'])
    def reject(self, request, pk=None):
        booking = self.get_object()
        
        if booking.trip.driver != request.user:
            return Response({'error': 'Only the driver can reject this request'}, status=403)
            
        if booking.status == 'confirmed':
            return Response({'error': 'Cannot reject a paid booking'}, status=400)

        if booking.status == 'cancelled':
             return Response({'error': 'Booking is already cancelled'}, status=400)

        booking.status = 'cancelled'
        booking.save()

        # ✅ RESTORE SEATS LOGIC
        trip = booking.trip
        trip.available_seats += booking.seats_booked
        trip.save()
        
        return Response({'message': 'Booking rejected and seats restored.', 'status': booking.status})

# =====================================================
#  RATINGS
# =====================================================
class RatingViewSet(viewsets.ModelViewSet):
    queryset = Rating.objects.all()
    permission_classes = [IsAuthenticated]
    serializer_class = RatingSerializer

    def get_queryset(self):
        return Rating.objects.select_related("rater", "ratee").all()

    def perform_create(self, serializer):
        serializer.save(rater=self.request.user)

# =====================================================
#  PAYMENTS
# =====================================================
class PaymentViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated]

    def create(self, request):
        try:
            # 1. Get Data
            booking_id = request.data.get('booking_id') or request.data.get('booking')
            amount = request.data.get('amount')
            
            if not booking_id:
                return Response({'status': 'error', 'message': 'Booking ID is required'}, status=400)
            
            # 2. Get Booking & Driver Info
            booking = get_object_or_404(Booking, id=booking_id, passenger=request.user)
            driver_profile = booking.trip.driver.profile
            driver_phone = driver_profile.phone_number

            # 3. Validation
            if booking.status == 'pending':
                return Response({'status': 'error', 'message': 'Please wait for approval.'}, status=400)
                
            if booking.status == 'cancelled':
                return Response({'status': 'error', 'message': 'This booking was rejected.'}, status=400)

            if hasattr(booking, 'payment') or booking.status == 'confirmed':
                return Response({'status': 'error', 'message': 'Payment already exists'}, status=400)
            
            # 4. SIMULATE "PAY TO DRIVER" (No API Call)
            import uuid
            transaction_ref = f"MANUAL-{uuid.uuid4().hex[:8].upper()}"

            # 5. Create Transaction Record
            payment = PaymentTransaction.objects.create(
                booking=booking,
                amount=amount or booking.total_price,
                provider='mobile_money_transfer',
                provider_transaction_id=transaction_ref,
                status='confirmed',
                paid_at=timezone.now()
            )

            # 6. Confirm Booking
            booking.status = 'confirmed'
            booking.save()
            
            # 7. Return Success
            return Response({
                'status': 'success',
                'message': f'Please send money to driver: {driver_phone}',
                'transaction_id': transaction_ref,
                'booking_id': booking.id,
                'driver_phone': driver_phone,
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({'status': 'error', 'message': str(e)}, status=400)

    def list(self, request):
        payments = PaymentTransaction.objects.filter(
            booking__passenger=request.user
        ).select_related('booking', 'booking__trip').order_by('-created_at')
        serializer = PaymentSerializer(payments, many=True)
        return Response(serializer.data)

# =====================================================
#  EXTRA VIEWS
# =====================================================
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_payment_by_booking(request, booking_id):
    booking = get_object_or_404(Booking, id=booking_id, passenger=request.user)
    if not hasattr(booking, 'payment'):
        return Response({'error': 'No payment found'}, status=404)
    serializer = PaymentSerializer(booking.payment)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_payment_detail(request, payment_id):
    payment = get_object_or_404(PaymentTransaction, id=payment_id, booking__passenger=request.user)
    serializer = PaymentSerializer(payment)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_all_payments_admin(request):
    payments = PaymentTransaction.objects.all().select_related('booking').order_by('-created_at')
    serializer = PaymentSerializer(payments, many=True)
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def recommended_trips(request):
    base_query = Trip.objects.select_related('driver', 'driver__profile').filter(is_active=True)
    popular = base_query.annotate(book_count=Count('booking')).order_by('-book_count')[:5]
    soon = base_query.filter(departure_time__gte=timezone.now()).order_by('departure_time')[:5]
    combined = list(dict.fromkeys(list(popular) + list(soon)))
    serializer = TripSerializer(combined, many=True)
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
        return Response({'error': f'You already have a {existing.status} verification request'}, status=400)
    
    serializer = DriverVerificationSerializer(data=request.data, context={'request': request})
    if serializer.is_valid():
        verification = serializer.save()
        return Response({'message': 'Verification submitted successfully', 'verification_id': verification.id}, status=201)
    return Response(serializer.errors, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def check_verification_status(request):
    try:
        verification = DriverVerification.objects.filter(user=request.user).latest('submitted_at')
        return Response({
            'is_verified': verification.status == VerificationStatus.APPROVED,
            'status': verification.status,
            'submitted_at': verification.submitted_at,
            'reviewed_at': verification.reviewed_at,
            'rejection_reason': verification.rejection_reason if verification.status == VerificationStatus.REJECTED else None
        })
    except DriverVerification.DoesNotExist:
        return Response({'is_verified': False, 'status': None, 'message': 'No verification found'})

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def get_user_verification_details(request):
    verification = DriverVerification.objects.filter(user=request.user).first()
    if not verification:
        return Response({"message": "No verification found"}, status=404)
    serializer = DriverVerificationSerializer(verification, context={"request": request})
    return Response(serializer.data)

# =====================================================
#  ADMIN VERIFICATION
# =====================================================
@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_pending_verifications(request):
    pending_verifications = DriverVerification.objects.filter(status=VerificationStatus.PENDING).select_related('user').order_by('-submitted_at')
    serializer = DriverVerificationSerializer(pending_verifications, many=True, context={'request': request})
    return Response(serializer.data)

@api_view(['GET'])
@permission_classes([IsAdminUser])
def list_all_verifications(request):
    verifications = DriverVerification.objects.all().select_related('user').order_by('-submitted_at')
    serializer = DriverVerificationSerializer(verifications, many=True, context={'request': request})
    return Response(serializer.data)

@api_view(['POST'])
@permission_classes([IsAdminUser])
def approve_verification(request, verification_id):
    verification = get_object_or_404(DriverVerification, id=verification_id)
    if verification.status == VerificationStatus.APPROVED:
        return Response({'message': 'Already approved'}, status=400)
    
    verification.status = VerificationStatus.APPROVED
    verification.reviewed_at = timezone.now()
    verification.reviewed_by = request.user
    verification.save()
    serializer = DriverVerificationSerializer(verification, context={'request': request})
    return Response({'message': 'Approved', 'verification': serializer.data})

@api_view(['POST'])
@permission_classes([IsAdminUser])
def reject_verification(request, verification_id):
    verification = get_object_or_404(DriverVerification, id=verification_id)
    rejection_reason = request.data.get('rejection_reason', '').strip()
    if not rejection_reason:
        return Response({'error': 'Reason required'}, status=400)
    
    verification.status = VerificationStatus.REJECTED
    verification.rejection_reason = rejection_reason
    verification.reviewed_at = timezone.now()
    verification.reviewed_by = request.user
    verification.save()
    serializer = DriverVerificationSerializer(verification, context={'request': request})
    return Response({'message': 'Rejected', 'verification': serializer.data})

@api_view(['GET'])
@permission_classes([IsAdminUser])
def get_verification_details(request, verification_id):
    verification = get_object_or_404(DriverVerification, id=verification_id)
    serializer = DriverVerificationSerializer(verification, context={'request': request})
    return Response({
        'verification': serializer.data,
        'user': {
            'id': verification.user.id,
            'username': verification.user.username,
            'email': verification.user.email,
            'first_name': verification.user.first_name,
            'last_name': verification.user.last_name,
        }
    })

@api_view(['POST'])
@permission_classes([IsAdminUser])
def bulk_approve_verifications(request):
    verification_ids = request.data.get('verification_ids', [])
    if not verification_ids:
        return Response({'error': 'No IDs provided'}, status=400)
    
    count = DriverVerification.objects.filter(id__in=verification_ids, status=VerificationStatus.PENDING).update(
        status=VerificationStatus.APPROVED, reviewed_at=timezone.now(), reviewed_by=request.user
    )
    return Response({'message': f'{count} approved', 'count': count})

@api_view(['GET'])
@permission_classes([IsAdminUser])
def verification_statistics(request):
    stats = {
        'total': DriverVerification.objects.count(),
        'pending': DriverVerification.objects.filter(status=VerificationStatus.PENDING).count(),
        'approved': DriverVerification.objects.filter(status=VerificationStatus.APPROVED).count(),
        'rejected': DriverVerification.objects.filter(status=VerificationStatus.REJECTED).count(),
    }
    return Response(stats)


# =====================================================
# SUBSCRIPTION MANAGEMENT
# =====================================================

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_subscription_status(request):
    """Get current user's subscription status"""
    try:
        subscription, created = Subscription.objects.get_or_create(
            user=request.user,
            defaults={
                'status': 'trial',
                'trial_ends_at': timezone.now() + timedelta(days=30)
            }
        )
        
        # If newly created, set trial end date
        if created and not subscription.trial_ends_at:
            subscription.trial_ends_at = subscription.trial_started_at + timedelta(days=30)
            subscription.save()
        
        serializer = SubscriptionSerializer(subscription)
        return Response(serializer.data)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def process_subscription_payment(request):
    """Process subscription payment"""
    try:
        subscription = Subscription.objects.get(user=request.user)
        
        # Get payment details from request
        phone_number = request.data.get('phone_number')
        payment_method = request.data.get('payment_method', 'mobile_money')
        
        if not phone_number:
            return Response({'error': 'Phone number is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        # Get subscription price based on role
        price = subscription.get_subscription_price()
        
        # Simulate payment (you can integrate with actual payment gateway here)
        # For now, we'll just mark it as paid
        subscription.status = 'active'
        subscription.amount_paid = price
        subscription.payment_method = payment_method
        subscription.payment_transaction_id = f"SUB-{subscription.id}-{int(timezone.now().timestamp())}"
        subscription.last_payment_date = timezone.now()
        subscription.subscription_started_at = timezone.now()
        subscription.subscription_ends_at = timezone.now() + timedelta(days=30)  # 1 month subscription
        subscription.save()
        
        serializer = SubscriptionSerializer(subscription)
        return Response({
            'message': 'Subscription activated successfully',
            'subscription': serializer.data
        }, status=status.HTTP_200_OK)
        
    except Subscription.DoesNotExist:
        return Response({'error': 'Subscription not found'}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def check_subscription_access(request):
    """Check if user has active subscription (trial or paid)"""
    try:
        subscription, created = Subscription.objects.get_or_create(
            user=request.user,
            defaults={
                'status': 'trial',
                'trial_ends_at': timezone.now() + timedelta(days=30)
            }
        )
        
        if created and not subscription.trial_ends_at:
            subscription.trial_ends_at = subscription.trial_started_at + timedelta(days=30)
            subscription.save()
        
        is_active = subscription.is_active()
        days_remaining = subscription.get_days_remaining()
        
        return Response({
            'has_access': is_active,
            'days_remaining': days_remaining,
            'status': subscription.status,
            'subscription_price': subscription.get_subscription_price(),
            'user_role': request.user.profile.role if hasattr(request.user, 'profile') else 'passenger'
        })
    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)