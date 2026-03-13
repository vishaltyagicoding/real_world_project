# Task Manager Frontend - Flutter

## Features
- JWT Authentication with secure token storage
- Task CRUD operations
- Real-time task statistics
- Search and filter functionality
- Material Design UI
- Provider state management
- Proper error handling

## Setup Instructions

### 1. Install Flutter
Make sure Flutter SDK is installed: https://flutter.dev/docs/get-started/install

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Backend URL
Update the `baseUrl` in `lib/config/api_config.dart` if your backend is not running on localhost:8000

### 4. Run the App
```bash
# For Android/iOS
flutter run

# For Web
flutter run -d chrome

# For Windows
flutter run -d windows
```

## Project Structure
```
frontend/
├── lib/
│   ├── config/              # Configuration files
│   │   └── api_config.dart  # API endpoints
│   ├── models/              # Data models
│   │   ├── user.dart        # User model
│   │   └── task.dart        # Task model
│   ├── providers/           # State management
│   │   ├── auth_provider.dart
│   │   └── task_provider.dart
│   ├── screens/             # UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── task_form_screen.dart
│   │   └── profile_screen.dart
│   ├── services/            # API services
│   │   ├── api_service.dart      # HTTP client
│   │   ├── auth_service.dart     # Auth operations
│   │   ├── task_service.dart     # Task operations
│   │   └── storage_service.dart  # Secure storage
│   ├── widgets/             # Reusable widgets
│   │   └── task_card.dart
│   └── main.dart            # Entry point
└── pubspec.yaml             # Dependencies
```

## Architecture

### State Management
- **Provider**: Used for state management
- **AuthProvider**: Manages authentication state
- **TaskProvider**: Manages task state and operations

### Services Layer
- **ApiService**: Generic HTTP client with token refresh
- **AuthService**: Authentication operations
- **TaskService**: Task CRUD operations
- **StorageService**: Secure token storage using flutter_secure_storage

### Models
- **User**: User data model
- **Task**: Task data model with comments
- **TaskStatistics**: Task statistics model

## Key Features Implementation

### Authentication Flow
1. User logs in → JWT tokens stored securely
2. Access token sent with each request
3. Automatic token refresh on 401 error
4. Logout clears all stored tokens

### Task Management
- Create, read, update, delete tasks
- Filter by status and priority
- Search functionality
- Mark tasks as complete
- View task statistics

### Security
- Tokens stored in flutter_secure_storage
- Automatic token refresh
- Secure API communication

## Dependencies
- **provider**: State management
- **http**: HTTP client
- **flutter_secure_storage**: Secure token storage
- **intl**: Date formatting

## API Integration
The app connects to Django backend at `http://localhost:8000/api`

### Endpoints Used
- POST `/auth/login/` - Login
- POST `/auth/register/` - Register
- POST `/auth/logout/` - Logout
- GET `/auth/profile/` - Get profile
- GET `/tasks/` - List tasks
- POST `/tasks/` - Create task
- PUT `/tasks/{id}/` - Update task
- DELETE `/tasks/{id}/` - Delete task
- POST `/tasks/{id}/complete/` - Complete task
- GET `/tasks/statistics/` - Get statistics

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### Windows
```bash
flutter build windows --release
```
