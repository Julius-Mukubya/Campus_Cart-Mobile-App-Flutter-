"""
Script to create a properly padded adaptive icon foreground image
Run: python create_adaptive_icon.py
Requires: pip install Pillow
"""

from PIL import Image
import os

def create_adaptive_foreground(input_path, output_path):
    """
    Creates an adaptive icon foreground with proper padding
    The icon will occupy 66% of the canvas (safe zone)
    """
    # Open the original icon
    original = Image.open(input_path)
    
    # Convert to RGBA if not already
    if original.mode != 'RGBA':
        original = original.convert('RGBA')
    
    # Create new canvas (1024x1024 for high quality)
    canvas_size = 1024
    safe_zone_size = int(canvas_size * 0.66)  # 675px
    
    # Create transparent canvas
    canvas = Image.new('RGBA', (canvas_size, canvas_size), (0, 0, 0, 0))
    
    # Resize original icon to fit safe zone
    original_resized = original.resize((safe_zone_size, safe_zone_size), Image.Resampling.LANCZOS)
    
    # Calculate position to center the icon
    position = ((canvas_size - safe_zone_size) // 2, (canvas_size - safe_zone_size) // 2)
    
    # Paste the resized icon onto the canvas
    canvas.paste(original_resized, position, original_resized)
    
    # Save the result
    canvas.save(output_path, 'PNG')
    print(f"✓ Created adaptive icon foreground: {output_path}")
    print(f"  Canvas: {canvas_size}x{canvas_size}px")
    print(f"  Icon size: {safe_zone_size}x{safe_zone_size}px (66% safe zone)")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    input_icon = os.path.join(script_dir, "assets", "icon", "app_icon.png")
    output_icon = os.path.join(script_dir, "assets", "icon", "app_icon_foreground.png")
    
    if not os.path.exists(input_icon):
        print(f"Error: Could not find {input_icon}")
        exit(1)
    
    try:
        create_adaptive_foreground(input_icon, output_icon)
        print("\nNext steps:")
        print("1. Update pubspec.yaml to use 'app_icon_foreground.png'")
        print("2. Run: flutter pub get")
        print("3. Run: flutter pub run flutter_launcher_icons")
    except ImportError:
        print("Error: Pillow library not found")
        print("Install it with: pip install Pillow")
        exit(1)
    except Exception as e:
        print(f"Error: {e}")
        exit(1)
