from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),

    # ✅ API Routes
    path('api/', include('api.urls')),

    # ✅ FORCE MEDIA SERVING (The Fix)
    # This tells Django: "Any URL starting with /media/ MUST be served from the MEDIA_ROOT folder."
    # We use re_path here because the standard static() function disables itself when DEBUG=False.
    re_path(r'^media/(?P<path>.*)$', serve, {
        'document_root': settings.MEDIA_ROOT,
    }),
]