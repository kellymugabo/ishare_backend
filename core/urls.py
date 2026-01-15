from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    RegisterViewSet, CustomTokenObtainPairView, 
    TripViewSet, BookingViewSet, RatingViewSet, UserProfileViewSet,
    PaymentViewSet, 
    submit_driver_verification, check_verification_status,
    ForgotPasswordView, ResetPasswordView
)

# 1. Automatic Router
router = DefaultRouter()

# ✅ ADDED basename='trip' (Fixes the AssertionError)
router.register(r'trips', TripViewSet, basename='trip')

# ✅ ADDED basename='booking' (Fixes the AssertionError)
router.register(r'bookings', BookingViewSet, basename='booking')

# These usually work fine, but explicit names are safer
router.register(r'profiles', UserProfileViewSet, basename='userprofile')
router.register(r'ratings', RatingViewSet, basename='rating')
router.register(r'payments', PaymentViewSet, basename='payments')

urlpatterns = [
    # 2. Router URLs
    path('', include(router.urls)),

    # 3. Auth URLs
    path('register/', RegisterViewSet.as_view({'post': 'create'}), name='register'),
    path('auth/token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    
    # 4. Password Reset
    path('auth/forgot-password/', ForgotPasswordView.as_view(), name='forgot-password'),
    path('auth/reset-password/', ResetPasswordView.as_view(), name='reset-password'),

    # 5. Driver Verification URLs
    path('driver-verification/submit/', submit_driver_verification, name='submit-verification'),
    path('driver-verification/status/', check_verification_status, name='check-verification'),
]