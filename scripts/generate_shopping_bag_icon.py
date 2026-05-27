"""
Generate app icon matching the sign-in screen design:
White shopping bag icon on #1A73E8 blue background.
"""
from PIL import Image, ImageDraw, ImageFont
import os, math

CANVAS = 2500
BLUE = (26, 115, 232, 255)    # #1A73E8
WHITE = (255, 255, 255, 255)
TRANSPARENT = (0, 0, 0, 0)

def draw_shopping_bag(draw, cx, cy, size):
    """Draw an isometric shopping bag icon centered at (cx, cy) with given size."""
    # Bag body - isometric rectangular shape
    w = size * 0.6
    h = size * 0.55
    
    # Bag main body (rectangle with rounded feel)
    x1 = cx - w/2
    y1 = cy - h/2
    x2 = cx + w/2
    y2 = cy + h/2
    
    # Draw slightly rounded rectangle for bag body
    r = size * 0.08
    draw.rounded_rectangle(
        [(x1, y1), (x2, y2)],
        radius=r,
        fill=WHITE,
        outline=None,
    )
    
    # Handle (curved top) - left side curve
    handle_width = size * 0.06
    handle_height = size * 0.35
    handle_gap = size * 0.05
    
    # Left handle line
    left_handle_x = cx - w/4 - handle_gap/2
    draw.arc(
        [(left_handle_x - handle_height/2, cy - h/2 - handle_height),
         (left_handle_x + handle_height/2, cy - h/2)],
        start=180, end=360,
        fill=WHITE,
        width=int(handle_width),
    )
    
    # Right handle line
    right_handle_x = cx + w/4 + handle_gap/2
    draw.arc(
        [(right_handle_x - handle_height/2, cy - h/2 - handle_height),
         (right_handle_x + handle_height/2, cy - h/2)],
        start=0, end=180,
        fill=WHITE,
        width=int(handle_width),
    )

def draw_shopping_bag_simple(draw, cx, cy, size):
    """Draw a simple shopping bag icon (rectangular body + curved handles + pocket/detail)."""
    w = size * 0.58
    h = size * 0.52
    line_w = max(int(size * 0.045), 3)
    
    # --- Bag body (rounded rectangle) ---
    r = int(size * 0.07)
    x1 = cx - w/2
    y1 = cy - h/2
    x2 = cx + w/2
    y2 = cy + h/2
    
    draw.rounded_rectangle(
        [(x1, y1), (x2, y2)],
        radius=r, fill=WHITE, outline=None
    )
    
    # --- Handles (two curved arcs) ---
    handle_w = size * 0.22
    handle_h = size * 0.32
    
    # Left handle
    lhx = cx - w/4
    lhb = cy - h/2  # bottom of handle = top of bag
    lht = lhb - handle_h  # top of handle
    
    # Use a chord/arc shape for left handle
    draw.arc(
        [(lhx - handle_w/2, lht), (lhx + handle_w/2, lhb)],
        start=0, end=180, fill=WHITE, width=line_w
    )
    
    # Right handle
    rhx = cx + w/4
    draw.arc(
        [(rhx - handle_w/2, lht), (rhx + handle_w/2, lhb)],
        start=0, end=180, fill=WHITE, width=line_w
    )
    
    # --- Horizontal line (bag opening / fold line) near top ---
    fold_y = y1 + size * 0.08
    draw.line(
        [(x1 + r, fold_y), (x2 - r, fold_y)],
        fill=BLUE, width=max(int(line_w * 0.6), 2)
    )
    
    # --- Pocket square on the bag ---
    pocket_size = size * 0.15
    px = cx
    py = cy + size * 0.02
    pocket_r = int(pocket_size * 0.12)
    draw.rounded_rectangle(
        [(px - pocket_size/2, py - pocket_size/2),
         (px + pocket_size/2, py + pocket_size/2)],
        radius=pocket_r,
        outline=BLUE,
        width=max(int(line_w * 0.4), 2),
    )

def main():
    assets_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "icon")
    
    # Generate main app_icon.png (2500x2500) - solid blue background with white icon
    img = Image.new('RGBA', (CANVAS, CANVAS), BLUE)
    draw = ImageDraw.Draw(img)
    
    cx, cy = CANVAS // 2, CANVAS // 2
    icon_size = CANVAS * 0.65
    
    # Draw the shopping bag
    draw_shopping_bag_simple(draw, cx, cy, icon_size)
    
    output_path = os.path.join(assets_dir, "app_icon.png")
    img.save(output_path, 'PNG')
    print(f"✓ Created: {output_path} ({CANVAS}x{CANVAS})")
    
    # Generate play_store_512.png (512x512) - same design
    img512 = Image.new('RGBA', (512, 512), BLUE)
    draw512 = ImageDraw.Draw(img512)
    
    cx512, cy512 = 512 // 2, 512 // 2
    icon_size512 = 512 * 0.62
    
    draw_shopping_bag_simple(draw512, cx512, cy512, icon_size512)
    
    play_store_path = os.path.join(assets_dir, "play_store_512.png")
    img512.save(play_store_path, 'PNG')
    print(f"✓ Created: {play_store_path} (512x512)")
    
    print("\nDone! Now run: flutter pub get && flutter pub run flutter_launcher_icons")

if __name__ == "__main__":
    main()