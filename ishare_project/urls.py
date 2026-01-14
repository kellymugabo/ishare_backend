from django.contrib import admin
from django.urls import path, include
from django.http import HttpResponse
from django.contrib.auth.models import User

# --- 🛠️ TEMPORARY VIEW TO CREATE SUPERUSER ---
def create_admin_view(request):
    try:
        # Check if 'admin' exists
        if not User.objects.filter(username='admin').exists():
            # Create the superuser
            User.objects.create_superuser('admin', 'admin@ishare.com', 'AdminPass123!')
            return HttpResponse("<h1>✅ Success!</h1><p>Superuser 'admin' created!</p><p>Password: <b>AdminPass123!</b></p>")
        else:
            return HttpResponse("<h1>ℹ️ Info</h1><p>Superuser 'admin' already exists.</p>")
    except Exception as e:
        return HttpResponse(f"<h1>❌ Error</h1><p>{str(e)}</p>")
# ------------------------------------------

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('ishare_app.urls')),
    path('api/subscriptions/', include('subscriptions.urls')),
    
    # 🔓 The Secret Backdoor Link
    path('make-me-admin/', create_admin_view),
]