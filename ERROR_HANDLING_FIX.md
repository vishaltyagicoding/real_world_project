# Error Handling Fix - Login Error Messages

## Issue
When logging in with invalid credentials (non-existent user or wrong password), the app showed a misleading error message: "Session expired. Please login again."

## Root Cause
The API service's error handler treated all 401 (Unauthorized) responses the same way:
1. Received 401 from login endpoint (invalid credentials)
2. Attempted to refresh the token (which doesn't make sense for login)
3. Token refresh failed (no token exists yet)
4. Showed "Session expired" message

## Solution

### 1. Differentiated Auth Requests from Regular Requests
**File**: `frontend/lib/services/api_service.dart`

Added `isAuthRequest` parameter to distinguish between:
- Authentication requests (login/register) - Don't try to refresh token on 401
- Regular API requests - Try to refresh token on 401

```dart
static Future<Map<String, dynamic>> _handleResponse(
    http.Response response, {bool isAuthRequest = false}) async {
  // ...
  if (response.statusCode == 401) {
    // For login/register, show actual error message
    if (isAuthRequest) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Invalid credentials');
    }
    
    // For other requests, try token refresh
    final refreshed = await _refreshToken();
    if (!refreshed) {
      throw Exception('Session expired. Please login again.');
    }
  }
}
```

### 2. Updated Auth Service
**File**: `frontend/lib/services/auth_service.dart`

Marked login and register requests as auth requests:
```dart
static Future<Map<String, dynamic>> login(...) async {
  final response = await ApiService.post(
    ApiConfig.loginEndpoint,
    {...},
    isAuthRequest: true,  // Don't try token refresh
  );
}
```

### 3. Improved Backend Error Messages
**File**: `backend/apps/accounts/views.py`

Made error messages more user-friendly:
- "Invalid email or password. Please check your credentials and try again."
- "Your account has been disabled. Please contact support."

## Error Messages by Scenario

### Invalid Credentials (Wrong Email/Password)
- **Before**: "Session expired. Please login again."
- **After**: "Invalid email or password. Please check your credentials and try again."

### Account Disabled
- **Before**: "Session expired. Please login again."
- **After**: "Your account has been disabled. Please contact support."

### Missing Email or Password
- **Message**: "Email and password are required"

### Token Expired (During App Usage)
- **Message**: "Session expired. Please login again."
- **Behavior**: User is redirected to login screen

### Network Error
- **Message**: "Request failed with status [code]"

### Invalid Response Format
- **Message**: "Failed to parse response: [details]"

## Testing Scenarios

### Test Invalid Login
1. Enter non-existent email: "test@example.com"
2. Enter any password
3. Click Login
4. **Expected**: "Invalid email or password. Please check your credentials and try again."

### Test Wrong Password
1. Enter valid email of existing user
2. Enter wrong password
3. Click Login
4. **Expected**: "Invalid email or password. Please check your credentials and try again."

### Test Empty Fields
1. Leave email or password empty
2. Click Login
3. **Expected**: Form validation error (handled by Flutter form)

### Test Disabled Account
1. Admin disables user account in Django admin
2. User tries to login
3. **Expected**: "Your account has been disabled. Please contact support."

### Test Token Expiration
1. Login successfully
2. Wait for token to expire (or manually delete token)
3. Try to access protected resource
4. **Expected**: "Session expired. Please login again." + redirect to login

## Files Modified

1. **frontend/lib/services/api_service.dart**
   - Added `isAuthRequest` parameter to `_handleResponse`
   - Added `isAuthRequest` parameter to `post` method
   - Differentiated error handling for auth vs regular requests

2. **frontend/lib/services/auth_service.dart**
   - Updated `login` method to pass `isAuthRequest: true`
   - Updated `register` method to pass `isAuthRequest: true`

3. **backend/apps/accounts/views.py**
   - Improved error messages in `LoginView`
   - Made messages more user-friendly and actionable

## Benefits

1. **Clear Error Messages**: Users see exactly what went wrong
2. **Better UX**: No confusion about "session expired" when they haven't logged in yet
3. **Proper Error Handling**: Different scenarios handled appropriately
4. **Production Ready**: User-friendly messages suitable for production

## Security Note

The error message "Invalid email or password" doesn't reveal whether the email exists or not, which is a security best practice to prevent user enumeration attacks.
