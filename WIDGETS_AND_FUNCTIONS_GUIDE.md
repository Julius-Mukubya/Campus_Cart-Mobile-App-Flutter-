# Campus Cart - Widgets & Functions Reference Guide

## 📋 Table of Contents
1. [HomeScreen](#homescreen)
2. [CategoriesScreen](#categoriesscreen)
3. [ProductDetails](#productdetails)
4. [WishlistScreen](#wishlistscreen)
5. [CartScreen](#cartscreen)

---

## 🏠 HomeScreen

### Main Widgets Used:

#### 1. **Scaffold**
- Purpose: Provides basic app structure
- Contains: AppBar, Body, BottomNavigationBar

#### 2. **AppBar**
- Purpose: Top navigation bar
- Widgets inside:
  - `Text.rich` with `TextSpan`: Shows "Welcome, User"
  - `IconButton` with `Badge`: Notification bell with unread count


#### 3. **Column** (Main Body)
- Purpose: Vertical layout of all content
- Children:
  - Fixed header (search + categories)
  - Scrollable content (banner + products)

#### 4. **Container** (Header Section)
- Purpose: Search bar and categories container
- Widgets inside:
  - **Row**: Search bar + Filter button
    - `Expanded` + `Container` + `TextField`: Search input
    - `Icon(Icons.search)`: Search icon
    - `GestureDetector` + `Container` + `Icon(Icons.tune)`: Filter button
  - **Text**: "Popular Categories" title
  - **SizedBox**: Category horizontal list
    - `ListView.builder`: Creates category chips
    - `GestureDetector`: Makes categories tappable
    - `Container` with `BoxDecoration`: Category circle
    - `Icon`: Category icon
    - `Text`: Category name


#### 5. **Expanded** + **SingleChildScrollView**
- Purpose: Scrollable content area
- Children:
  - **SizedBox** + **PageView.builder**: Banner slideshow
    - `ClipRRect`: Rounded corners
    - `Stack`: Overlays gradient and text
    - `Image.network`: Banner images
    - `Container` with gradient: Overlay
    - `Positioned`: Text positioning
    - `Row` with `List.generate`: Page indicators
  - **Row**: "Our Products" title
  - **GridView.builder**: Product grid
    - Uses `_buildProductCard()` for each item

#### 6. **AppBottomNavigation**
- Purpose: Bottom navigation bar
- Props: currentIndex, wishlistCount, cartCount


### Key Functions:

#### `filteredProducts` (Getter)
```dart
List<Map<String, dynamic>> get filteredProducts
```
- **Purpose**: Filters and sorts products based on user selections
- **Logic**:
  1. Filters by selected category
  2. Filters by price range (_minPrice to _maxPrice)
  3. Filters by minimum rating (_minRating)
  4. Sorts based on _sortBy value
- **Returns**: Filtered list of products

#### `_extractPrice(String priceString)`
```dart
double _extractPrice(String priceString)
```
- **Purpose**: Extracts numeric value from price string
- **Input**: "UGX 85,000"
- **Output**: 85000.0
- **How**: Removes all non-numeric characters using RegExp

#### `_getDiscountedPrice(Map<String, dynamic> product)`
```dart
double _getDiscountedPrice(Map<String, dynamic> product)
```
- **Purpose**: Calculates final price after discount
- **Logic**:
  1. Gets original price
  2. Extracts discount percentage
  3. Calculates discount amount
  4. Returns price - discount
- **Returns**: Final price as double


#### `_buildPriceSection(Map<String, dynamic> product)`
```dart
Widget _buildPriceSection(Map<String, dynamic> product)
```
- **Purpose**: Displays price with or without discount
- **Returns**: 
  - If discount exists: Row with strikethrough original + discounted price
  - If no discount: Single price text
- **Widgets**: Row, Flexible, Text, SizedBox

#### `_buildProductCard(Map<String, dynamic> product)`
```dart
Widget _buildProductCard(Map<String, dynamic> product)
```
- **Purpose**: Creates individual product card
- **Structure**:
  - Container (card wrapper)
  - Column (vertical layout)
    - Stack (image + badges)
      - Container + ClipRRect + Image.network (product image)
      - Positioned + Container (discount badge)
      - Positioned + GestureDetector (wishlist button)
    - SizedBox + Padding (product details)
      - Text (product name)
      - Row (rating + cart button)
      - Price section
- **Returns**: Complete product card widget


#### `_showFilterDialog()`
```dart
void _showFilterDialog()
```
- **Purpose**: Opens filter bottom sheet
- **Uses**: showModalBottomSheet with StatefulBuilder
- **Contains**:
  - Sort options (Wrap with GestureDetector chips)
  - Price range slider (RangeSlider)
  - Rating selector (Row with star Icons)
  - Apply button (ElevatedButton)
- **State Variables**:
  - _sortBy: Current sort option
  - _minPrice, _maxPrice: Price range
  - _minRating: Minimum rating filter

#### `_autoScrollBanner()`
```dart
void _autoScrollBanner()
```
- **Purpose**: Auto-scrolls banner every 3 seconds
- **Logic**:
  1. Checks if widget is still mounted
  2. Calculates next page index
  3. Animates to next page
  4. Schedules next scroll with Future.delayed

#### `_onWishlistChanged()` & `_onCartChanged()`
```dart
void _onWishlistChanged()
void _onCartChanged()
```
- **Purpose**: Rebuilds UI when wishlist/cart changes
- **Called by**: WishlistManager and CartManager listeners
- **Action**: Calls setState() to trigger rebuild


---

## 📂 CategoriesScreen

### Main Widgets Used:

#### 1. **Scaffold**
- AppBar with title "Categories"
- Body with SafeArea
- BottomNavigationBar

#### 2. **Padding** + **Column**
- Purpose: Main layout container
- Children:
  - Header section (search + filter)
  - Categories grid

#### 3. **Container** (Header Section)
- Purpose: Search and filter area
- Widgets:
  - **Row**: Search bar + Filter button
    - `Expanded` + `Container` + `TextField`: Search input
    - `GestureDetector` + `Container` + `Icon(Icons.tune)`: Filter button

#### 4. **Expanded** + **GridView.builder**
- Purpose: Displays category cards in grid
- Properties:
  - crossAxisCount: 2 (2 columns)
  - crossAxisSpacing: 16
  - mainAxisSpacing: 16
  - childAspectRatio: 0.59
- Uses: `_buildCategoryCard()` for each category


### Key Functions:

#### `filteredCategories` (Getter)
```dart
List<Map<String, dynamic>> get filteredCategories
```
- **Purpose**: Filters and sorts categories
- **Logic**:
  1. Filters by search query (name or description)
  2. Sorts based on _sortBy:
     - Name: A to Z / Z to A
     - Most/Least Products
- **Returns**: Filtered category list

#### `_getProductCount(String categoryTitle)`
```dart
int _getProductCount(String categoryTitle)
```
- **Purpose**: Counts products in a category
- **Input**: Category name (e.g., "Electronics")
- **Returns**: Number of products in that category
- **How**: Filters allProducts by category and returns length

#### `_buildCategoryCard(Map<String, dynamic> category)`
```dart
Widget _buildCategoryCard(Map<String, dynamic> category)
```
- **Purpose**: Creates category card
- **Structure**:
  - Container (card wrapper)
  - Column
    - SizedBox + Stack (category image)
      - Container + ClipRRect + Image.network
      - Positioned (product count badge)
      - Positioned (category icon)
    - Padding (category details)
      - Text (category title)
      - Text (category description)
      - Row (product count + arrow icon)
- **Returns**: Complete category card


#### `_showFilterDialog()`
```dart
void _showFilterDialog()
```
- **Purpose**: Opens sort options bottom sheet
- **Contains**:
  - Sort options (Default, Name A-Z, Name Z-A, Most/Least Products)
  - Reset button
  - Apply button
- **State Variables**:
  - _sortBy: Current sort selection
  - _tempSortBy: Temporary selection (only applied on button press)

#### `_onSearchChanged(String value)` (via TextField)
```dart
onChanged: (value) {
  setState(() {
    _searchQuery = value;
  });
}
```
- **Purpose**: Updates search query in real-time
- **Triggers**: filteredCategories getter to re-filter

---

## 🔍 ProductDetails

### Main Widgets Used:

#### 1. **Scaffold**
- AppBar with back button and product name
- Body with SingleChildScrollView

#### 2. **SingleChildScrollView** + **Column**
- Purpose: Scrollable product details
- Children:
  - Product image section
  - Product info section
  - Reviews section


#### 3. **Container** (Product Image)
- Purpose: Large product image with badges
- Widgets:
  - **Stack**:
    - `ClipRRect` + `Image.network`: Product image
    - `Positioned` (top-left): Discount badge
    - `Positioned` (top-right): Wishlist button

#### 4. **Padding** (Product Info)
- Purpose: Product details section
- Widgets:
  - **Row**: Price + Rating
    - `_buildMainPriceSection()`: Price display
    - `Container` with star icon: Rating badge
  - **Text**: "Description" title
  - **Text**: Product description
  - **Container** + **ElevatedButton.icon**: Add to Cart button
    - Changes to "View Cart" if already in cart
    - Icon changes based on cart status

#### 5. **Reviews Section**
- Widgets:
  - **Text**: "Reviews" title
  - **Row**: Rating summary
    - `Column`: Overall rating (4.5/5) with stars
    - `Expanded` + `Column`: Rating bars (5-star breakdown)
  - **List of review cards**: User reviews
    - `Container` with `Row`:
      - `CircleAvatar`: User icon
      - `Column`: User name, comment, time


#### 6. **Write Review Section**
- Widgets:
  - **Container** with Column:
    - Text: "Write a Review"
    - Row: Rating stars (tappable)
    - TextField: Review input
    - ElevatedButton: Submit button

#### 7. **Related Products Section**
- Widgets:
  - **Text**: "You May Also Like"
  - **Wrap**: Grid of related product cards
    - Uses `_buildProductCard()` for each item

### Key Functions:

#### `_buildMainPriceSection()`
```dart
Widget _buildMainPriceSection()
```
- **Purpose**: Displays large price for product details
- **Returns**: 
  - Column with strikethrough + discounted price (if discount)
  - Single large price text (if no discount)
- **Font Size**: Larger than product card prices (22px)

#### `relatedProducts` (Getter)
```dart
List<Map<String, dynamic>> get relatedProducts
```
- **Purpose**: Gets similar products
- **Logic**:
  1. Gets products from same category
  2. Excludes current product
  3. If less than 4, adds products from other categories
  4. Returns up to 4 products
- **Returns**: List of related products


#### `_buildRatingBar(int stars, double percentage)`
```dart
Widget _buildRatingBar(int stars, double percentage)
```
- **Purpose**: Creates rating distribution bar
- **Input**: Star count (1-5) and percentage (0.0-1.0)
- **Structure**:
  - Row with:
    - Text: Star number
    - Expanded + Stack: Progress bar
      - Container (background)
      - Container (filled portion based on percentage)
    - Text: Percentage
- **Returns**: Rating bar widget

#### `_buildProductCard(Map<String, dynamic> product)`
```dart
Widget _buildProductCard(Map<String, dynamic> product)
```
- **Purpose**: Creates product card for related products
- **Same as HomeScreen**: Uses identical structure
- **Returns**: Product card widget

---

## ❤️ WishlistScreen

### Main Widgets Used:

#### 1. **Scaffold**
- AppBar with "My Wishlist" title
- Body with conditional rendering:
  - Empty state if no items
  - Product list if items exist
- BottomNavigationBar


#### 2. **Empty State** (`_buildEmptyState()`)
- Purpose: Shows when wishlist is empty
- Widgets:
  - **Center** + **Column**:
    - `Container` with `Icon(Icons.favorite_border)`: Large heart icon
    - `Text`: "Your Wishlist is Empty"
    - `Text`: Description message
    - `ElevatedButton`: "Start Shopping" button

#### 3. **Padding** + **Column** (With Items)
- Purpose: Main layout when items exist
- Children:
  - Header section (search + view toggle)
  - Item count and clear button
  - Product grid/list

#### 4. **Container** (Header Section)
- Purpose: Search and view toggle
- Widgets:
  - **Row**:
    - `Expanded` + `TextField`: Search input
    - `GestureDetector` + `Icon`: Grid/List toggle button

#### 5. **Row** (Item Count)
- Purpose: Shows count and clear all button
- Widgets:
  - `Text`: "X items in wishlist"
  - `Spacer`
  - `TextButton`: "Clear All" button


#### 6. **Expanded** + **GridView.builder** (Grid View)
- Purpose: Displays wishlist items in grid
- Properties: Same as HomeScreen grid
- Uses: `_buildGridCard()` for each item

#### 7. **Expanded** + **ListView.builder** (List View)
- Purpose: Displays wishlist items in list
- Uses: `_buildListCard()` for each item

### Key Functions:

#### `_filterItems()`
```dart
void _filterItems()
```
- **Purpose**: Filters wishlist based on search query
- **Logic**:
  - If search empty: Shows all items
  - If search exists: Filters by name or category
- **Updates**: _filteredItems list

#### `_onSearchChanged(String value)`
```dart
void _onSearchChanged(String value)
```
- **Purpose**: Handles search input changes
- **Actions**:
  1. Updates _searchQuery
  2. Calls _filterItems()
  3. Calls setState() to rebuild

#### `removeItem(String productName)`
```dart
void removeItem(String productName)
```
- **Purpose**: Removes item from wishlist
- **Actions**:
  1. Calls _wishlistManager.removeFromWishlist()
  2. Shows SnackBar confirmation


#### `addToCart(Map<String, dynamic> item)`
```dart
void addToCart(Map<String, dynamic> item)
```
- **Purpose**: Adds wishlist item to cart
- **Actions**:
  1. Calls _cartManager.addToCart()
  2. Shows success SnackBar
  3. UI updates automatically via listener

#### `_buildGridCard(Map<String, dynamic> item)`
```dart
Widget _buildGridCard(Map<String, dynamic> item)
```
- **Purpose**: Creates grid view product card
- **Structure**: Similar to HomeScreen product card
- **Differences**:
  - Remove button instead of wishlist button
  - Cart button changes color/icon when item in cart
- **Returns**: Grid card widget

#### `_buildListCard(Map<String, dynamic> item)`
```dart
Widget _buildListCard(Map<String, dynamic> item)
```
- **Purpose**: Creates list view product card
- **Structure**:
  - Container + Row:
    - Product image (80x80)
    - Expanded Column:
      - Row: Name + Delete button
      - Row: Category badge + Rating
      - Row: Price + Add to Cart button
- **Returns**: List card widget

#### `_onWishlistChanged()` & `_onCartChanged()`
```dart
void _onWishlistChanged()
void _onCartChanged()
```
- **Purpose**: Rebuilds UI when wishlist/cart changes
- **Triggers**: setState() to update UI


---

## 🛒 CartScreen

### Main Widgets Used:

#### 1. **Scaffold**
- AppBar with "My Cart" title
- Body with conditional rendering:
  - Empty state if no items
  - Cart items + checkout section if items exist

#### 2. **Empty State** (`_buildEmptyState()`)
- Purpose: Shows when cart is empty
- Widgets:
  - **Center** + **Column**:
    - `Container` with `Icon(Icons.shopping_cart_outlined)`: Large cart icon
    - `Text`: "Your Cart is Empty"
    - `Text`: Description message
    - `ElevatedButton`: "Start Shopping" button

#### 3. **Column** (With Items)
- Purpose: Main layout when cart has items
- Children:
  - Cart items list
  - Order summary section
  - Checkout button

#### 4. **Expanded** + **ListView.builder**
- Purpose: Displays cart items
- Uses: `_buildCartItem()` for each item
- Scrollable list of products in cart


#### 5. **Container** (Order Summary)
- Purpose: Shows price breakdown
- Widgets:
  - **Column**:
    - `Text`: "Order Summary" title
    - `Row`: Subtotal label + amount
    - `Row`: Discount label + amount
    - `Divider`: Separator line
    - `Row`: Total label + amount (bold)

#### 6. **Container** + **ElevatedButton**
- Purpose: Checkout button
- Widgets:
  - **ElevatedButton** with gradient background
  - **Row**: Icon + "Proceed to Checkout" text
  - Full width button with rounded corners

### Key Functions:

#### `_buildCartItem(Map<String, dynamic> item)`
```dart
Widget _buildCartItem(Map<String, dynamic> item)
```
- **Purpose**: Creates individual cart item card
- **Structure**:
  - Container + Row:
    - Product image (80x80)
    - Expanded Column:
      - Row: Name + Delete button
      - Text: Category
      - Row: Price
      - Row: Quantity controls
        - Decrease button (-)
        - Quantity text
        - Increase button (+)
- **Returns**: Cart item widget


#### `_calculateSubtotal()`
```dart
double _calculateSubtotal()
```
- **Purpose**: Calculates total before discounts
- **Logic**:
  1. Loops through all cart items
  2. Gets discounted price for each
  3. Multiplies by quantity
  4. Sums all items
- **Returns**: Subtotal as double

#### `_calculateDiscount()`
```dart
double _calculateDiscount()
```
- **Purpose**: Calculates total discount amount
- **Logic**:
  1. Loops through all cart items
  2. Calculates discount per item (original - discounted)
  3. Multiplies by quantity
  4. Sums all discounts
- **Returns**: Total discount as double

#### `_calculateTotal()`
```dart
double _calculateTotal()
```
- **Purpose**: Calculates final amount to pay
- **Formula**: Subtotal - Discount
- **Returns**: Total as double

#### `_updateQuantity(String productName, int newQuantity)`
```dart
void _updateQuantity(String productName, int newQuantity)
```
- **Purpose**: Updates item quantity in cart
- **Actions**:
  1. Validates quantity (minimum 1)
  2. Calls _cartManager.updateQuantity()
  3. UI updates automatically via listener


#### `_removeFromCart(String productName)`
```dart
void _removeFromCart(String productName)
```
- **Purpose**: Removes item from cart
- **Actions**:
  1. Calls _cartManager.removeFromCart()
  2. Shows SnackBar confirmation
  3. UI updates automatically

#### `_onCartChanged()`
```dart
void _onCartChanged()
```
- **Purpose**: Rebuilds UI when cart changes
- **Triggers**: setState() to recalculate totals and update UI

---

## 🔧 Common Widgets Across All Screens

### 1. **Container**
- **Purpose**: Box model widget for styling
- **Properties**:
  - padding: Inner spacing
  - margin: Outer spacing
  - decoration: BoxDecoration for styling
  - child: Single child widget

### 2. **BoxDecoration**
- **Purpose**: Styles containers
- **Properties**:
  - color: Background color
  - borderRadius: Rounded corners
  - boxShadow: Drop shadows
  - gradient: Color gradients
  - border: Border styling


### 3. **Row** & **Column**
- **Purpose**: Layout widgets
- **Row**: Horizontal arrangement
- **Column**: Vertical arrangement
- **Properties**:
  - children: List of widgets
  - mainAxisAlignment: Primary axis alignment
  - crossAxisAlignment: Cross axis alignment
  - mainAxisSize: Size behavior

### 4. **Stack**
- **Purpose**: Overlays widgets on top of each other
- **Children**: List of widgets (first = bottom, last = top)
- **Used with**: Positioned widget for precise placement

### 5. **Positioned**
- **Purpose**: Positions child within Stack
- **Properties**:
  - top, bottom, left, right: Distance from edges
  - Must be child of Stack

### 6. **GestureDetector**
- **Purpose**: Detects user interactions
- **Properties**:
  - onTap: Single tap handler
  - onDoubleTap: Double tap handler
  - onLongPress: Long press handler
  - child: Widget to make interactive

### 7. **Image.network**
- **Purpose**: Loads images from internet
- **Properties**:
  - URL string
  - fit: How image fills space (cover, contain, etc.)
  - errorBuilder: Widget shown on error
  - loadingBuilder: Widget shown while loading


### 8. **Text**
- **Purpose**: Displays text
- **Properties**:
  - String content
  - style: TextStyle for formatting
  - maxLines: Maximum lines to show
  - overflow: How to handle overflow (ellipsis, clip, etc.)

### 9. **TextStyle**
- **Purpose**: Styles text
- **Properties**:
  - fontSize: Text size
  - fontWeight: Bold, normal, etc.
  - color: Text color
  - decoration: Underline, strikethrough, etc.
  - height: Line height

### 10. **Icon**
- **Purpose**: Displays material icons
- **Properties**:
  - IconData (e.g., Icons.favorite)
  - size: Icon size
  - color: Icon color

### 11. **SizedBox**
- **Purpose**: Fixed size box or spacing
- **Properties**:
  - width: Fixed width
  - height: Fixed height
  - child: Optional child widget
- **Common use**: Spacing between widgets

### 12. **Expanded**
- **Purpose**: Fills available space in Row/Column
- **Properties**:
  - flex: Proportion of space to take
  - child: Widget to expand


### 13. **ListView.builder**
- **Purpose**: Creates scrollable list efficiently
- **Properties**:
  - itemCount: Number of items
  - itemBuilder: Function that builds each item
  - scrollDirection: Vertical or horizontal
  - physics: Scroll behavior

### 14. **GridView.builder**
- **Purpose**: Creates scrollable grid efficiently
- **Properties**:
  - itemCount: Number of items
  - itemBuilder: Function that builds each item
  - gridDelegate: Defines grid layout
    - crossAxisCount: Number of columns
    - crossAxisSpacing: Horizontal spacing
    - mainAxisSpacing: Vertical spacing
    - childAspectRatio: Width/height ratio

### 15. **TextField**
- **Purpose**: Text input field
- **Properties**:
  - controller: TextEditingController for managing text
  - onChanged: Callback when text changes
  - decoration: InputDecoration for styling
  - hintText: Placeholder text

### 16. **ElevatedButton**
- **Purpose**: Raised button with elevation
- **Properties**:
  - onPressed: Tap handler
  - style: ButtonStyle for customization
  - child: Button content (usually Text or Row)


### 17. **SnackBar**
- **Purpose**: Shows temporary message at bottom
- **Properties**:
  - content: Widget to display (usually Text)
  - backgroundColor: Background color
  - behavior: Floating or fixed
  - duration: How long to show
  - shape: Border shape
- **Usage**: `ScaffoldMessenger.of(context).showSnackBar()`

### 18. **CircularProgressIndicator**
- **Purpose**: Shows loading spinner
- **Properties**:
  - strokeWidth: Thickness of circle
  - valueColor: Color of spinner
- **Used in**: Image loading states

### 19. **ClipRRect**
- **Purpose**: Clips child with rounded corners
- **Properties**:
  - borderRadius: Corner radius
  - child: Widget to clip
- **Common use**: Rounded images

### 20. **Divider**
- **Purpose**: Horizontal line separator
- **Properties**:
  - color: Line color
  - thickness: Line thickness
  - height: Total height including spacing

---

## 📊 State Management Pattern

### ChangeNotifier Pattern (Used in Services)

#### How it works:
1. **Service extends ChangeNotifier**
```dart
class CartManager extends ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  
  void addToCart(product) {
    _cartItems.add(product);
    notifyListeners(); // Tells all listeners to update
  }
}
```


2. **Screen creates instance and adds listener**
```dart
class _HomeScreenState extends State<HomeScreen> {
  final CartManager _cartManager = CartManager();
  
  @override
  void initState() {
    super.initState();
    _cartManager.addListener(_onCartChanged);
  }
  
  void _onCartChanged() {
    setState(() {}); // Rebuilds UI
  }
  
  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    super.dispose();
  }
}
```

3. **When data changes, all listeners are notified**
```dart
// User adds item to cart
_cartManager.addToCart(product);
  ↓
// CartManager calls notifyListeners()
  ↓
// All screens listening to CartManager rebuild
  ↓
// UI updates automatically (cart count, button states, etc.)
```

---

## 🎨 Styling Patterns

### Gradient Backgrounds
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppColors.primary.withOpacity(0.1),
        AppColors.secondary.withOpacity(0.05),
      ],
    ),
  ),
)
```


### Box Shadows
```dart
Container(
  decoration: BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.12),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  ),
)
```

### Rounded Corners
```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(20),
  ),
)

// Or specific corners
BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
)
```

### Badges
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: AppColors.accent,
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    '-20%',
    style: TextStyle(
      color: AppColors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
)
```

---

## 🔄 Navigation Patterns

### Push to new screen
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ProductDetailScreen(product: product),
  ),
);
```

### Pop back
```dart
Navigator.pop(context);
```

### Named routes
```dart
Navigator.pushNamed(context, '/cart');
```


---

## 📱 Bottom Sheet Pattern

### Show Modal Bottom Sheet
```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => StatefulBuilder(
    builder: (context, setModalState) => Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Content here
        ],
      ),
    ),
  ),
);
```

**Key Points:**
- `StatefulBuilder`: Allows setState within bottom sheet
- `setModalState`: Updates bottom sheet UI
- `isScrollControlled`: Allows custom height
- `backgroundColor: Colors.transparent`: For rounded corners

---

## 🎯 Quick Reference Table

| Widget | Purpose | Common Properties |
|--------|---------|-------------------|
| Scaffold | App structure | appBar, body, bottomNavigationBar |
| Container | Box with styling | padding, margin, decoration, child |
| Row | Horizontal layout | children, mainAxisAlignment |
| Column | Vertical layout | children, crossAxisAlignment |
| Stack | Overlay widgets | children |
| ListView.builder | Scrollable list | itemCount, itemBuilder |
| GridView.builder | Scrollable grid | itemCount, gridDelegate |
| Text | Display text | style, maxLines, overflow |
| Image.network | Load image | URL, fit, errorBuilder |
| GestureDetector | Handle taps | onTap, child |
| ElevatedButton | Raised button | onPressed, child, style |
| TextField | Text input | controller, onChanged, decoration |
| Icon | Material icon | IconData, size, color |
| SizedBox | Fixed size/spacing | width, height, child |
| Expanded | Fill space | flex, child |
| Padding | Add padding | padding, child |
| ClipRRect | Rounded clip | borderRadius, child |


---

## 🔍 Function Categories

### Price Calculation Functions
- `_extractPrice()`: Converts price string to number
- `_getDiscountedPrice()`: Calculates price after discount
- `_calculateSubtotal()`: Sums all cart items
- `_calculateDiscount()`: Sums all discounts
- `_calculateTotal()`: Final amount to pay

### UI Builder Functions
- `_buildProductCard()`: Creates product card
- `_buildCategoryCard()`: Creates category card
- `_buildCartItem()`: Creates cart item
- `_buildGridCard()`: Creates grid view card
- `_buildListCard()`: Creates list view card
- `_buildPriceSection()`: Displays price with discount
- `_buildRatingBar()`: Creates rating distribution bar
- `_buildEmptyState()`: Shows empty state message

### Filter/Sort Functions
- `filteredProducts`: Filters and sorts products
- `filteredCategories`: Filters and sorts categories
- `relatedProducts`: Gets similar products
- `_filterItems()`: Filters wishlist items

### Dialog Functions
- `_showFilterDialog()`: Opens filter bottom sheet

### State Management Functions
- `_onWishlistChanged()`: Handles wishlist updates
- `_onCartChanged()`: Handles cart updates
- `setState()`: Triggers UI rebuild

### Action Functions
- `addToCart()`: Adds item to cart
- `removeItem()`: Removes from wishlist
- `_removeFromCart()`: Removes from cart
- `_updateQuantity()`: Changes item quantity
- `toggleWishlist()`: Adds/removes from wishlist

---

## 💡 Tips for Presentation

### When Explaining Widgets:
1. **Start with the structure**: "This screen uses a Scaffold with..."
2. **Explain the layout**: "Inside, we have a Column that contains..."
3. **Highlight key features**: "The product card uses a Stack to overlay badges..."
4. **Show the interaction**: "When user taps, GestureDetector calls..."

### When Explaining Functions:
1. **State the purpose**: "This function calculates the discounted price..."
2. **Explain the logic**: "It extracts the original price, then..."
3. **Show the result**: "Finally, it returns the price after discount"

### Demo Flow:
1. **Home Screen**: Show categories, filtering, product cards
2. **Tap Product**: Explain navigation and product details
3. **Add to Wishlist**: Show state update and icon change
4. **Add to Cart**: Show cart badge update
5. **Go to Cart**: Show quantity controls and price calculation
6. **Go to Wishlist**: Show saved items and search

---

**End of Guide** ✅

This document covers all major widgets and functions used in the Campus Cart app. Use it as a reference during your presentation to explain how each screen works!
