from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.views.static import serve
from core.views import fix_all_profiles, force_delete_user # <--- Import it

# ✅ IMPORT THE REPAIR FUNCTION
from core.views import fix_all_profiles 

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # ✅ Subscriptions App
    path('api/subscriptions/', include('subscriptions.urls')),

    # ✅ CORE API Routes (Trips, Bookings, Auth, Profile)
    path('api/', include('core.urls')),

    # ✅ REPAIR TOOL (Click this link to fix your database)
    path('fix-profiles-now/', fix_all_profiles),
    # ✅ FORCE DELETE LINK
    path('force-delete/<str:username>/', force_delete_user),

    # ✅ FORCE MEDIA SERVING (For Railway)
    re_path(r'^media/(?P<path>.*)$', serve, {
        'document_root': settings.MEDIA_ROOT,
    }),
]