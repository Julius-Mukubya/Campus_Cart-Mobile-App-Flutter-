# App Icon Setup Guide

## Current Issue
The cart icon appears zoomed because adaptive icons need proper padding.

## Solution Options

### Option 1: Use Online Tool (Easiest - 2 minutes)
1. Go to: https://icon.kitchen/ or https://easyappicon.com/
2. Upload your `app_icon.png`
3. Select "Android Adaptive Icon"
4. The tool will automatically add proper padding
5. Download the generated `foreground.png`
6. Save it as `assets/icon/app_icon_foreground.png`
7. Update pubspec.yaml to use the new foreground image

### Option 2: Manual Editing (If you have image editor)
1. Open `app_icon.png` in an image editor (Photoshop, GIMP, Figma, etc.)
2. Create a new canvas: 1024x1024px with transparent background
3. Paste your cart icon in the center
4. Resize the cart icon to occupy only 66% of the canvas (about 675x675px)
5. The cart should be centered with transparent padding around it
6. Export as PNG with transparency
7. Save as `assets/icon/app_icon_foreground.png`

### Option 3: Use Current Icon with Background Color (Current Setup)
- Your cart icon will show on a blue (#1A73E8) background
- This works but may look zoomed on some devices
- To fix: The icon itself needs to be smaller with transparent padding

## Recommended Dimensions
- Full canvas: 1024x1024px
- Safe zone (where icon should be): 684x684px (center)
- Icon should not extend beyond the safe zone

## After Creating Foreground Image
Update `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1A73E8"
  adaptive_icon_foreground: "assets/icon/app_icon_foreground.png"  # New file
  min_sdk_android: 21
```

Then run:
```
flutter pub get
flutter pub run flutter_launcher_icons
```
