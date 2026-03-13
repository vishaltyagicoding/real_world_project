# Task Manager Backend - Django REST API

## Features
- JWT Authentication with refresh tokens
- Custom User model with email login
- Task CRUD operations with filtering
- Redis caching for performance
- Custom middleware for request logging
- Celery for background tasks
- Custom admin panel
- Proper permissions and security

## Setup Instructions

### 1. Create Virtual Environment
```bash
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Environment Variables
Copy `.env.example` to `.env` and update values:
```bash
copy .env.example .env
```

### 4. Run Migrations
```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Create Superuser
```bash
python manage.py createsuperuser
```

### 6. Run Development Server
```bash
python manage.py runserver
```

### 7. Run Redis (Optional)
```bash
redis-server
```

### 8. Run Celery Worker (Optional)
```bash
celery -A config worker -l info
```

## API Endpoints

### Authentication
- POST `/api/auth/register/` - Register new user
- POST `/api/auth/login/` - Login (get JWT tokens)
- POST `/api/auth/logout/` - Logout (blacklist token)
- POST `/api/auth/token/refresh/` - Refresh access token
- GET `/api/auth/profile/` - Get user profile
- PUT `/api/auth/profile/` - Update user profile
- POST `/api/auth/change-password/` - Change password

### Tasks
- GET `/api/tasks/` - List all tasks (with filters)
- POST `/api/tasks/` - Create new task
- GET `/api/tasks/{id}/` - Get task detail
- PUT `/api/tasks/{id}/` - Update task
- DELETE `/api/tasks/{id}/` - Delete task
- POST `/api/tasks/{id}/complete/` - Mark task as completed
- POST `/api/tasks/{id}/add_comment/` - Add comment to task
- GET `/api/tasks/statistics/` - Get task statistics

### Query Parameters
- `?status=pending` - Filter by status
- `?priority=high` - Filter by priority
- `?search=keyword` - Search in title/description
- `?ordering=-created_at` - Order results

## Project Structure
```
backend/
├── config/              # Project configuration
│   ├── settings.py      # Django settings
│   ├── urls.py          # Main URL configuration
│   ├── celery.py        # Celery configuration
│   ├── wsgi.py          # WSGI configuration
│   └── asgi.py          # ASGI configuration
├── apps/                # Django applications
│   ├── accounts/        # User authentication
│   │   ├── models.py    # Custom User model
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── admin.py     # Custom admin
│   │   └── urls.py
│   ├── tasks/           # Task management
│   │   ├── models.py    # Task & Comment models
│   │   ├── serializers.py
│   │   ├── views.py
│   │   ├── admin.py     # Custom admin
│   │   ├── permissions.py
│   │   ├── signals.py   # Cache invalidation
│   │   ├── tasks.py     # Celery tasks
│   │   └── urls.py
│   └── core/            # Core utilities
│       ├── middleware.py # Custom middleware
│       └── apps.py
├── media/               # User uploaded files
├── static/              # Static files
├── manage.py            # Django management
└── requirements.txt     # Python dependencies
```

## Admin Panel
Access at: http://localhost:8000/admin/
- Custom user management
- Task management with inline comments
- Color-coded status and priority badges
- Advanced filtering and search

## Technologies Used
- Django 4.2
- Django REST Framework
- JWT Authentication (simplejwt)
- Redis for caching
- Celery for background tasks
- PostgreSQL ready (SQLite for dev)
- CORS headers for frontend integration
