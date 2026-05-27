# Firebase Cloud Messaging (FCM) Setup Guide

## Issue: DEVELOPER_ERROR from Google Play Services

If you're seeing this error:
```
W/GoogleApiManager(23523): Not showing notification since connectionResult is not user-facing: 
ConnectionResult{statusCode=DEVELOPER_ERROR, resolution=null, message=null}
```

This means FCM isn't properly initialized on the Android device, but **notifications will still work** through local notifications.

## Solutions

### Solution 1: Get SHA-1 Certificate Fingerprint

1. **Get debug SHA-1:**
   ```bash
   cd android
   ./gradlew signingReport
   ```
   Look for `SHA1:` under `Variant: debugAndroidTest`

2. **Add to Firebase Console:**
   - Go to Firebase Console → Project Settings
   - Click "Add Fingerprint"
   - Paste the SHA-1 from step 1
   - Click "Save"

### Solution 2: Verify google-services.json

1. **Check the package name matches:**
   - In `android/app/build.gradle.kts`: Check `applicationId = "com.example.madpractical"`
   - In `android/app/google-services.json`: Check `"package_name": "com.example.madpractical"`
   - They must match exactly

2. **If they don't match:**
   - Download fresh `google-services.json` from Firebase Console
   - Replace `android/app/google-services.json`
   - Run `flutter clean && flutter pub get`

### Solution 3: Enable FCM in Firebase

1. Go to Firebase Console → Cloud Messaging
2. Click "Enable"
3. Wait 5-10 minutes for it to propagate

### Solution 4: Update AndroidManifest.xml

Add this permission (already added):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

## Fallback Mode (Current Implementation)

Even if FCM fails to initialize, the app has fallback mechanisms:

1. **Local Notifications Still Work:**
   - App shows local notifications when message arrives (foreground)
   - Real-time notification list updates from Firestore

2. **Error Handling:**
   - All FCM operations wrapped in try-catch
   - Warnings logged, not errors
   - App continues to function

## Testing Notifications

### 1. Test Local Notifications (In-app):
- Open app
- Have another user/account place an order
- Should see local notification immediately

### 2. Test Push Notifications (Background):
- Put app in background
- Send notification from Firebase Console or code
- Should see system notification

### 3. Check FCM Token:
- Dart code will print FCM token on startup
- Look for: `FCM token obtained: ...`
- Or: `Failed to get FCM token` (fallback mode)

## Debug Checklist

- [ ] Check logcat for `DEVELOPER_ERROR`
- [ ] Verify SHA-1 fingerprint registered in Firebase
- [ ] Verify `google-services.json` package name matches app
- [ ] Verify FCM enabled in Firebase Console
- [ ] Check `AndroidManifest.xml` has notification permission
- [ ] Run `flutter clean && flutter pub get`
- [ ] Reinstall app: `flutter run`

## Key Files Modified

- `lib/services/fcm_service.dart` - Error handling in init()
- `android/app/src/main/AndroidManifest.xml` - Added POST_NOTIFICATIONS permission

## Notes

- The app uses **local notifications** for foreground messages
- The app uses **Firestore stream** for real-time notification list
- FCM push tokens are optional (app works without them)
- All notifications are also saved to Firestore for history
