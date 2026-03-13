# 🔒 HTTP vs HTTPS - Quick Reference

## Current Setup

### ✅ Development (Local Testing)
```
Frontend: http://localhost:8000/api
Backend:  http://localhost:8000
Status:   ✅ SAFE for local development
```

### ✅ Production (Live App)
```
Frontend: https://your-domain.com/api
Backend:  https://your-domain.com
Status:   ✅ REQUIRED for production
```

---

## 🔄 How to Switch

### Development → Production

**1. Flutter (frontend/lib/config/api_config.dart)**
```dart
// Change this line:
static const bool isDevelopment = false;  // was: true

// Update this line:
static const String productionUrl = 'https://your-domain.com/api';
```

**2. Django (backend/config/settings.py)**
```python
# Change this line:
DEBUG = False  # was: True

# Update this line:
ALLOWED_HOSTS = ['your-domain.com', 'www.your-domain.com']

# CORS is already configured to use HTTPS in production!
```

**3. Get SSL Certificate**
```bash
# Free option: Let's Encrypt
sudo certbot --nginx -d your-domain.com

# Or use cloud provider (AWS, Heroku, etc.)
```

---

## ⚡ Quick Commands

### Check Current Mode
```dart
// In Flutter app, check console output
print('API URL: ${ApiConfig.baseUrl}');
// Development: http://localhost:8000/api
// Production:  https://your-domain.com/api
```

### Test HTTPS
```bash
# Test backend
curl https://your-domain.com/api/tasks/

# Should redirect HTTP to HTTPS
curl http://your-domain.com/api/tasks/
```

---

## 🛡️ Security Features (Already Implemented!)

### Development Mode
- ✅ HTTP allowed for localhost
- ✅ CORS allows localhost
- ✅ Debug mode enabled
- ✅ Detailed error messages

### Production Mode (Automatic!)
- ✅ HTTPS enforced
- ✅ HTTP redirects to HTTPS
- ✅ Secure cookies
- ✅ HSTS enabled
- ✅ XSS protection
- ✅ CORS restricted to HTTPS
- ✅ Certificate validation

---

## 📱 Platform Requirements

### Android
- Development: HTTP allowed
- Production: HTTPS required by Google Play

### iOS
- Development: HTTP allowed with exception
- Production: HTTPS required by App Store

### Web
- Development: HTTP allowed
- Production: HTTPS required by browsers

---

## ⚠️ Common Mistakes

### ❌ DON'T
```dart
// Don't use HTTP in production
static const bool isDevelopment = true;  // Wrong!
static const String productionUrl = 'http://your-domain.com/api';  // Wrong!
```

### ✅ DO
```dart
// Use HTTPS in production
static const bool isDevelopment = false;  // Correct!
static const String productionUrl = 'https://your-domain.com/api';  // Correct!
```

---

## 🚀 Deployment Checklist

- [ ] Set `isDevelopment = false`
- [ ] Update `productionUrl` with HTTPS
- [ ] Set `DEBUG = False` in Django
- [ ] Update `ALLOWED_HOSTS`
- [ ] Get SSL certificate
- [ ] Test HTTPS connection
- [ ] Deploy backend
- [ ] Deploy frontend
- [ ] Test end-to-end

---

## 📚 More Information

See **HTTPS_SECURITY_GUIDE.md** for:
- Detailed HTTPS setup
- SSL certificate installation
- Nginx configuration
- Deployment options
- Security best practices
- Troubleshooting

---

## ✅ Summary

| Aspect | Development | Production |
|--------|-------------|------------|
| Protocol | HTTP | HTTPS |
| URL | localhost:8000 | your-domain.com |
| isDevelopment | true | false |
| DEBUG | True | False |
| SSL Certificate | Not needed | Required |
| Security | Basic | Full |

**Your app is already configured!** Just flip the switch when deploying. 🚀
