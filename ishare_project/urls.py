from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.views.static import serve
# ✅ Added the Refresh View import
from rest_framework_simplejwt.views import TokenRefreshView 
from core.views import fix_all_profiles, force_delete_user

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # ✅ FIX: Added JWT Refresh endpoint for Flutter
    path('api/auth/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),

    # ✅ Subscriptions App
    path('api/subscriptions/', include('subscriptions.urls')),

    # ✅ CORE API Routes (Trips, Bookings, Auth, Profile)
    path('api/', include('core.urls')),

    # ✅ REPAIR TOOLS (Useful for your IntegrityErrors)
    path('fix-profiles-now/', fix_all_profiles),
    path('force-delete/<str:username>/', force_delete_user),

    # ✅ MEDIA SERVING
    # Keep this only for local development. On DigitalOcean, Spaces handles this.
]

if settings.DEBUG:
    urlpatterns += [
        re_path(r'^media/(?P<path>.*)$', serve, {
            'document_root': settings.MEDIA_ROOT,
        }),
    ]