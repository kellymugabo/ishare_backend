from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.utils import timezone
from datetime import timedelta
from django.db.models import Q

# Import your models
from .models import SubscriptionPlan, UserSubscription, SubscriptionTransaction
from .serializers import SubscriptionPlanSerializer, UserSubscriptionSerializer

# 1. List available plans (AUTOMATIC FILTERING)
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_plans(request):
    try:
        # 1. Detect User Role automatically
        user_role = request.user.profile.role # 'driver' or 'passenger'

        # 2. Filter plans automatically
        plans = SubscriptionPlan.objects.filter(
            Q(target_role=user_role) | Q(target_role='all')
        )
        
        serializer = SubscriptionPlanSerializer(plans, many=True)
        return Response(serializer.data)
        
    except Exception as e:
        return Response({"error": str(e)}, status=400)

# 2. Get My Current Subscription Status
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_my_subscription(request):
    # Use .first() to avoid crashes if multiple exist by mistake
    sub = UserSubscription.objects.filter(user=request.user).first()
    
    if sub:
        serializer = UserSubscriptionSerializer(sub)
        return Response(serializer.data)
    else:
        return Response({"message": "No active subscription", "is_valid": False})

# 3. Activate Subscription (For Free Trial)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def subscribe_user(request):
    plan_id = request.data.get('plan_id')
    
    try:
        plan = SubscriptionPlan.objects.get(id=plan_id)
    except SubscriptionPlan.DoesNotExist:
        return Response({"error": "Plan not found"}, status=404)

    # ✅ FIX: Calculate dates BEFORE saving to avoid "NOT NULL" crash
    new_start_date = timezone.now()
    new_end_date = timezone.now() + timedelta(days=plan.duration_days)

    # Use update_or_create to safely handle both "New" and "Renewal"
    sub, created = UserSubscription.objects.update_or_create(
        user=request.user,
        defaults={
            'plan': plan,
            'start_date': new_start_date,
            'end_date': new_end_date,
            'is_active': True
        }
    )

    return Response({
        "message": f"Successfully subscribed to {plan.name}",
        "expires_at": sub.end_date
    })

# 4. Submit Payment for Review (For Paid Plans)
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def submit_subscription_payment(request):
    plan_id = request.data.get('plan_id')
    transaction_id = request.data.get('transaction_id') 

    if not transaction_id:
        return Response({"error": "Transaction ID is required"}, status=400)

    try:
        plan = SubscriptionPlan.objects.get(id=plan_id)
        
        # Check if transaction ID already exists
        if SubscriptionTransaction.objects.filter(transaction_id=transaction_id).exists():
             return Response({"error": "This transaction ID has already been used."}, status=400)

        # Create the pending record
        SubscriptionTransaction.objects.create(
            user=request.user,
            plan=plan,
            amount=plan.price,
            transaction_id=transaction_id,
            status='pending'
        )
        
        return Response({"message": "Payment submitted! Waiting for approval."}, status=201)

    except SubscriptionPlan.DoesNotExist:
        return Response({"error": "Plan not found"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=400)