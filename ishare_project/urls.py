from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework_simplejwt.views import TokenRefreshView
from api.views import CustomTokenObtainPairView, RegisterViewSet

urlpatterns = [
    path('admin/', admin.site.urls),

    # 1. YOUR CUSTOM AUTH
    path('auth/token/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/register/', RegisterViewSet.as_view({'post': 'create'}), name='register'),

    # 2. MAIN API
    path('api/', include('api.urls')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)