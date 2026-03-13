# 🏗️ ARCHITECTURE OVERVIEW

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      FLUTTER FRONTEND                        │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │ Screens  │───▶│ Providers│───▶│ Services │             │
│  │  (UI)    │◀───│  (State) │◀───│  (API)   │             │
│  └──────────┘    └──────────┘    └──────────┘             │
│       │                                  │                   │
│       │                                  │ HTTP/JWT          │
│       └──────────────────────────────────┘                   │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            │ REST API
                            │
┌───────────────────────────▼──────────────────────────────────┐
│                    DJANGO BACKEND                            │
│                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │  Views   │───▶│  Models  │───▶│ Database │             │
│  │ (API)    │◀───│(Business)│◀───│(SQLite)  │             │
│  └──────────┘    └──────────┘    └──────────┘             │
│       │                                                      │
│       ├──────────▶ Redis Cache                              │
│       │                                                      │
│       └──────────▶ Celery Tasks                             │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Data Flow - User Login

```
1. User enters email/password
   │
   ▼
2. LoginScreen → AuthProvider.login()
   │
   ▼
3. AuthProvider → AuthService.login()
   │
   ▼
4. AuthService → ApiService.post('/auth/login/')
   │
   ▼
5. Django receives request → TokenObtainPairView
   │
   ▼
6. Validates credentials → Returns JWT tokens
   │
   ▼
7. StorageService.saveTokens() → Secure Storage
   │
   ▼
8. Navigate to HomeScreen
```

## Data Flow - Create Task

```
1. User fills task form
   │
   ▼
2. TaskFormScreen → TaskProvider.createTask()
   │
   ▼
3. TaskProvider → TaskService.createTask()
   │
   ▼
4. TaskService → ApiService.post('/tasks/', data)
   │
   ▼
5. Django receives request → TaskViewSet.create()
   │
   ▼
6. Validates data → Saves to database
   │
   ▼
7. Signal fires → Clears cache
   │
   ▼
8. Returns task data → Updates UI
```

## Authentication Flow

```
┌─────────────┐
│   Flutter   │
│     App     │
└──────┬──────┘
       │
       │ 1. POST /auth/login/
       │    {email, password}
       ▼
┌─────────────┐
│   Django    │
│   Backend   │
└──────┬──────┘
       │
       │ 2. Returns JWT tokens
       │    {access, refresh}
       ▼
┌─────────────┐
│   Secure    │
│   Storage   │
└──────┬──────┘
       │
       │ 3. Stored encrypted
       │
       ▼
┌─────────────┐
│  All API    │
│  Requests   │
│  + Bearer   │
│   Token     │
└─────────────┘
```

## Token Refresh Flow

```
1. API request with expired access token
   │
   ▼
2. Backend returns 401 Unauthorized
   │
   ▼
3. ApiService detects 401
   │
   ▼
4. Automatically calls /auth/token/refresh/
   │
   ▼
5. Sends refresh token
   │
   ▼
6. Backend validates refresh token
   │
   ▼
7. Returns new access token
   │
   ▼
8. Saves new token
   │
   ▼
9. Retries original request
```

## Caching Strategy

```
┌─────────────┐
│   Request   │
│   Tasks     │
└──────┬──────┘
       │
       ▼
┌─────────────┐
│  Check      │
│  Redis      │
│  Cache      │
└──────┬──────┘
       │
       ├─── Cache Hit ───▶ Return cached data
       │
       └─── Cache Miss
              │
              ▼
       ┌─────────────┐
       │  Query      │
       │  Database   │
       └──────┬──────┘
              │
              ▼
       ┌─────────────┐
       │  Store in   │
       │  Cache      │
       └──────┬──────┘
              │
              ▼
       Return data
```

## Database Schema

```
┌─────────────────────┐
│       User          │
├─────────────────────┤
│ id (PK)             │
│ email (unique)      │
│ username (unique)   │
│ password (hashed)   │
│ first_name          │
│ last_name           │
│ phone               │
│ avatar              │
│ is_active           │
│ is_staff            │
│ date_joined         │
└──────────┬──────────┘
           │
           │ 1:N
           │
┌──────────▼──────────┐
│       Task          │
├─────────────────────┤
│ id (PK)             │
│ user_id (FK)        │
│ title               │
│ description         │
│ status              │
│ priority            │
│ due_date            │
│ completed_at        │
│ created_at          │
│ updated_at          │
└──────────┬──────────┘
           │
           │ 1:N
           │
┌──────────▼──────────┐
│   TaskComment       │
├─────────────────────┤
│ id (PK)             │
│ task_id (FK)        │
│ user_id (FK)        │
│ content             │
│ created_at          │
│ updated_at          │
└─────────────────────┘
```

## Folder Structure Comparison

### Django (Backend)
```
backend/
├── config/              # Project settings
│   ├── settings.py      # All configurations
│   ├── urls.py          # URL routing
│   └── celery.py        # Background tasks
├── apps/                # Business logic
│   ├── accounts/        # User management
│   │   ├── models.py    # User model
│   │   ├── views.py     # API endpoints
│   │   ├── serializers.py
│   │   └── admin.py
│   ├── tasks/           # Task management
│   │   ├── models.py    # Task models
│   │   ├── views.py     # API endpoints
│   │   ├── serializers.py
│   │   ├── permissions.py
│   │   └── admin.py
│   └── core/            # Shared utilities
│       └── middleware.py
└── manage.py            # CLI tool
```

### Flutter (Frontend)
```
frontend/
├── lib/
│   ├── config/          # Configuration
│   │   └── api_config.dart
│   ├── models/          # Data structures
│   │   ├── user.dart
│   │   └── task.dart
│   ├── services/        # Business logic
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── task_service.dart
│   │   └── storage_service.dart
│   ├── providers/       # State management
│   │   ├── auth_provider.dart
│   │   └── task_provider.dart
│   ├── screens/         # UI pages
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── task_form_screen.dart
│   │   └── profile_screen.dart
│   ├── widgets/         # Reusable UI
│   │   └── task_card.dart
│   └── main.dart        # Entry point
└── pubspec.yaml         # Dependencies
```

## API Endpoints Map

```
Authentication
├── POST   /api/auth/register/          Create account
├── POST   /api/auth/login/             Get JWT tokens
├── POST   /api/auth/logout/            Blacklist token
├── POST   /api/auth/token/refresh/     Refresh access token
├── GET    /api/auth/profile/           Get user profile
├── PUT    /api/auth/profile/           Update profile
└── POST   /api/auth/change-password/   Change password

Tasks
├── GET    /api/tasks/                  List all tasks
├── POST   /api/tasks/                  Create task
├── GET    /api/tasks/{id}/             Get task detail
├── PUT    /api/tasks/{id}/             Update task
├── DELETE /api/tasks/{id}/             Delete task
├── POST   /api/tasks/{id}/complete/    Mark complete
├── POST   /api/tasks/{id}/add_comment/ Add comment
└── GET    /api/tasks/statistics/       Get stats
```

## State Management Flow (Provider)

```
┌─────────────────────────────────────────────────┐
│                   Widget Tree                    │
│                                                  │
│  ┌────────────────────────────────────────┐    │
│  │  MultiProvider                          │    │
│  │  ├── AuthProvider                       │    │
│  │  └── TaskProvider                       │    │
│  │                                          │    │
│  │  ┌────────────────────────────────┐    │    │
│  │  │  Consumer<AuthProvider>         │    │    │
│  │  │  ├── Listens to auth changes    │    │    │
│  │  │  └── Rebuilds on notify         │    │    │
│  │  └────────────────────────────────┘    │    │
│  │                                          │    │
│  │  ┌────────────────────────────────┐    │    │
│  │  │  Consumer<TaskProvider>         │    │    │
│  │  │  ├── Listens to task changes    │    │    │
│  │  │  └── Rebuilds on notify         │    │    │
│  │  └────────────────────────────────┘    │    │
│  └────────────────────────────────────────┘    │
└─────────────────────────────────────────────────┘

When data changes:
1. Provider.notifyListeners()
2. Only Consumer widgets rebuild
3. Rest of UI stays unchanged
4. Efficient and performant
```

## Security Layers

```
┌─────────────────────────────────────────┐
│         Flutter App (Client)            │
│  ┌───────────────────────────────────┐ │
│  │  Secure Storage (Encrypted)       │ │
│  │  - Access Token                   │ │
│  │  - Refresh Token                  │ │
│  └───────────────────────────────────┘ │
└──────────────┬──────────────────────────┘
               │ HTTPS + Bearer Token
               ▼
┌─────────────────────────────────────────┐
│         Django Backend (Server)         │
│  ┌───────────────────────────────────┐ │
│  │  JWT Authentication               │ │
│  │  - Validates token                │ │
│  │  - Checks expiration              │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │  Permission Classes               │ │
│  │  - IsAuthenticated                │ │
│  │  - IsTaskOwner                    │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │  Django ORM                       │ │
│  │  - SQL Injection Protection       │ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## Key Takeaways

1. **Layered Architecture**: Clear separation of concerns
2. **Stateless Backend**: JWT allows horizontal scaling
3. **Secure by Default**: Multiple security layers
4. **Performance First**: Caching and optimization
5. **Maintainable**: Easy to understand and modify
6. **Production-Ready**: Real-world patterns throughout

This architecture can scale from 1 to 1,000,000 users! 🚀
