# Deployment Guide - Task Manager App

## Issue Fixed
Fixed the login error: "type 'Null' is not a subtype of type 'Map<String, dynamic>'"

### Root Cause
The backend login endpoint was using Django's default `TokenObtainPairView` which only returns JWT tokens without user data. The Flutter app expected a response containing user information.

### Solution
Created a custom `LoginView` that returns both JWT tokens and user data in the response format:
```json
{
  "access": "jwt_access_token",
  "refresh": "jwt_refresh_token",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username",
    "first_name": "First",
    "last_name": "Last",
    "phone": null,
    "avatar": null,
    "date_joined": "2024-01-01T00:00:00Z"
  }
}
```

## Production Deployment Checklist

### Backend (Django)

1. **Environment Variables** - Update `.env` file:
   ```env
   DEBUG=False
   SECRET_KEY=your-strong-production-secret-key
   ALLOWED_HOSTS=your-domain.com,www.your-domain.com
   
   # Database
   DB_NAME=production_db
   DB_USER=production_user
   DB_PASSWORD=strong_password
   DB_HOST=your-db-host
   DB_PORT=5432
   
   # Redis
   REDIS_HOST=your-redis-host
   REDIS_PORT=6379
   
   # JWT Token Lifetimes (in minutes)
   JWT_ACCESS_TOKEN_LIFETIME=60
   JWT_REFRESH_TOKEN_LIFETIME=1440
   ```

2. **Update CORS Settings** in `backend/config/settings.py`:
   ```python
   CORS_ALLOWED_ORIGINS = [
       "https://your-domain.com",
       "https://www.your-domain.com",
   ]
   ```

3. **Run Migrations**:
   ```bash
   cd backend
   python manage.py migrate
   python manage.py collectstatic --noinput
   ```

4. **Create Superuser**:
   ```bash
   python manage.py createsuperuser
   ```

5. **Start Services**:
   ```bash
   # Using Gunicorn (recommended)
   gunicorn config.wsgi:application --bind 0.0.0.0:8000 --workers 4
   
   # Start Celery worker
   celery -A config worker -l info
   
   # Start Celery beat (for scheduled tasks)
   celery -A config beat -l info
   ```

### Frontend (Flutter)

1. **Update API Configuration** in `frontend/lib/config/api_config.dart`:
   ```dart
   static const bool isDevelopment = false;  // Set to false for production
   static const String productionUrl = 'https://api.your-domain.com/api';
   ```

2. **Build for Production**:
   
   **Android**:
   ```bash
   cd frontend
   flutter build apk --release
   # Or for app bundle
   flutter build appbundle --release
   ```
   
   **iOS**:
   ```bash
   cd frontend
   flutter build ios --release
   ```

3. **Test Production Build**:
   - Install the release APK on a physical device
   - Test all authentication flows
   - Verify API connectivity

## Development Setup

### Backend
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver 0.0.0.0:8000
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Testing on Physical Device

1. **Find your computer's local IP**:
   - Windows: `ipconfig` (look for IPv4 Address)
   - Mac/Linux: `ifconfig` or `ip addr`

2. **Update development URL** in `frontend/lib/config/api_config.dart`:
   ```dart
   static const String developmentUrl = 'http://YOUR_IP:8000/api';
   ```

3. **Ensure backend allows your IP** in `backend/config/settings.py`:
   ```python
   ALLOWED_HOSTS = ['localhost', '127.0.0.1', 'YOUR_IP']
   ```

4. **Connect device to same WiFi network** as your development machine

## Security Notes

- Always use HTTPS in production
- Keep SECRET_KEY secure and never commit to version control
- Use strong database passwords
- Enable Django's security middleware in production
- Regularly update dependencies
- Implement rate limiting for API endpoints
- Use environment variables for sensitive configuration

## Monitoring

- Check Django logs: `backend/logs/django.log`
- Monitor Celery tasks
- Set up error tracking (e.g., Sentry)
- Monitor API response times
- Track user authentication failures

## Troubleshooting

### Login fails with "Invalid credentials"
- Verify user exists in database
- Check email and password are correct
- Ensure user account is active

### "Connection refused" error
- Verify backend is running
- Check firewall settings
- Confirm correct IP address and port
- Ensure device is on same network (development)

### Token expired errors
- Check JWT token lifetime settings
- Verify token refresh logic is working
- Clear app data and login again

## Support

For issues or questions, check:
- Backend logs: `backend/logs/django.log`
- Flutter logs: `flutter logs`
- Django admin: `http://your-domain.com/admin/`
