from celery import shared_task
from django.core.mail import send_mail
from django.conf import settings

@shared_task
def send_task_reminder(task_id):
    """
    Send reminder email for tasks that are due soon
    """
    from apps.tasks.models import Task
    try:
        task = Task.objects.get(id=task_id)
        # Email sending logic here
        return f"Reminder sent for task: {task.title}"
    except Task.DoesNotExist:
        return "Task not found"

@shared_task
def cleanup_old_tasks():
    """
    Cleanup completed tasks older than 90 days
    """
    from apps.tasks.models import Task
    from django.utils import timezone
    from datetime import timedelta
    
    cutoff_date = timezone.now() - timedelta(days=90)
    deleted_count = Task.objects.filter(
        status='completed',
        completed_at__lt=cutoff_date
    ).delete()[0]
    
    return f"Deleted {deleted_count} old tasks"
