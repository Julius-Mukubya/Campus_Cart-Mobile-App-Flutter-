# App Icon & Splash Screen Setup

## Shopping Bag Icon Design
Create a 1024x1024 PNG image with a shopping bag icon design that matches the `Icons.shopping_bag` used in the splash screen.

### Design Specifications:
- **Size**: 1024x1024 pixels
- **Format**: PNG with transparent background
- **Icon**: Shopping bag design (similar to Material Icons shopping_bag)
- **Colors**: Use your app's primary color scheme
- **Style**: Simple, clean, recognizable

### Recommended Design:
- Shopping bag silhouette in your primary color
- Clean, minimal design
- Good contrast for visibility on various backgrounds
- Matches the aesthetic of your splash screen

## Instructions:
1. Create or design your shopping bag icon as `app_icon.png` (1024x1024)
2. Place the file in this folder
3. Run the following commands to generate all icon sizes and splash screens:
   ```
   flutter pub get
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```

## Current Status:
⚠️ **Action Required**: Add your shopping bag `app_icon.png` file to this folder

Once you add the icon file, the packages will automatically:
- Generate all required icon sizes for Android and iOS
- Create splash screens using the same icon for both platforms
- Configure Android 12+ splash screen support

### Quick Icon Creation Options:
1. **Design tools**: Figma, Canva, Adobe Illustrator
2. **Icon generators**: Use online icon generators with shopping bag templates
3. **AI tools**: Generate a shopping bag icon design
4. **Material Design**: Create a custom version of the Material shopping bag icon
