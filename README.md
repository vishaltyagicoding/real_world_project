# Real-World Task Manager - Flutter + Django

A production-grade task management application demonstrating real-world architecture patterns, authentication, and best practices for both Flutter (frontend) and Django (backend).

## 🎯 Project Overview

This project is designed as a comprehensive learning resource for building real-world applications with:
- **Backend**: Django REST Framework with JWT authentication, Redis caching, Celery, custom middleware
- **Frontend**: Flutter with Provider state management, secure token storage, proper API integration

## 🏗️ Architecture

### Backend (Django)
```
backend/
├── config/              # Project configuration
│   ├── settings.py      # Django settings with production patterns
│   ├── urls.py          # URL routing
│   ├── celery.py        # Celery configuration
│   └── wsgi.py/asgi.py  # Server configurations
├── apps/
│   ├── accounts/        # User authentication & management
│   │   ├── models.py    # Custom User model
│   │   ├── serializers.py
│   │   ├── views.py     # JWT auth views
│   │   └── admin.py     # Custom admin
│   ├── tasks/           # Task management
│   │   ├── models.py    # Task & Comment models
│   │   ├── views.py     # ViewSets with caching
│   │   ├── permissions.py
│   │   ├── signals.py   # Cache invalidation
│   │   └── tasks.py     # Celery tasks
│   └── core/            # Core utilities
│       └── middleware.py # Request logging
└── requirements.txt
```

### Frontend (Flutter)
```
frontend/
├── lib/
│   ├── config/          # API configuration
│   ├── models/          # Data models
│   ├── providers/       # State management (Provider)
│   ├── screens/         # UI screens
│   ├── services/        # API & storage services
│   ├── widgets/         # Reusable widgets
│   └── main.dart
└── pubspec.yaml
```

## 🚀 Features

### Authentication
- ✅ JWT token-based authentication
- ✅ Automatic token refresh
- ✅ Secure token storage (flutter_secure_storage)
- ✅ Custom User model with email login
- ✅ Password change functionality

### Task Management
- ✅ CRUD operations for tasks
- ✅ Task status (Pending, In Progress, Completed, Cancelled)
- ✅ Priority levels (Low, Medium, High, Urgent)
- ✅ Due dates with overdue detection
- ✅ Task comments
- ✅ Search and filtering
- ✅ Task statistics dashboard

### Backend Features
- ✅ Django REST Framework
- ✅ JWT authentication (simplejwt)
- ✅ Redis caching for performance
- ✅ Celery for background tasks
- ✅ Custom middleware for logging
- ✅ Custom admin panel with badges
- ✅ Proper permissions & security
- ✅ Database indexing
- ✅ Signal-based cache invalidation

### Frontend Features
- ✅ Provider state management
- ✅ Secure token storage
- ✅ Automatic token refresh
- ✅ Material Design UI
- ✅ Pull-to-refresh
- ✅ Error handling
- ✅ Loading states

## 📋 Prerequisites

### Backend
- Python 3.8+
- pip
- Redis (optional, for caching)

### Frontend
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android SDK / Xcode (for mobile)

## 🛠️ Setup Instructions

### Backend Setup

1. **Navigate to backend directory**
```bash
cd backend
```

2. **Create virtual environment**
```bash
python -m venv venv
venv\Scripts\activate  # Windows
source venv/bin/activate  # Linux/Mac
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Configure environment**
```bash
copy .env.example .env  # Windows
cp .env.example .env    # Linux/Mac
```

5. **Run migrations**
```bash
python manage.py makemigrations
python manage.py migrate
```

6. **Create superuser**
```bash
python manage.py createsuperuser
```

7. **Run development server**
```bash
python manage.py runserver
```

8. **Optional: Run Redis**
```bash
redis-server
```

9. **Optional: Run Celery**
```bash
celery -A config worker -l info
```

### Frontend Setup

1. **Navigate to frontend directory**
```bash
cd frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

## 📱 Usage

1. **Start Backend**: `python manage.py runserver` (http://localhost:8000)
2. **Start Frontend**: `flutter run`
3. **Admin Panel**: http://localhost:8000/admin/
4. **Register** a new account in the Flutter app
5. **Login** and start managing tasks

## 🔑 API Endpoints

### Authentication
- `POST /api/auth/register/` - Register
- `POST /api/auth/login/` - Login
- `POST /api/auth/logout/` - Logout
- `POST /api/auth/token/refresh/` - Refresh token
- `GET /api/auth/profile/` - Get profile
- `PUT /api/auth/profile/` - Update profile
- `POST /api/auth/change-password/` - Change password

### Tasks
- `GET /api/tasks/` - List tasks
- `POST /api/tasks/` - Create task
- `GET /api/tasks/{id}/` - Get task
- `PUT /api/tasks/{id}/` - Update task
- `DELETE /api/tasks/{id}/` - Delete task
- `POST /api/tasks/{id}/complete/` - Mark complete
- `POST /api/tasks/{id}/add_comment/` - Add comment
- `GET /api/tasks/statistics/` - Get statistics

## 🎓 Learning Points

### Django Backend
1. **Custom User Model**: Email-based authentication
2. **JWT Authentication**: Token-based auth with refresh
3. **DRF ViewSets**: RESTful API design
4. **Redis Caching**: Performance optimization
5. **Celery Tasks**: Background job processing
6. **Custom Middleware**: Request logging
7. **Signals**: Cache invalidation
8. **Custom Admin**: Enhanced admin interface
9. **Permissions**: Object-level permissions
10. **Database Optimization**: Indexes, select_related, prefetch_related

### Flutter Frontend
1. **Provider Pattern**: State management
2. **Service Layer**: API abstraction
3. **Secure Storage**: Token management
4. **HTTP Client**: API communication
5. **Error Handling**: Graceful error management
6. **Token Refresh**: Automatic token renewal
7. **Material Design**: Modern UI/UX
8. **Form Validation**: Input validation
9. **Navigation**: Screen routing
10. **Responsive Design**: Adaptive layouts

## 🔒 Security Features

- JWT token authentication
- Password hashing (Django default)
- CORS configuration
- **HTTPS support** (HTTP for dev, HTTPS for production)
- Secure token storage (flutter_secure_storage)
- Token blacklisting on logout
- Permission-based access control
- SQL injection protection (Django ORM)
- XSS protection (Django middleware)
- HSTS (HTTP Strict Transport Security)
- Secure cookies in production
- Certificate validation

**Note:** The app uses HTTP for local development and automatically enforces HTTPS in production. See [HTTPS_SECURITY_GUIDE.md](HTTPS_SECURITY_GUIDE.md) for details.

## 📊 Database Schema

### User Model
- email (unique)
- username (unique)
- first_name, last_name
- phone, avatar
- is_active, is_staff, is_superuser
- date_joined, last_login

### Task Model
- title, description
- status (pending, in_progress, completed, cancelled)
- priority (low, medium, high, urgent)
- user (ForeignKey)
- due_date, completed_at
- created_at, updated_at

### TaskComment Model
- task (ForeignKey)
- user (ForeignKey)
- content
- created_at, updated_at

## 🚀 Production Deployment

### Backend
1. Set `DEBUG=False` in settings
2. Configure PostgreSQL database
3. Set up Redis for caching
4. Configure Celery with Redis broker
5. Collect static files: `python manage.py collectstatic`
6. Use Gunicorn/uWSGI for WSGI server
7. Set up Nginx as reverse proxy
8. Configure SSL/TLS certificates

### Frontend
1. Update API base URL in `api_config.dart`
2. **Set `isDevelopment = false` for production (enables HTTPS)**
3. Build release version: `flutter build apk --release`
4. Deploy to Play Store / App Store
5. For web: `flutter build web --release`

**Important:** See [HTTPS_SECURITY_GUIDE.md](HTTPS_SECURITY_GUIDE.md) for production deployment with HTTPS.

## 📝 License

This project is created for educational purposes.

## 🤝 Contributing

This is a learning project. Feel free to fork and modify for your own learning.

## 📧 Support

For questions or issues, please refer to the documentation in each directory's README.

---

**Happy Learning! 🎉**
