"""
Django settings for ishare_project project.
Updated for Railway Deployment
"""
import os
import dj_database_url
from pathlib import Path
from datetime import timedelta

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('SECRET_KEY', 'django-insecure-your-secret-key-here-change-this-in-production')

# ✅ SECURITY: Smart logic for Production vs Local
# On Railway, we usually set an environment variable specifically, or rely on DEBUG=False
# If 'RAILWAY_ENVIRONMENT' is present, we are in production.
if 'RAILWAY_ENVIRONMENT' in os.environ:
    DEBUG = False
else:
    DEBUG = True

# ✅ ALLOWED HOSTS
ALLOWED_HOSTS = ['*']

# ✅ CSRF TRUSTED ORIGINS (CRITICAL FOR RAILWAY)
# Django 4.0+ requires this for HTTPS sites. 
# This allows the Railway domain to send data to your server.
CSRF_TRUSTED_ORIGINS = [
    'https://*.railway.app',
    'https://*.up.railway.app',
]

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    
    # Third party apps
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'rest_framework.authtoken',
    'corsheaders', 
    
    # Your apps
    'api',
    # 'trips',    # Ensure these are added if they are separate apps
    # 'ratings',
    # 'profiles',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware', # ✅ Production Static Files
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',      # ✅ CORS (Critical for Flutter)
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'ishare_project.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'ishare_project.wsgi.application'

# ✅ DATABASE CONFIGURATION
# It tries to use the Production Database first (from env variable DATABASE_URL).
# If that fails (e.g., on your laptop), it falls back to SQLite.
DATABASES = {
    'default': dj_database_url.config(
        default='sqlite:///' + os.path.join(BASE_DIR, 'db.sqlite3'),
        conn_max_age=600
    )
}

# Password validation
AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Internationalization
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Africa/Kigali'  # Rwanda timezone
USE_I18N = True
USE_TZ = True

# ✅ STATIC FILES (CSS, JavaScript, Images)
STATIC_URL = 'static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'staticfiles')

# Enable WhiteNoise's compression and caching support
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

# ✅ MEDIA FILES (User Uploads like Car Photos)
# Note: On Railway/Heroku, local files (Media) are deleted when the server restarts.
# For production, you eventually need AWS S3 or Cloudinary. For now, this works for testing.
MEDIA_URL = '/media/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'media')

# Default primary key field type
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# CORS settings - Fixed for Flutter Web
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:8000",
    "http://localhost:*",  # Flutter web dev server
    "http://127.0.0.1:*",  # Flutter web dev server
]

# ✅ CRITICAL: Allow all origins for web (Flutter web uses dynamic ports)
# This is safe because we're using JWT tokens for authentication
CORS_ALLOW_ALL_ORIGINS = True

# ✅ Allow credentials (cookies, authorization headers)
CORS_ALLOW_CREDENTIALS = True

# ✅ Allowed HTTP methods
CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

# ✅ Allowed headers (including Authorization for JWT)
CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',  # ✅ Critical for JWT Bearer tokens
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
    'access-control-allow-origin',  # ✅ Additional header support
    'access-control-allow-methods',
    'access-control-allow-headers',
]

# ✅ Expose headers to the client
CORS_EXPOSE_HEADERS = [
    'content-type',
    'authorization',
]

# ✅ Preflight cache duration (in seconds)
CORS_PREFLIGHT_MAX_AGE = 86400  # 24 hours

# REST Framework settings
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ],
    'DEFAULT_PERMISSION_CLASSES': [
        'rest_framework.permissions.AllowAny',
    ],
    'DEFAULT_PARSER_CLASSES': [
        'rest_framework.parsers.JSONParser',
        'rest_framework.parsers.MultiPartParser',
        'rest_framework.parsers.FormParser',
    ],
}

# JWT Settings
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(days=1),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
    'ROTATE_REFRESH_TOKENS': True,
    'BLACKLIST_AFTER_ROTATION': True,
    'UPDATE_LAST_LOGIN': True,
    'ALGORITHM': 'HS256',
    'SIGNING_KEY': SECRET_KEY,
    'AUTH_HEADER_TYPES': ('Bearer',),
    'AUTH_HEADER_NAME': 'HTTP_AUTHORIZATION',
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
    'AUTH_TOKEN_CLASSES': ('rest_framework_simplejwt.tokens.AccessToken',),
    'TOKEN_TYPE_CLAIM': 'token_type',
}

# 📧 EMAIL CONFIGURATION
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = 'smtp.gmail.com'
EMAIL_PORT = 587
EMAIL_USE_TLS = True
EMAIL_HOST_USER = 'murenzicharles24@gmail.com' 
# ✅ SECURITY UPDATE: Use Environment Variable
EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD') 
DEFAULT_FROM_EMAIL = 'ISHARE Support <murenzicharles24@gmail.com>'