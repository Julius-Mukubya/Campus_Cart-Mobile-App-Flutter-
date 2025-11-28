# Campus Cart - Mobile Shopping App Documentation

## 📱 Overview
Campus Cart is a mobile e-commerce application built with Flutter that allows users to browse products, manage wishlists, add items to cart, and complete purchases. The app is designed specifically for campus shopping needs.

---

## 🏗️ Project Structure

```
lib/
├── main.dart                    # App entry point
├── constants/                   # App-wide constants
│   └── app_colors.dart         # Color definitions
├── pages/                       # All screen/page files
│   ├── HomeScreen.dart         # Main home page
│   ├── CategoriesScreen.dart   # Categories listing
│   ├── ProductDetails.dart     # Product detail view
│   ├── WishlistScreen.dart     # Saved items
│   ├── CartScreen.dart         # Shopping cart
│   ├── ProfileScreen.dart      # User profile
│   ├── SignInScreen.dart       # Login page
│   ├── SignUpScreen.dart       # Registration page
│   └── ... (other screens)
├── services/                    # Business logic & data management
│   ├── cart_manager.dart       # Cart operations
│   ├── wishlist_manager.dart   # Wishlist operations
│   └── notification_manager.dart # Notifications
└── widgets/                     # Reusable UI components
    ├── app_bottom_navigation.dart # Bottom nav bar
    └── notification_icon.dart      # Notification bell icon
```

---

## 🎯 Key Features

### 1. **Home Screen** (`HomeScreen.dart`)
- **Banner Slideshow**: Auto-scrolling promotional banners
- **Category Filter**: Horizontal scrollable category chips (All, Electronics, Fashion, etc.)
- **Product Grid**: Displays products with images, prices, ratings, and discounts
- **Search Bar**: Search for products
- **Filter Button**: Sort and filter products by price, rating, name
- **Add to Cart/Wishlist**: Quick actions on each product card

**Key Functions:**
- `filteredProducts`: Filters products by category, price range, and rating
- `_showFilterDialog()`: Opens bottom sheet with filter options
- `_buildProductCard()`: Creates individual product cards

### 2. **Categories Screen** (`CategoriesScreen.dart`)
- **Category Cards**: Visual cards for each product category
- **Product Count**: Shows number of items in each category
- **Search**: Filter categories by name
- **Sort Options**: Sort categories by name or product count
- **Navigation**: Tap category to view its products

**Key Functions:**
- `filteredCategories`: Filters and sorts category list
- `_showFilterDialog()`: Category sorting options
- `CategoryProductsScreen`: Separate screen showing products in selected category

### 3. **Product Details** (`ProductDetails.dart`)
- **Large Product Image**: Full-width product photo
- **Price Display**: Shows original and discounted prices
- **Rating & Reviews**: Star ratings and user reviews
- **Description**: Detailed product information
- **Add to Cart Button**: Changes to "View Cart" if already added
- **Wishlist Toggle**: Heart icon to save/unsave
- **Related Products**: Shows similar items at bottom

**Key Functions:**
- `_getDiscountedPrice()`: Calculates price after discount
- `relatedProducts`: Gets products from same category

### 4. **Wishlist Screen** (`WishlistScreen.dart`)
- **Saved Items**: All products user has favorited
- **Grid/List View Toggle**: Switch between layouts
- **Search**: Filter wishlist items
- **Remove Items**: Delete from wishlist
- **Add to Cart**: Quick add from wishlist
- **Empty State**: Friendly message when no items

**Key Functions:**
- `_filterItems()`: Searches through wishlist
- `removeItem()`: Removes from wishlist
- `addToCart()`: Adds wishlist item to cart

### 5. **Cart Screen** (`CartScreen.dart`)
- **Cart Items**: List of products to purchase
- **Quantity Controls**: Increase/decrease item quantity
- **Price Calculation**: Subtotal, discount, and total
- **Remove Items**: Delete from cart
- **Checkout Button**: Proceed to payment

---

## 🔧 Services (Business Logic)

### **Cart Manager** (`cart_manager.dart`)
Manages shopping cart operations using Flutter's `ChangeNotifier` pattern.

**Key Methods:**
- `addToCart(product)`: Adds item to cart
- `removeFromCart(productName)`: Removes item
- `updateQuantity(productName, quantity)`: Changes item quantity
- `isInCart(productName)`: Checks if item exists in cart
- `itemCount`: Total number of items
- `clearCart()`: Empties the cart

**How it works:**
```dart
// Add item to cart
_cartManager.addToCart(product);

// Check if in cart
if (_cartManager.isInCart('Wireless Headphones')) {
  // Show "In Cart" button
}

// Listen to changes
_cartManager.addListener(() {
  setState(() {}); // Rebuild UI when cart changes
});
```

### **Wishlist Manager** (`wishlist_manager.dart`)
Manages saved/favorite items.

**Key Methods:**
- `toggleWishlist(product)`: Add/remove from wishlist
- `isInWishlist(productName)`: Check if item is saved
- `removeFromWishlist(productName)`: Remove item
- `wishlistItems`: List of all saved items
- `itemCount`: Number of saved items

### **Notification Manager** (`notification_manager.dart`)
Handles app notifications.

**Key Methods:**
- `addNotification(title, message)`: Create notification
- `markAsRead(id)`: Mark notification as read
- `unreadCount`: Number of unread notifications

---

## 🎨 Design System

### **Colors** (`app_colors.dart`)
Centralized color definitions for consistent UI:

```dart
AppColors.primary      // Main brand color (blue)
AppColors.secondary    // Secondary color
AppColors.accent       // Accent color (for highlights)
AppColors.background   // Screen background
AppColors.text         // Primary text color
AppColors.secondaryText // Lighter text
AppColors.error        // Error messages
AppColors.success      // Success messages
```

### **Widgets** (Reusable Components)

**Bottom Navigation** (`app_bottom_navigation.dart`)
- 5 tabs: Home, Categories, Cart, Wishlist, Profile
- Shows badge counts for cart and wishlist
- Highlights active tab

**Notification Icon** (`notification_icon.dart`)
- Bell icon with unread count badge
- Opens notifications list

---

## 📊 Data Flow

### How Products Work:
1. **Product Data**: Stored as `List<Map<String, dynamic>>` in each screen
2. **Product Structure**:
```dart
{
  'name': 'Wireless Headphones',
  'price': 'UGX 85,000',
  'rating': 4.8,
  'discount': '-20%',
  'category': 'Electronics',
  'image': 'https://...',
  'description': '...'
}
```

### State Management:
- **ChangeNotifier Pattern**: Used for cart, wishlist, and notifications
- **setState()**: Updates UI when data changes
- **Listeners**: Screens listen to manager changes and rebuild

### Example Flow - Adding to Cart:
```
User taps "Add to Cart" 
    ↓
CartManager.addToCart() called
    ↓
Cart list updated
    ↓
notifyListeners() called
    ↓
All listening widgets rebuild
    ↓
UI shows updated cart count
```

---

## 🚀 Key Concepts for Beginners

### 1. **StatefulWidget vs StatelessWidget**
- **StatefulWidget**: Can change over time (e.g., HomeScreen with filters)
- **StatelessWidget**: Never changes (e.g., static text)

### 2. **setState()**
Tells Flutter to rebuild the widget with new data:
```dart
setState(() {
  selectedCategory = 'Electronics'; // Update data
}); // UI rebuilds automatically
```

### 3. **Navigator**
Handles screen navigation:
```dart
// Go to new screen
Navigator.push(context, MaterialPageRoute(
  builder: (context) => ProductDetailScreen(product: product)
));

// Go back
Navigator.pop(context);
```

### 4. **Async Operations**
Loading images from internet:
```dart
Image.network(
  product['image'],
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;
    return CircularProgressIndicator(); // Show loading
  },
)
```

### 5. **Builders**
Create lists efficiently:
```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    return ProductCard(product: products[index]);
  },
)
```

---

## 🎓 Presentation Tips

### App Highlights to Mention:

1. **User-Friendly Interface**
   - Clean, modern design
   - Easy navigation with bottom bar
   - Visual feedback (colors change when items added)

2. **Smart Features**
   - Filter & sort products
   - Search functionality
   - Wishlist for saving items
   - Real-time cart updates

3. **Technical Implementation**
   - Flutter framework (cross-platform)
   - State management with ChangeNotifier
   - Responsive design
   - Network image loading

4. **User Experience**
   - Discount badges
   - Product ratings
   - Empty states with helpful messages
   - Smooth animations

### Demo Flow Suggestion:
1. Start on Home Screen → Show categories
2. Filter products → Demonstrate filter options
3. Tap product → Show details page
4. Add to wishlist → Show heart animation
5. Add to cart → Show cart badge update
6. Go to Categories → Show category navigation
7. Go to Wishlist → Show saved items
8. Go to Cart → Show checkout flow

---

## 🐛 Common Issues & Solutions

### Images not loading?
- Check internet connection
- Verify internet permissions in AndroidManifest.xml
- Images have error handlers showing placeholder icons

### State not updating?
- Ensure `setState()` is called
- Check if listeners are properly added/removed
- Verify ChangeNotifier is being used correctly

### Navigation issues?
- Check route names in main.dart
- Ensure context is available
- Use Navigator.pop() to go back

---

## 📝 Code Examples

### Adding a New Product:
```dart
{
  'name': 'New Product',
  'price': 'UGX 50,000',
  'rating': 4.5,
  'discount': '-15%',
  'category': 'Electronics',
  'image': 'https://your-image-url.com',
  'description': 'Product description here',
}
```

### Creating a Filter:
```dart
List<Map<String, dynamic>> get filteredProducts {
  var products = allProducts;
  
  // Filter by category
  if (selectedCategory != 'All') {
    products = products.where((p) => 
      p['category'] == selectedCategory
    ).toList();
  }
  
  // Sort by price
  if (sortBy == 'Price: Low to High') {
    products.sort((a, b) => 
      _getPrice(a).compareTo(_getPrice(b))
    );
  }
  
  return products;
}
```

---

## 🎯 Future Enhancements

Potential features to add:
- User authentication (login/signup)
- Payment integration
- Order history
- Product reviews
- Push notifications
- Dark mode
- Multiple languages
- Delivery tracking

---

## 📚 Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Dart Language**: https://dart.dev/guides
- **Material Design**: https://material.io/design

---

## ✅ Checklist for Presentation

- [ ] App runs without errors
- [ ] All images load properly
- [ ] Internet permission enabled
- [ ] Understand main features
- [ ] Can explain code structure
- [ ] Know how to navigate the app
- [ ] Prepared demo flow
- [ ] Can answer questions about:
  - Why Flutter?
  - How state management works?
  - How data flows through the app?
  - What makes the app user-friendly?

---

**Good luck with your presentation! 🚀**

Remember: Focus on demonstrating the features and explaining how they benefit users. The technical details are secondary to showing a working, useful application.
