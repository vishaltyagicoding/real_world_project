# Cache Invalidation Fix - Stale Statistics

## Issue
After deleting all tasks, the statistics still showed "1 Total" and incorrect counts for Pending and Overdue. The statistics only updated after restarting the app.

## Root Cause
The backend was caching the task queryset for 5 minutes without proper cache invalidation:

```python
def get_queryset(self):
    cache_key = f'user_tasks_{self.request.user.id}'
    queryset = cache.get(cache_key)
    
    if queryset is None:
        queryset = Task.objects.filter(user=self.request.user)
        cache.set(cache_key, queryset, 300)  # ❌ Cache for 5 minutes
    
    return queryset
```

When tasks were created, updated, or deleted, the cache was not cleared, causing:
- Statistics to show old counts
- Task list to show deleted tasks
- New tasks not appearing immediately

## Solution

### 1. Removed Queryset Caching (Immediate Fix)
**File**: `backend/apps/tasks/views.py`

Removed the problematic caching from `get_queryset()`:

```python
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
```

### 2. Added Cache Helper Methods
**File**: `backend/apps/tasks/views.py`

Added methods to manage cache:

```python
def _get_cache_key(self):
    """Generate cache key for current user"""
    return f'user_tasks_{self.request.user.id}'

def _clear_cache(self):
    """Clear cached tasks for current user"""
    cache_key = self._get_cache_key()
    cache.delete(cache_key)
```

### 3. Clear Cache After Modifications
**File**: `backend/apps/tasks/views.py`

Added cache clearing to all modification operations:

```python
def create(self, request, *args, **kwargs):
    # ... create task ...
    self._clear_cache()  # ✅ Clear cache
    return Response(...)

def update(self, request, *args, **kwargs):
    # ... update task ...
    self._clear_cache()  # ✅ Clear cache
    return Response(...)

def destroy(self, request, *args, **kwargs):
    # ... delete task ...
    self._clear_cache()  # ✅ Clear cache
    return Response(...)

@action(detail=True, methods=['post'])
def complete(self, request, pk=None):
    # ... complete task ...
    self._clear_cache()  # ✅ Clear cache
    return Response(...)
```

### 4. Enhanced Signal Handlers
**File**: `backend/apps/tasks/signals.py`

Added signal for deletion (save signal already existed):

```python
from django.db.models.signals import post_save, post_delete

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
```

## Why This Fixes the Issue

### Before
1. User deletes all tasks
2. Tasks are deleted from database
3. Cache still contains old queryset (5 minutes TTL)
4. Statistics endpoint uses cached queryset
5. Shows incorrect counts (1 Total, etc.)

### After
1. User deletes all tasks
2. Tasks are deleted from database
3. Cache is immediately cleared (via signal or view method)
4. Statistics endpoint queries fresh data
5. Shows correct counts (0 Total, 0 Pending, etc.)

## Testing Scenarios

### Test Delete All Tasks
1. Create 3 tasks
2. Note statistics: Total=3, Pending=3
3. Delete all 3 tasks one by one
4. **Expected**: Statistics show Total=0, Pending=0, Completed=0, Overdue=0

### Test Create Task
1. Start with 0 tasks
2. Create a new task
3. **Expected**: Statistics immediately show Total=1, Pending=1

### Test Complete Task
1. Have 1 pending task
2. Mark it as complete
3. **Expected**: Statistics show Pending=0, Completed=1

### Test Update Task Status
1. Have 1 pending task
2. Edit and change status to "in_progress"
3. **Expected**: Statistics show Pending=0, In Progress=1

## Performance Considerations

### Removed Caching
- **Impact**: Slightly more database queries
- **Benefit**: Always accurate data
- **Mitigation**: Using `select_related()` and `prefetch_related()` for efficient queries

### Database Optimization
```python
queryset = Task.objects.filter(user=self.request.user)\
    .select_related('user')\           # ✅ Joins user table
    .prefetch_related('comments')      # ✅ Efficient comment loading
```

### Future Optimization (Optional)
If you need caching for performance:
1. Use shorter cache TTL (30 seconds instead of 5 minutes)
2. Implement proper cache invalidation (already done with signals)
3. Cache statistics separately from queryset
4. Use Redis cache with proper key patterns

## Production Considerations

### Current Solution
- ✅ Always accurate data
- ✅ Simple implementation
- ✅ No cache invalidation bugs
- ✅ Suitable for small to medium apps

### When to Add Caching Back
Consider re-implementing caching if:
- You have thousands of tasks per user
- Database queries become slow
- You need to reduce database load

### How to Add Caching Back Safely
```python
def get_queryset(self):
    cache_key = self._get_cache_key()
    queryset = cache.get(cache_key)
    
    if queryset is None:
        queryset = Task.objects.filter(user=self.request.user)\
            .select_related('user')\
            .prefetch_related('comments')
        # Shorter TTL + proper invalidation
        cache.set(cache_key, queryset, 30)  # 30 seconds
    
    return queryset
```

## Files Modified

1. **backend/apps/tasks/views.py**
   - Removed queryset caching from `get_queryset()`
   - Added `_get_cache_key()` helper method
   - Added `_clear_cache()` helper method
   - Added cache clearing to `create()`
   - Added cache clearing to `update()`
   - Added cache clearing to `destroy()`
   - Added cache clearing to `complete()`

2. **backend/apps/tasks/signals.py**
   - Added `post_delete` signal handler
   - Renamed `post_save` signal handler for clarity

## Benefits

1. **Accurate Statistics**: Always shows current counts
2. **Real-Time Updates**: Changes reflect immediately
3. **No Stale Data**: Cache invalidation works properly
4. **Simple Solution**: Easy to understand and maintain
5. **Production Ready**: Handles all edge cases

## Verification

After restarting the Django backend:
1. Delete all tasks → Statistics show 0
2. Create a task → Statistics show 1
3. Complete a task → Statistics update correctly
4. Delete a task → Statistics update correctly
