from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView
from .views import (
    # Auth Views
    CustomTokenObtainPairView, 
    RegisterViewSet, 
    ForgotPasswordView, 
    ResetPasswordView,
    
    # Core ViewSets
    UserProfileViewSet, 
    TripViewSet, 
    BookingViewSet, 
    RatingViewSet, 
    PaymentViewSet,
    
    # Extra Views
    recommended_trips,
    get_payment_by_booking,
    get_payment_detail,
    get_all_payments_admin,
    
    # Verification Views
    submit_driver_verification,
    check_verification_status,
    get_user_verification_details,
    
    # Admin Views
    list_pending_verifications,
    approve_verification,
    reject_verification,
    get_verification_details,
    list_all_verifications,
    bulk_approve_verifications,
    verification_statistics,
    
    # Subscription Views
    get_subscription_status,
    process_subscription_payment,
    check_subscription_access
)

# =====================================================
# 1. ROUTER SETUP (ViewSets)
# =====================================================
router = DefaultRouter()
router.register(r'register', RegisterViewSet, basename='register')
router.register(r'profiles', UserProfileViewSet)
router.register(r'trips', TripViewSet, basename='trips')
router.register(r'bookings', BookingViewSet, basename='bookings')
router.register(r'ratings', RatingViewSet)
router.register(r'payments', PaymentViewSet, basename='payments')

urlpatterns = [
    # ==================================
    # 2. AUTHENTICATION (Specific paths first)
    # ==================================
    path('auth/token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('auth/reset-password/', ResetPasswordView.as_view(), name='reset-password'),

    # ==================================
    # 3. CUSTOM ACTIONS (Must be BEFORE router)
    # ==================================
    # Trips
    path('trips/recommended/', recommended_trips, name='recommended-trips'),

    # Payments
    path('payments/booking/<int:booking_id>/', get_payment_by_booking, name='payment_by_booking'),
    path('payments/detail/<int:payment_id>/', get_payment_detail, name='payment_detail'),
    path('payments/admin/all/', get_all_payments_admin, name='all_payments_admin'),

    # Driver Verification
    path('driver/verify/', submit_driver_verification, name='submit_verification'),
    path('driver/verification-status/', check_verification_status, name='verification_status'),
    path('driver/my-verification/', get_user_verification_details, name='user_verification_details'),

    # Admin Verification
    path('admin/verifications/pending/', list_pending_verifications, name='list_pending_verifications'),
    path('admin/verifications/all/', list_all_verifications, name='list_all_verifications'),
    path('admin/verifications/<int:verification_id>/approve/', approve_verification, name='approve_verification'),
    path('admin/verifications/<int:verification_id>/reject/', reject_verification, name='reject_verification'),
    path('admin/verifications/<int:verification_id>/', get_verification_details, name='get_verification_details'),
    path('admin/verifications/bulk-approve/', bulk_approve_verifications, name='bulk_approve_verifications'),
    path('admin/verifications/stats/', verification_statistics, name='verification_statistics'),

    # Subscription Management
    path('subscription/status/', get_subscription_status, name='subscription_status'),
    path('subscription/pay/', process_subscription_payment, name='subscription_payment'),
    path('subscription/check/', check_subscription_access, name='check_subscription_access'),

    # ==================================
    # 4. ROUTER ENDPOINTS (Catch-all last)
    # ==================================
    path('', include(router.urls)),
]