from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.core.cache import cache
from django.utils import timezone
from .models import Task, TaskComment
from .serializers import TaskSerializer, TaskCreateUpdateSerializer, TaskCommentSerializer
from .permissions import IsTaskOwner

class TaskViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsTaskOwner]
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['title', 'description']
    ordering_fields = ['created_at', 'due_date', 'priority', 'status']
    ordering = ['-created_at']
    
    def _get_cache_key(self):
        """Generate cache key for current user"""
        return f'user_tasks_{self.request.user.id}'
    
    def _clear_cache(self):
        """Clear cached tasks for current user"""
        cache_key = self._get_cache_key()
        cache.delete(cache_key)
    
    def get_queryset(self):
        # Don't use cache for now - it causes stale data issues
        # In production, implement proper cache invalidation
        queryset = Task.objects.filter(user=self.request.user).select_related('user').prefetch_related('comments')
        
        status_filter = self.request.query_params.get('status', None)
        priority_filter = self.request.query_params.get('priority', None)
        
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        if priority_filter:
            queryset = queryset.filter(priority=priority_filter)
        
        return queryset
    
    def get_serializer_class(self):
        if self.action in ['create', 'update', 'partial_update']:
            return TaskCreateUpdateSerializer
        return TaskSerializer
    
    def perform_create(self, serializer):
        serializer.save(user=self.request.user)
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        task = serializer.save(user=request.user)
        
        # Clear cache after creating task
        self._clear_cache()
        
        # Return full task data with user information
        response_serializer = TaskSerializer(task)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        task = serializer.save()
        
        # Clear cache after updating task
        self._clear_cache()
        
        # Return full task data with user information
        response_serializer = TaskSerializer(task)
        return Response(response_serializer.data)
    
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        self.perform_destroy(instance)
        
        # Clear cache after deleting task
        self._clear_cache()
        
        return Response(status=status.HTTP_204_NO_CONTENT)
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        task = self.get_object()
        task.status = 'completed'
        task.completed_at = timezone.now()
        task.save()
        
        # Clear cache after completing task
        self._clear_cache()
        
        return Response({'status': 'Task marked as completed'})
    
    @action(detail=True, methods=['post'])
    def add_comment(self, request, pk=None):
        task = self.get_object()
        serializer = TaskCommentSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save(user=request.user, task=task)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['get'])
    def statistics(self, request):
        tasks = self.get_queryset()
        stats = {
            'total': tasks.count(),
            'pending': tasks.filter(status='pending').count(),
            'in_progress': tasks.filter(status='in_progress').count(),
            'completed': tasks.filter(status='completed').count(),
            'cancelled': tasks.filter(status='cancelled').count(),
            'overdue': sum(1 for task in tasks if task.is_overdue),
        }
        return Response(stats)
