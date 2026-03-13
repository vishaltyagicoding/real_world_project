# 🔒 HTTPS & SECURITY GUIDE

## ⚠️ IMPORTANT: HTTP vs HTTPS

### Development (Local)
- ✅ **HTTP** is acceptable: `http://localhost:8000`
- Used for local testing only
- No sensitive data exposed to internet

### Production (Live)
- ❌ **HTTP is NOT acceptable**
- ✅ **HTTPS is MANDATORY**: `https://your-domain.com`
- Encrypts all data in transit
- Required by app stores (Google Play, Apple App Store)
- Required for payment processing
- Required by GDPR and other regulations

---

## 🔧 Current Configuration

### Development Mode (Default)
```dart
// frontend/lib/config/api_config.dart
static const bool isDevelopment = true;
static const String developmentUrl = 'http://localhost:8000/api';
```

### Production Mode
```dart
// frontend/lib/config/api_config.dart
static const bool isDevelopment = false;  // Change this!
static const String productionUrl = 'https://your-domain.com/api';
```

---

## 🚀 How to Switch to Production (HTTPS)

### Step 1: Update Flutter Configuration

Edit `frontend/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Change to false for production
  static const bool isDevelopment = false;
  
  static const String developmentUrl = 'http://localhost:8000/api';
  static const String productionUrl = 'https://api.your-domain.com/api'; // Your HTTPS URL
  
  // Rest of the code...
}
```

### Step 2: Update Django Settings

Edit `backend/config/settings.py`:

```python
# Set DEBUG to False in production
DEBUG = False

# Add your production domain
ALLOWED_HOSTS = ['your-domain.com', 'www.your-domain.com', 'api.your-domain.com']

# CORS for production (HTTPS only)
CORS_ALLOWED_ORIGINS = [
    "https://your-domain.com",
    "https://www.your-domain.com",
]

# Security settings are already configured!
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
```

### Step 3: Get SSL Certificate

**Option 1: Let's Encrypt (Free)**
```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Get certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com
```

**Option 2: Cloud Provider**
- AWS: Use AWS Certificate Manager (ACM)
- Google Cloud: Use Google-managed SSL certificates
- Heroku: Automatic SSL with paid dynos
- DigitalOcean: One-click SSL certificates

**Option 3: Cloudflare (Free)**
- Add your domain to Cloudflare
- Enable SSL/TLS encryption
- Cloudflare provides free SSL certificates

---

## 🛡️ Security Features Implemented

### Backend (Django)

#### 1. HTTPS Enforcement
```python
# Redirects all HTTP to HTTPS in production
SECURE_SSL_REDIRECT = not DEBUG
```

#### 2. Secure Cookies
```python
# Cookies only sent over HTTPS
SESSION_COOKIE_SECURE = not DEBUG
CSRF_COOKIE_SECURE = not DEBUG
```

#### 3. HTTP Strict Transport Security (HSTS)
```python
# Browser remembers to use HTTPS
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
```

#### 4. XSS Protection
```python
# Prevents cross-site scripting
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
```

#### 5. Clickjacking Protection
```python
# Prevents iframe embedding
X_FRAME_OPTIONS = 'DENY'
```

#### 6. JWT Token Security
```python
# Tokens expire automatically
ACCESS_TOKEN_LIFETIME = timedelta(minutes=60)
REFRESH_TOKEN_LIFETIME = timedelta(days=1)
ROTATE_REFRESH_TOKENS = True
BLACKLIST_AFTER_ROTATION = True
```

### Frontend (Flutter)

#### 1. HTTPS Validation
```dart
// Validates HTTPS in production
static bool isSecureConnection() {
  if (!isDevelopment && !baseUrl.startsWith('https://')) {
    throw Exception('Production must use HTTPS!');
  }
  return true;
}
```

#### 2. Secure Token Storage
```dart
// Uses platform-specific secure storage
// iOS: Keychain
// Android: KeyStore
// Web: Encrypted storage
const _storage = FlutterSecureStorage();
```

#### 3. Certificate Pinning (Optional - Advanced)
```dart
// Add to pubspec.yaml for certificate pinning
dependencies:
  http_certificate_pinning: ^2.0.0
```

---

## 📱 Platform-Specific HTTPS Requirements

### Android
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="false">  <!-- Disable HTTP -->
```

### iOS
```xml
<!-- ios/Runner/Info.plist -->
<!-- Remove or comment out NSAllowsArbitraryLoads -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>  <!-- Enforce HTTPS -->
</dict>
```

### Web
```html
<!-- web/index.html -->
<meta http-equiv="Content-Security-Policy" 
      content="upgrade-insecure-requests">
```

---

## 🔐 Additional Security Best Practices

### 1. Environment Variables
```bash
# Never commit these to git!
SECRET_KEY=your-secret-key-here
DATABASE_PASSWORD=your-db-password
API_KEY=your-api-key
```

### 2. API Rate Limiting
```python
# Add to settings.py
REST_FRAMEWORK = {
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle'
    ],
    'DEFAULT_THROTTLE_RATES': {
        'anon': '100/day',
        'user': '1000/day'
    }
}
```

### 3. Password Requirements
```python
# Already configured in settings.py
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]
```

### 4. Input Validation
```dart
// Frontend validation
validator: (value) {
  if (value == null || value.isEmpty) return 'Required';
  if (!value.contains('@')) return 'Invalid email';
  return null;
}
```

```python
# Backend validation
class TaskSerializer(serializers.ModelSerializer):
    def validate_due_date(self, value):
        if value and value < timezone.now():
            raise serializers.ValidationError("Due date cannot be in the past")
        return value
```

---

## 🚀 Deployment Checklist

### Before Deploying to Production

- [ ] Set `isDevelopment = false` in Flutter
- [ ] Set `DEBUG = False` in Django
- [ ] Update `productionUrl` with HTTPS URL
- [ ] Update `ALLOWED_HOSTS` in Django
- [ ] Update `CORS_ALLOWED_ORIGINS` with HTTPS URLs
- [ ] Get SSL certificate
- [ ] Configure web server (Nginx/Apache) for HTTPS
- [ ] Test HTTPS connection
- [ ] Enable HSTS
- [ ] Set secure environment variables
- [ ] Remove any hardcoded secrets
- [ ] Test all API endpoints with HTTPS
- [ ] Test Flutter app with production API
- [ ] Enable rate limiting
- [ ] Set up monitoring and logging
- [ ] Configure firewall rules
- [ ] Set up automated backups
- [ ] Test token refresh over HTTPS
- [ ] Verify secure cookie settings

---

## 🌐 Deployment Options with HTTPS

### Option 1: Traditional Server (VPS)

**Requirements:**
- Domain name
- VPS (DigitalOcean, Linode, AWS EC2)
- Nginx/Apache
- SSL certificate (Let's Encrypt)

**Setup:**
```bash
# Install Nginx
sudo apt-get install nginx

# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com

# Configure Nginx
sudo nano /etc/nginx/sites-available/your-app

# Nginx configuration
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

### Option 2: Heroku (Easy)

**Automatic HTTPS:**
```bash
# Deploy backend
heroku create your-app-name
git push heroku main

# HTTPS is automatic!
# Your app: https://your-app-name.herokuapp.com
```

### Option 3: AWS (Scalable)

**Components:**
- EC2 for Django
- RDS for PostgreSQL
- S3 for static files
- CloudFront for CDN
- Certificate Manager for SSL
- Elastic Load Balancer (handles HTTPS)

### Option 4: Google Cloud Run (Serverless)

**Automatic HTTPS:**
```bash
# Deploy with one command
gcloud run deploy --source .

# HTTPS is automatic!
```

### Option 5: DigitalOcean App Platform

**Automatic HTTPS:**
- Connect GitHub repo
- Select branch
- Deploy
- HTTPS is automatic!

---

## 🧪 Testing HTTPS

### Test Backend HTTPS
```bash
# Should work
curl https://your-domain.com/api/tasks/

# Should redirect to HTTPS
curl http://your-domain.com/api/tasks/
```

### Test Flutter App
```dart
// Add logging to see requests
print('Making request to: ${ApiConfig.baseUrl}');

// Should see: https://your-domain.com/api
```

### Test SSL Certificate
```bash
# Check certificate validity
openssl s_client -connect your-domain.com:443

# Online tools
# https://www.ssllabs.com/ssltest/
```

---

## 🔍 Common HTTPS Issues

### Issue 1: Mixed Content Error
**Problem:** HTTPS page loading HTTP resources
**Solution:** Ensure all resources use HTTPS

### Issue 2: Certificate Not Trusted
**Problem:** Self-signed certificate
**Solution:** Use Let's Encrypt or proper CA

### Issue 3: CORS Error with HTTPS
**Problem:** CORS not configured for HTTPS
**Solution:** Update `CORS_ALLOWED_ORIGINS` with HTTPS URLs

### Issue 4: Redirect Loop
**Problem:** Nginx misconfiguration
**Solution:** Check proxy headers in Nginx config

---

## 📊 Security Comparison

| Feature | HTTP (Dev) | HTTPS (Prod) |
|---------|-----------|--------------|
| Data Encryption | ❌ No | ✅ Yes |
| Man-in-the-Middle Protection | ❌ No | ✅ Yes |
| App Store Approval | ❌ No | ✅ Yes |
| SEO Ranking | ❌ Lower | ✅ Higher |
| Browser Trust | ⚠️ Warning | ✅ Secure |
| Payment Processing | ❌ Not Allowed | ✅ Allowed |
| GDPR Compliant | ❌ No | ✅ Yes |
| Production Ready | ❌ No | ✅ Yes |

---

## 🎓 Why HTTPS Matters

### 1. Data Encryption
- All data encrypted in transit
- Passwords, tokens, personal data protected
- Prevents eavesdropping

### 2. Authentication
- Verifies server identity
- Prevents impersonation
- Users trust your app

### 3. Data Integrity
- Prevents data tampering
- Ensures data arrives unchanged
- Detects man-in-the-middle attacks

### 4. Compliance
- Required by GDPR, PCI-DSS
- Required by app stores
- Required by browsers (Chrome marks HTTP as "Not Secure")

### 5. SEO Benefits
- Google ranks HTTPS sites higher
- Better search visibility
- More organic traffic

---

## ✅ Quick Reference

### Development (Local Testing)
```dart
// Flutter
isDevelopment = true
developmentUrl = 'http://localhost:8000/api'

// Django
DEBUG = True
ALLOWED_HOSTS = ['localhost', '127.0.0.1']
```

### Production (Live App)
```dart
// Flutter
isDevelopment = false
productionUrl = 'https://api.your-domain.com/api'

// Django
DEBUG = False
ALLOWED_HOSTS = ['your-domain.com']
SECURE_SSL_REDIRECT = True
```

---

## 🚀 Summary

✅ **Development**: HTTP is OK for local testing
✅ **Production**: HTTPS is MANDATORY
✅ **Security**: All features already implemented
✅ **Configuration**: Just change `isDevelopment` flag
✅ **Deployment**: Multiple easy options available

**Your app is already configured for HTTPS!** Just switch the flag when deploying to production.

---

**Stay Secure! 🔒**
