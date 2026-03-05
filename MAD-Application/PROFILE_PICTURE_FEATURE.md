# Profile Picture Feature

## Overview
Users can now upload and manage their profile pictures in the Campus Cart app. Profile pictures are stored in Firebase Storage and the URLs are saved in Firestore.

## Features
- Upload profile picture from camera or gallery
- Automatic image compression (max 800x800, 85% quality)
- Real-time upload progress indicator
- Profile picture displayed across the app
- Secure storage in Firebase Storage

## Implementation Details

### Services Created
1. **FirebaseStorageService** (`lib/services/firebase_storage_service.dart`)
   - `uploadProfileImage(File image, String userId)` - Uploads image and returns download URL
   - `deleteProfileImage(String imageUrl)` - Deletes image from storage
   - `updateProfileImageUrl(String userId, String imageUrl)` - Updates Firestore with new URL

### Updated Screens
1. **EditProfileScreen** (`lib/pages/edit_profile_screen.dart`)
   - Added image picker functionality
   - Camera icon button to trigger image selection
   - Shows upload progress indicator
   - Displays current profile picture or initials

2. **ProfileScreen** (`lib/pages/profile_screen.dart`)
   - Displays uploaded profile picture
   - Falls back to initials if no picture uploaded

### Dependencies
- `image_picker: ^1.0.7` - For selecting images from camera/gallery
- `firebase_storage: ^12.3.6` - For storing images in Firebase

## How to Use

### For Users
1. Navigate to Profile screen
2. Tap the edit icon (top right of profile header)
3. Tap the camera icon on the profile picture
4. Choose "Camera" or "Gallery"
5. Select/take a photo
6. Wait for upload to complete
7. Profile picture is automatically updated

### For Developers

#### Upload Profile Picture
```dart
final FirebaseStorageService storageService = FirebaseStorageService();
final String downloadUrl = await storageService.uploadProfileImage(
  File(imagePath),
  userId,
);
```

#### Update UserManager
```dart
final UserManager userManager = UserManager();
userManager.updateProfile(profileImage: downloadUrl);
```

## Firebase Storage Structure
```
profile_images/
  ├── profile_user123.jpg
  ├── profile_user456.jpg
  └── ...
```

## Firestore Schema Update
The `users` collection documents now include:
```json
{
  "profileImage": "https://firebasestorage.googleapis.com/...",
  "updatedAt": "2024-03-15T10:30:00Z"
}
```

## Security Rules
Ensure Firebase Storage rules allow authenticated users to upload their own profile pictures:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile_images/{userId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Error Handling
- Shows error message if upload fails
- Validates user is logged in before upload
- Handles network errors gracefully
- Falls back to initials if image URL is invalid

## Future Enhancements
- Image cropping before upload
- Multiple image size variants (thumbnail, medium, large)
- Profile picture removal option
- Default avatar selection
- Image filters/effects
