from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # ✅ Subscriptions App
    path('api/subscriptions/', include('subscriptions.urls')),

    # ✅ CORE API Routes (Trips, Bookings, Auth, Profile)
    # This now points to the new 'core' app we created to fix the naming conflict.
    path('api/', include('core.urls')),

    # ✅ FORCE MEDIA SERVING (For Railway)
    # This serves uploaded images (like profile pics) correctly in production.
    re_path(r'^media/(?P<path>.*)$', serve, {
        'document_root': settings.MEDIA_ROOT,
    }),
]

# Force update routing