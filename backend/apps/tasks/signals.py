from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.core.cache import cache
from .models import Task

@receiver(post_save, sender=Task)
def clear_task_cache_on_save(sender, instance, **kwargs):
    """Clear cache when task is created or updated"""
    cache_key = f'user_tasks_{instance.user.id}'
    cache.delete(cache_key)

@receiver(post_delete, sender=Task)
def clear_task_cache_on_delete(sender, instance, **kwargs):
    """Clear cache when task is deleted"""
    cache_key = f'user_tasks_{instance.user.id}'
    cache.delete(cache_key)
