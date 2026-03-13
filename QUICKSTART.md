# 🚀 QUICK START GUIDE

## Prerequisites Check
- [ ] Python 3.8+ installed
- [ ] Flutter SDK installed
- [ ] Code editor (VS Code / Android Studio)

## Backend Setup (5 minutes)

### 1. Open Terminal in `backend` folder
```bash
cd backend
```

### 2. Create Virtual Environment
```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Setup Database
```bash
python manage.py makemigrations
python manage.py migrate
```

### 5. Create Admin User
```bash
python manage.py createsuperuser
# Enter email, username, and password
```

### 6. Run Server
```bash
python manage.py runserver
```

✅ Backend running at: http://localhost:8000
✅ Admin panel at: http://localhost:8000/admin

---

## Frontend Setup (3 minutes)

### 1. Open NEW Terminal in `frontend` folder
```bash
cd frontend
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run App
```bash
# For Chrome (easiest)
flutter run -d chrome

# For Android Emulator
flutter run

# For Windows Desktop
flutter run -d windows
```

✅ App is running!

---

## First Time Usage

### 1. Register Account
- Open the Flutter app
- Click "Don't have an account? Register"
- Fill in the form
- Click "Register"

### 2. Create Your First Task
- Click the "+" button
- Fill in task details
- Click "Create Task"

### 3. Explore Features
- ✅ View task statistics
- ✅ Search tasks
- ✅ Filter by status/priority
- ✅ Mark tasks complete
- ✅ Edit/Delete tasks
- ✅ View profile

---

## Testing the API (Optional)

### Using Admin Panel
1. Go to http://localhost:8000/admin
2. Login with superuser credentials
3. Explore Users and Tasks

### Using API Directly
```bash
# Register
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","username":"testuser","password":"testpass123","password2":"testpass123"}'

# Login
curl -X POST http://localhost:8000/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"email":"test@test.com","password":"testpass123"}'
```

---

## Troubleshooting

### Backend Issues

**Port 8000 already in use?**
```bash
# Windows
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Linux/Mac
lsof -ti:8000 | xargs kill -9
```

**Database errors?**
```bash
# Delete db.sqlite3 and run migrations again
del db.sqlite3  # Windows
rm db.sqlite3   # Linux/Mac
python manage.py migrate
```

### Frontend Issues

**Flutter not found?**
- Install Flutter: https://flutter.dev/docs/get-started/install
- Add to PATH

**Dependencies error?**
```bash
flutter clean
flutter pub get
```

**Connection refused?**
- Make sure backend is running on http://localhost:8000
- Check `lib/config/api_config.dart` for correct URL

---

## Project Structure Overview

```
real_world_project/
├── backend/                 # Django REST API
│   ├── config/             # Settings & URLs
│   ├── apps/
│   │   ├── accounts/       # User authentication
│   │   ├── tasks/          # Task management
│   │   └── core/           # Utilities
│   ├── manage.py
│   └── requirements.txt
│
├── frontend/               # Flutter App
│   ├── lib/
│   │   ├── config/        # API config
│   │   ├── models/        # Data models
│   │   ├── providers/     # State management
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API services
│   │   ├── widgets/       # UI components
│   │   └── main.dart      # Entry point
│   └── pubspec.yaml
│
└── README.md              # Main documentation
```

---

## What You'll Learn

### Django Backend
✅ Custom User model with email authentication
✅ JWT token authentication
✅ Django REST Framework ViewSets
✅ Redis caching (optional)
✅ Celery background tasks (optional)
✅ Custom middleware
✅ Signals for cache invalidation
✅ Custom admin panel
✅ Permissions & security
✅ Database optimization

### Flutter Frontend
✅ Provider state management
✅ Service layer architecture
✅ Secure token storage
✅ HTTP API integration
✅ Token refresh mechanism
✅ Form validation
✅ Material Design UI
✅ Navigation & routing
✅ Error handling
✅ Loading states

---

## Next Steps

1. ✅ Complete the setup above
2. 📖 Read the main README.md
3. 🔍 Explore the code structure
4. 🎨 Customize the UI
5. 🚀 Add new features
6. 📚 Learn from the patterns used

---

## Need Help?

- Check README.md in each folder
- Review the code comments
- Django docs: https://docs.djangoproject.com
- DRF docs: https://www.django-rest-framework.org
- Flutter docs: https://flutter.dev/docs

---

**Happy Coding! 🎉**
