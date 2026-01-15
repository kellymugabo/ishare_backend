from rest_framework import permissions

class IsDriverOrReadOnly(permissions.BasePermission):
    """
    Custom permission to only allow Drivers to create/edit trips.
    Passengers can only VIEW (read) trips.
    """
    def has_permission(self, request, view):
        # 1. Allow GET, HEAD, OPTIONS requests for everyone (Passengers need to see trips)
        if request.method in permissions.SAFE_METHODS:
            return True

        # 2. Check if the user is authenticated and has the role 'driver'
        return (
            request.user 
            and request.user.is_authenticated 
            and request.user.role == 'driver'
        )