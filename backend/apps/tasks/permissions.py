from rest_framework import permissions

class IsTaskOwner(permissions.BasePermission):
    """
    Custom permission to only allow owners of a task to edit it.
    """
    def has_object_permission(self, request, view, obj):
        return obj.user == request.user
