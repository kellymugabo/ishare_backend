from django.urls import path
from . import views

urlpatterns = [
    # 1. Get Plans
    # URL: /api/subscriptions/plans/
    path('plans/', views.get_plans, name='get_plans'),
    
    # 2. Get My Status (Matches Flutter: /subscriptions/me/)
    # URL: /api/subscriptions/me/
    path('me/', views.get_my_subscription, name='my_subscription'),
    
    # 3. Free Trial Activation
    # URL: /api/subscriptions/subscribe/
    path('subscribe/', views.subscribe_user, name='subscribe_user'),
    
    # 4. Paid Plan Submission
    # URL: /api/subscriptions/pay/
    path('pay/', views.submit_subscription_payment, name='submit_subscription_payment'),
]