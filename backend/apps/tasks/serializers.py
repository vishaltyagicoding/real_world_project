from rest_framework import serializers
from .models import Task, TaskComment
from apps.accounts.serializers import UserSerializer

class TaskCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    
    class Meta:
        model = TaskComment
        fields = ['id', 'task', 'user', 'content', 'created_at', 'updated_at']
        read_only_fields = ['id', 'user', 'created_at', 'updated_at']

class TaskSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    comments = TaskCommentSerializer(many=True, read_only=True)
    is_overdue = serializers.BooleanField(read_only=True)
    
    class Meta:
        model = Task
        fields = ['id', 'title', 'description', 'status', 'priority', 'user', 
                  'due_date', 'completed_at', 'created_at', 'updated_at', 
                  'comments', 'is_overdue']
        read_only_fields = ['id', 'user', 'completed_at', 'created_at', 'updated_at']
    
    def validate_due_date(self, value):
        from django.utils import timezone
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date cannot be in the past")
        return value

class TaskCreateUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Task
        fields = ['title', 'description', 'status', 'priority', 'due_date']
    
    def validate_due_date(self, value):
        from django.utils import timezone
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date cannot be in the past")
        return value
