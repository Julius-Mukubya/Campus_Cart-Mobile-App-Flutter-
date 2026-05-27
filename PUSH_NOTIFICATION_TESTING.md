# Push Notification Testing Guide

## Steps to Test Push Notifications

### 1. Get Your Device's FCM Token

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Check the logs for FCM token:**
   ```
   I/flutter: FCM token obtained successfully
   I/flutter: FCM Token: <your_token_here>
   ```
   
   Copy the full token from the logs.

3. **Verify the token is saved to Firestore:**
   - Firebase Console → Firestore
   - Navigate to: `users/{your_user_id}`
   - Look for field `fcmToken` with the value you just copied

### 2. Send Push Notification from Firebase Console

1. **Go to Firebase Console:**
   - Firebase Project → Cloud Messaging

2. **Click "Send your first message"**

3. **Fill in the notification:**
   - Title: `Test Notification`
   - Body: `This is a test message`

4. **Click "Send test message"**

5. **Select target:**
   - Choose "FCMToken" as target type
   - Paste the FCM token you copied earlier
   - Click "Send"

### 3. Expected Behavior

**If app is open (foreground):**
- ✅ Local notification appears at the top of the screen
- ✅ Notification appears in `/notifications` list
- ✅ Notification saved to Firestore

**If app is closed or in background:**
- ✅ System notification appears
- ✅ When you tap it, app opens
- ✅ Notification appears in `/notifications` list
- ✅ Notification saved to Firestore

### 4. Troubleshooting

**If notification doesn't appear:**

1. **Check FCM token is in Firestore:**
   ```
   Firestore → users/{userId} → field: fcmToken
   ```
   If missing, the token wasn't uploaded.

2. **Check app has notification permissions:**
   - Android: Settings → Apps → Campus Cart → Notifications → Allow
   - iOS: Settings → Apps → Campus Cart → Allow notifications

3. **Check device has Google Play Services:**
   - Some emulators don't have it (use physical device)
   - Or use Android emulator with Play Store support

4. **Check logs for errors:**
   - Look for any `FCM` related errors in Flutter logs

### 5. Alternative: Test with Code

Instead of Firebase Console, you can send notifications from your app code:

```dart
// In any service that has access to NotificationService
final notificationService = NotificationService();

await notificationService.sendNotification(
  userId: 'user_id_here',
  title: 'Test Notification',
  message: 'This is a test from code',
  type: 'test',
);
```

This saves to Firestore directly and will show in the notifications list.

## Key Files

- `lib/services/fcm_service.dart` - Handles FCM initialization and push messages
- `lib/services/notification_service.dart` - Saves notifications to Firestore
- `lib/providers/notification_provider.dart` - Real-time notification stream

## Important Notes

⚠️ **FCM Token Registration:**
- Token is obtained on app startup
- Token is uploaded to Firestore when user logs in (in `setUserId()`)
- Token persists across app restarts
- Token may refresh (new token uploaded automatically)

⚠️ **Notification Flow:**
1. Service saves notification to Firestore
2. FCM sends push to device's FCM token (if available)
3. Local notification shows on device
4. Real-time listener updates notification list

⚠️ **Fallback Mode:**
- If FCM token can't be obtained, app still works
- Notifications appear in real-time from Firestore
- Push notifications won't work (but they're optional)
