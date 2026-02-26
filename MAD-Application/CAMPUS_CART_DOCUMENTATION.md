# Campus Cart - Complete Application Documentation

## Table of Contents
1. [Overview](#overview)
2. [User Roles & Authentication](#user-roles--authentication)
3. [Customer Features](#customer-features)
4. [Seller Features](#seller-features)
5. [Staff Features](#staff-features)
6. [Admin Features](#admin-features)
7. [Technical Architecture](#technical-architecture)
8. [Navigation Flow](#navigation-flow)
9. [Key Components](#key-components)

---

## Overview

Campus Cart is a comprehensive e-commerce mobile application built with Flutter, designed specifically for campus communities. It provides a multi-role platform where customers can shop, sellers can manage their stores, staff can handle operations, and admins can oversee the entire platform.

### Key Features
- Multi-role authentication system
- Real-time shopping experience
- Order management and tracking
- Live chat support
- Content moderation
- Route planning for deliveries
- Comprehensive analytics dashboards

---

## User Roles & Authentication

### Available Roles

1. **Customer** (Default)
   - Browse and purchase products
   - Manage cart and wishlist
   - Track orders
   - Access customer support

2. **Seller**
   - Manage product inventory
   - Process orders
   - Track sales and earnings
   - Manage store settings

3. **Staff** (3 Sub-types)
   - **Order Coordinator**: Process orders, assign deliveries, manage order flow
   - **Customer Support**: Handle tickets, live chat, moderation
   - **Delivery Personnel**: Manage pickups and deliveries with route planning

4. **Admin**
   - Platform-wide management
   - Seller approval and management
   - System analytics
   - Content oversight

### Test Credentials

```dart
// Customer
Email: customer@test.com
Password: customer123

// Seller
Email: seller@test.com
Password: seller123

// Order Coordinator Staff
Email: coordinator@test.com
Password: coordinator123

// Customer Support Staff
Email: support@test.com
Password: support123

// Delivery Personnel
Email: delivery@test.com
Password: delivery123

// Admin
Email: admin@test.com
Password: admin123
```

### Authentication Flow

1. User opens app → **Splash Screen** (2 seconds)
2. Redirects to **Sign In Screen**
3. User enters credentials
4. System validates and determines role
5. Redirects to appropriate dashboard based on role

---

## Customer Features

### 1. Home Screen
**Purpose**: Main shopping interface for browsing and discovering products

**Features**:
- Search bar with real-time filtering
- Category quick access buttons
- Featured products grid
- Product cards with:
  - Product image
  - Name and rating
  - Price with discount badge
  - Add to cart button
  - Wishlist toggle
- Filter by category
- Responsive grid layout

**Navigation**:
- Tap product → Product Details Screen
- Tap category → Categories Screen
- Tap cart icon → Cart Screen
- Bottom navigation to other sections

### 2. Product Details Screen
**Purpose**: Detailed view of individual products

**Features**:
- Full product image gallery
- Product name and description
- Price and discount information
- Star rating and reviews
- Size/color selection (if applicable)
- Quantity selector
- Add to Cart button
- Add to Wishlist button
- Seller information
- Related products section

### 3. Categories Screen
**Purpose**: Browse products by category

**Features**:
- Grid/List view toggle
- Category cards with:
  - Category image
  - Category name
  - Product count
  - Category icon
- Search functionality
- Filter by category
- Tap to view category products

### 4. Cart Screen
**Purpose**: Review and manage items before checkout

**Features**:
- Cart items list with:
  - Product image
  - Name and category
  - Price
  - Quantity controls (+/-)
  - Remove button
- Order summary:
  - Subtotal
  - Delivery fee
  - Total amount
- Delivery method selection
- Shipping address input
- Payment method selection
- Proceed to Checkout button
- Empty cart state

### 5. Wishlist Screen
**Purpose**: Save products for later purchase

**Features**:
- Saved products grid
- Quick add to cart
- Remove from wishlist
- Product details access
- Empty wishlist state

### 6. My Orders Screen
**Purpose**: Track order history and status

**Features**:
- Order list with:
  - Order ID
  - Order date
  - Status badge
  - Total amount
  - Items count
- Order status tracking:
  - Pending
  - Processing
  - Shipped
  - Delivered
  - Cancelled
- Order details view
- Reorder functionality

### 7. Profile Screen
**Purpose**: Manage account and settings

**Features**:
- User information display
- Edit profile
- Order history access
- Wishlist access
- Settings:
  - Notifications
  - Privacy & Security
  - Help & Support
  - Language preferences
- Logout option

---

## Seller Features

### 1. Seller Dashboard
**Purpose**: Overview of seller's store performance

**Features**:
- Welcome banner
- Summary cards:
  - Total Sales (UGX 2.5M)
  - Orders (156)
  - Products (24)
  - Rating (4.8)
- Quick actions:
  - My Products
  - Orders
  - Add Product
  - Earnings
- Responsive card layout with overflow protection

**Navigation**:
- `/seller/dashboard`

### 2. My Products Screen
**Purpose**: Manage product inventory

**Features**:
- Product list with:
  - Product image
  - Name and category
  - Price
  - Stock status
  - Edit/Delete actions
- Add new product button
- Search and filter
- Stock management

**Navigation**:
- `/seller/products`

### 3. Add Product Screen
**Purpose**: Create new product listings

**Features**:
- Product information form:
  - Product name
  - Description
  - Category selection
  - Price
  - Discount
  - Stock quantity
  - Images upload
- Validation
- Save button

**Navigation**:
- `/seller/add-product`

### 4. Edit Product Screen
**Purpose**: Update existing product information

**Features**:
- Pre-filled product form
- Update all product details
- Delete product option
- Save changes

**Navigation**:
- `/seller/edit-product` (with product argument)

### 5. Seller Orders Screen
**Purpose**: Manage incoming orders

**Features**:
- Order cards with:
  - Order ID with urgent badge
  - Customer name and avatar
  - Delivery address
  - Total amount
  - Status badge
  - Items count and date
  - View details button
- Status filters:
  - All
  - Pending
  - Processing
  - Shipped
  - Delivered
  - Cancelled
- Search by order ID or customer
- Order details modal
- Responsive layout with overflow fixes

**Navigation**:
- `/seller/orders`

### 6. Order Details Screen
**Purpose**: View and manage specific order

**Features**:
- Order information
- Customer details
- Product list
- Status update actions
- Tracking number management

**Navigation**:
- `/seller/order-details` (with order argument)

### 7. Earnings Screen
**Purpose**: Track sales and revenue

**Features**:
- Total earnings display
- Sales breakdown
- Transaction history
- Withdrawal options
- Analytics charts

**Navigation**:
- `/seller/earnings`

### 8. Store Settings Screen
**Purpose**: Configure store preferences

**Features**:
- Store information
- Business hours
- Shipping settings
- Payment methods
- Store policies

**Navigation**:
- `/seller/settings`

---

## Staff Features

### Staff Dashboard Types

The staff dashboard adapts based on staff type (coordinator, support, or delivery).

### 1. Order Coordinator Dashboard
**Purpose**: Coordinate order processing and delivery assignments

**Summary Cards**:
- Pending Orders (12)
- Processing (8)
- Ready for Delivery (5)
- Assigned to Delivery (15)

**Quick Actions**:
- Process Orders
- Assign Delivery
- View Analytics
- Manage Sellers

**Navigation**:
- `/staff/dashboard` (with staffType: 'coordinator' or null)

**Responsibilities**:
- View accepted orders from sellers
- Assign accepted orders to available delivery personnel
- Monitor delivery assignments and order status
- Coordinate between sellers and delivery personnel

### 2. Customer Support Dashboard
**Purpose**: Handle customer inquiries and issues

**Summary Cards**:
- Open Tickets (8)
- In Progress (5)
- Resolved (12)
- Avg Response (5 min)

**Quick Actions**:
- Support Tickets
- Live Chat
- Moderation
- Help Center

**Navigation**:
- `/staff/dashboard` (with staffType: 'support')

### 2. Support Tickets Screen
**Purpose**: Manage customer support tickets

**Features**:
- Ticket cards with:
  - Ticket ID
  - Category icon and badge
  - Priority badge (High/Medium/Low)
  - Status badge (Open/In Progress/Resolved)
  - Subject
  - Customer name and date
  - Last message preview
  - Action buttons (Take Ticket/Mark Resolved/View Details)
- Filter by status:
  - All
  - Open
  - In Progress
  - Resolved
- Ticket details modal with:
  - Full conversation thread
  - Reply functionality
  - Status updates
- Overflow-proof responsive layout

**Navigation**:
- `/staff/tickets`

### 3. Live Chat Screen
**Purpose**: Real-time customer support chat

**Features**:
- Active chats list with:
  - Customer avatar with online status
  - Customer name
  - Last message preview
  - Timestamp
  - Unread message badge
- Stats cards:
  - Active Chats count
  - Waiting count
- Chat interface modal with:
  - Customer info header
  - Message area
  - Message input with send button
- Real-time status indicators

**Navigation**:
- `/staff/chat`

### 4. Moderation Screen
**Purpose**: Review and moderate flagged content

**Features**:
- Pending items banner showing count
- Flagged item cards with:
  - Item ID and type badge (Product/Review/Comment)
  - Status badge (Pending/Reviewed)
  - Item image (if applicable)
  - Title
  - Reason for flagging
  - Description
  - Reporter information
  - Date
  - Approve/Remove actions
- Filter by type:
  - All
  - Products
  - Reviews
  - Comments
- Responsive layout with proper overflow handling

**Navigation**:
- `/staff/moderation`

### 5. Help Center Screen
**Purpose**: Knowledge base for support staff

**Features**:
- Search bar for articles
- Category filters:
  - All
  - Orders
  - Products
  - Payments
  - Shipping
  - Returns
- Article cards with:
  - Category icon and badge
  - Article title
  - View count
  - Helpful rating count
- Article viewer modal with:
  - Full article content
  - Feedback buttons (Was this helpful?)
- Color-coded categories

**Navigation**:
- `/staff/help-center`

### 7. Delivery Personnel Dashboard
**Purpose**: Manage pickups and deliveries

**Summary Cards**:
- Pending Pickups (6)
- In Transit (4)
- Delivered (15)
- Distance Today (45 km)

**Quick Actions**:
- Deliveries
- Active Orders
- History
- Route Planner

**Navigation**:
- `/staff/dashboard` (with staffType: 'delivery')

**Responsibilities**:
- Pick up orders from seller stores
- Deliver orders to customer locations
- Update delivery status in real-time
- Follow optimized routes
- Confirm pickups and deliveries

### 8. Route Planner Screen
**Purpose**: Optimize delivery routes with pickup and delivery stops

**Features**:
- Route summary with:
  - Pending deliveries count
  - Completed deliveries count
  - Total distance
  - Total estimated time
  - Optimize Route button
- Delivery stop cards with:
  - Stop type badge (PICKUP from seller / DELIVERY to customer)
  - Priority number badge
  - Order ID and location name
  - Address
  - Phone number
  - Distance and estimated time
  - Items count
  - Navigate button
  - Confirm Pickup / Complete Delivery button
- Completed stops marked with checkmark
- Visual priority ordering
- Two stops per order: pickup from seller, then delivery to customer

**Navigation**:
- `/staff/route-planner`

### 9. Orders to Process Screen
**Purpose**: Process and fulfill orders (Order Coordinator)

**Features**:
- Order cards with:
  - Order ID
  - Priority badge (High/Medium/Low)
  - Status badge
  - Customer name
  - Items count and date
  - Total amount
  - Action buttons based on status:
    - Pending → Start Processing
    - Processing → Mark Ready
    - Ready to Ship → Add Tracking
  - View button
- Filter by status:
  - All
  - Pending
  - Processing
  - Ready to Ship
- Order details modal with:
  - Full order information
  - Customer details
  - Delivery address
  - Order items placeholder
- Add tracking number dialog

**Navigation**:
- `/staff/orders`

### 10. Active Deliveries Screen
**Purpose**: Track ongoing deliveries (Delivery Personnel)

**Features**:
- Active delivery list
- Real-time status updates
- Delivery tracking

**Navigation**:
- `/staff/active-deliveries`

### 11. Delivery History Screen
**Purpose**: View completed deliveries (Delivery Personnel)

**Features**:
- Completed deliveries list
- Delivery details
- Performance metrics

**Navigation**:
- `/staff/delivery-history`

---

## Order Flow

### Complete Order Lifecycle

1. **Customer Places Order**
   - Customer adds items to cart
   - Proceeds to checkout
   - Confirms order and payment
   - Order status: "Pending"

2. **Seller Accepts Order**
   - Seller receives order notification
   - Reviews order details
   - Accepts order and prepares items at their store
   - Order status: "Accepted"

3. **Order Coordinator Assigns Delivery**
   - Views accepted orders in "Orders to Process" screen
   - Assigns order to available delivery personnel
   - Order appears in delivery personnel's route
   - Order status: "Assigned to Delivery"

4. **Delivery Personnel Picks Up Product**
   - Views assigned orders in Route Planner
   - Navigates to seller's store (PICKUP stop)
   - Collects product from seller
   - Confirms pickup in app
   - Order status: "Picked Up" / "In Transit"

5. **Delivery Personnel Delivers Product**
   - Navigates to customer location (DELIVERY stop)
   - Delivers product to customer
   - Confirms delivery in app
   - Order status: "Delivered"

6. **Order Complete**
   - Customer receives order
   - Can rate and review
   - Seller receives payment
   - Order archived in history

### Key Points
- Seller accepts and prepares order before coordinator assigns delivery
- Each order has TWO stops: PICKUP (from seller) → DELIVERY (to customer)
- Delivery personnel do NOT pick up from a central warehouse
- Sellers maintain their own inventory at their stores
- Order Coordinator only assigns orders after seller has accepted them

---

## Admin Features

### 1. Admin Dashboard
**Purpose**: Platform-wide overview and management

**Features**:
- Welcome banner
- Platform statistics cards:
  - Total Sales (UGX 15.2M)
  - Total Orders (1,247)
  - Active Sellers (89)
  - Total Customers (2,156)
- Alerts & Notifications:
  - Pending Seller Approvals (3)
  - Flagged Products (2)
  - System Updates
- Quick actions:
  - Manage Sellers
  - Manage Products
  - View Reports
  - System Settings
- Responsive layout with overflow protection

**Navigation**:
- `/admin/dashboard`

### 2. Manage Sellers Screen
**Purpose**: Approve and manage seller accounts

**Features**:
- Seller list
- Approval workflow
- Seller performance metrics
- Suspend/activate sellers

**Navigation**:
- `/admin/sellers`

---

## Technical Architecture

### Project Structure

```
lib/
├── main.dart                 # App entry point
├── constants/
│   └── app_colors.dart      # Color scheme
├── services/
│   ├── user_manager.dart    # User state management
│   ├── cart_manager.dart    # Cart functionality
│   └── wishlist_manager.dart # Wishlist functionality
├── widgets/
│   └── notification_icon.dart # Reusable notification icon
└── pages/
    ├── SplashScreen.dart
    ├── SignInScreen.dart
    ├── SignUpScreen.dart
    ├── ForgotPasswordScreen.dart
    ├── OtpVerificationScreen.dart
    ├── ResetPasswordScreen.dart
    ├── HomeScreen.dart
    ├── ProductDetails.dart
    ├── CategoriesScreen.dart
    ├── CartScreen.dart
    ├── WishlistScreen.dart
    ├── ProfileScreen.dart
    ├── MyOrdersScreen.dart
    ├── OrderSuccess.dart
    ├── NotificationsListScreen.dart
    ├── HelpSupportScreen.dart
    ├── PrivacySecurityScreen.dart
    ├── access_denied_screen.dart
    ├── seller/
    │   ├── seller_dashboard_screen.dart
    │   ├── my_products_screen.dart
    │   ├── add_product_screen.dart
    │   ├── edit_product_screen.dart
    │   ├── seller_orders_screen.dart
    │   ├── order_details_screen.dart
    │   ├── earnings_screen.dart
    │   └── store_settings_screen.dart
    ├── staff/
    │   ├── staff_dashboard_screen.dart
    │   ├── orders_to_process_screen.dart
    │   ├── support_tickets_screen.dart
    │   ├── live_chat_screen.dart
    │   ├── moderation_screen.dart
    │   ├── help_center_screen.dart
    │   ├── route_planner_screen.dart
    │   ├── active_deliveries_screen.dart
    │   └── delivery_history_screen.dart
    └── admin/
        ├── admin_dashboard_screen.dart
        └── manage_sellers_screen.dart
```

### State Management

**UserManager Service**:
- Manages user authentication state
- Stores user role and staff type
- Provides role-based access control
- Singleton pattern for global access

**CartManager Service**:
- Manages shopping cart items
- Add/remove/update cart items
- Calculate totals
- Persist cart state

**WishlistManager Service**:
- Manages wishlist items
- Add/remove items
- Check if item is in wishlist
- Persist wishlist state

### Color Scheme (AppColors)

```dart
class AppColors {
  static const Color primary = Color(0xFF1A73E8);      // Blue
  static const Color secondary = Color(0xFF34A853);    // Green
  static const Color accent = Color(0xFFFBBC04);       // Yellow
  static const Color error = Color(0xFFEA4335);        // Red
  static const Color success = Color(0xFF34A853);      // Green
  static const Color background = Color(0xFFF5F5F5);   // Light Gray
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color text = Color(0xFF212121);
  static const Color secondaryText = Color(0xFF616161);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color cards = Color(0xFFFFFFFF);
  static const Color buttons = Color(0xFF1A73E8);
}
```

### Responsive Design Patterns

**Overflow Prevention**:
1. Use `Flexible` widgets for dynamic sizing
2. Implement `FittedBox` with `BoxFit.scaleDown`
3. Add `mainAxisSize: MainAxisSize.min` to columns
4. Set `maxLines` and `overflow: TextOverflow.ellipsis`
5. Reduce padding and font sizes for tight spaces
6. Use `Wrap` instead of `Row` for wrapping content

**Example Pattern**:
```dart
Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Long text that might overflow',
          style: TextStyle(fontSize: 20),
        ),
      ),
    ),
    Flexible(
      child: Text(
        'Another text',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

---

## Navigation Flow

### Route Structure

```dart
routes: {
  '/splash': SplashScreen(),
  '/': SignInScreen(),
  '/signup': SignUpScreen(),
  '/signin': SignInScreen(),
  '/forgot-password': ForgotPasswordScreen(),
  '/otp-verification': OtpVerificationScreen(),
  '/reset-password': ResetPasswordScreen(),
  '/home': HomeScreen(),
  '/cart': CartScreen(),
  '/categories': CategoriesScreen(),
  '/wishlist': WishlistScreen(),
  '/profile': ProfileScreen(),
  '/my-orders': MyOrdersScreen(),
  '/access-denied': AccessDeniedScreen(),
  
  // Seller routes
  '/seller/dashboard': SellerDashboardScreen(),
  '/seller/products': MyProductsScreen(),
  '/seller/add-product': AddProductScreen(),
  '/seller/orders': SellerOrdersScreen(),
  '/seller/earnings': EarningsScreen(),
  '/seller/settings': StoreSettingsScreen(),
  
  // Staff routes
  '/staff/dashboard': StaffDashboardScreen(),
  '/staff/orders': OrdersToProcessScreen(),
  '/staff/tickets': SupportTicketsScreen(),
  '/staff/chat': LiveChatScreen(),
  '/staff/moderation': ModerationScreen(),
  '/staff/help-center': HelpCenterScreen(),
  '/staff/route-planner': RoutePlannerScreen(),
  '/staff/active-deliveries': ActiveDeliveriesScreen(),
  '/staff/delivery-history': DeliveryHistoryScreen(),
  
  // Admin routes
  '/admin/dashboard': AdminDashboardScreen(),
  '/admin/sellers': ManageSellersScreen(),
}
```

### Dynamic Routes (with arguments)

```dart
onGenerateRoute: (settings) {
  // Product details
  if (settings.name == '/product-details') {
    final product = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => ProductDetailScreen(product: product),
    );
  }
  
  // Edit product
  if (settings.name == '/seller/edit-product') {
    final product = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => EditProductScreen(product: product),
    );
  }
  
  // Order details
  if (settings.name == '/seller/order-details') {
    final order = settings.arguments as Map<String, dynamic>;
    return MaterialPageRoute(
      builder: (context) => OrderDetailsScreen(order: order),
    );
  }
}
```

### Role-Based Access Control

```dart
// Check user role before allowing access
if (settings.name?.startsWith('/seller/') == true && userRole != 'seller') {
  return MaterialPageRoute(
    builder: (context) => AccessDeniedScreen()
  );
}

if (settings.name?.startsWith('/staff/') == true && userRole != 'staff') {
  return MaterialPageRoute(
    builder: (context) => AccessDeniedScreen()
  );
}

if (settings.name?.startsWith('/admin/') == true && userRole != 'admin') {
  return MaterialPageRoute(
    builder: (context) => AccessDeniedScreen()
  );
}
```

---

## Key Components

### 1. NotificationIcon Widget
**Purpose**: Reusable notification bell icon with badge

**Features**:
- Notification count badge
- Tap to view notifications
- Used across all app bars

**Usage**:
```dart
AppBar(
  actions: [NotificationIcon()],
)
```

### 2. Product Card
**Purpose**: Display product in grid/list

**Features**:
- Product image with loading/error states
- Discount badge
- Wishlist toggle
- Rating display
- Add to cart button
- Tap to view details

### 3. Order Card
**Purpose**: Display order information

**Features**:
- Order ID and status
- Customer information
- Items count and total
- Action buttons based on status
- Responsive layout

### 4. Summary Card (Dashboard)
**Purpose**: Display key metrics

**Features**:
- Icon with colored background
- Value (large text)
- Label (small text)
- Responsive sizing with overflow protection

### 5. Modal Bottom Sheets
**Purpose**: Display detailed information

**Features**:
- Drag handle
- Header with close button
- Scrollable content
- Action buttons
- Used for:
  - Order details
  - Product details
  - Chat interface
  - Article viewer

---

## Development Guidelines

### Adding New Features

1. **Create Screen File**:
   - Place in appropriate folder (pages/customer, pages/seller, etc.)
   - Follow naming convention: `feature_name_screen.dart`

2. **Add Route**:
   - Add to `routes` in `main.dart`
   - Add role-based protection if needed

3. **Implement Responsive Design**:
   - Use `Flexible` and `FittedBox` for text
   - Add `maxLines` and `overflow` handling
   - Test on different screen sizes

4. **Follow Color Scheme**:
   - Use `AppColors` constants
   - Maintain consistent styling

5. **Add Navigation**:
   - Use `Navigator.pushNamed()` for routes
   - Pass arguments when needed

### Testing Checklist

- [ ] Test all user roles
- [ ] Verify navigation flows
- [ ] Check responsive layout on different screen sizes
- [ ] Test overflow scenarios with long text
- [ ] Verify role-based access control
- [ ] Test all CRUD operations
- [ ] Check error handling
- [ ] Verify data persistence

### Common Issues & Solutions

**Issue**: RenderFlex overflow
**Solution**: Use `Flexible`, `FittedBox`, reduce padding/font sizes

**Issue**: Navigation not working
**Solution**: Check route name spelling, verify arguments are passed correctly

**Issue**: Access denied for valid role
**Solution**: Check `UserManager` role assignment, verify route protection logic

**Issue**: State not updating
**Solution**: Ensure `setState()` is called, check service singleton implementation

---

## Future Enhancements

### Planned Features
1. Real-time notifications using Firebase
2. Payment gateway integration
3. Advanced analytics and reporting
4. Multi-language support
5. Dark mode theme
6. Push notifications
7. In-app messaging system
8. Product reviews and ratings
9. Advanced search with filters
10. Seller verification system

### Technical Improvements
1. State management with Provider/Riverpod
2. API integration for backend
3. Local database with SQLite
4. Image caching and optimization
5. Offline mode support
6. Unit and integration tests
7. CI/CD pipeline
8. Performance monitoring

---

## Conclusion

Campus Cart is a feature-rich, multi-role e-commerce platform designed for campus communities. With comprehensive dashboards for customers, sellers, staff, and admins, it provides a complete ecosystem for online shopping and store management.

The application follows Flutter best practices with:
- Clean architecture
- Responsive design
- Role-based access control
- Reusable components
- Consistent styling
- Proper error handling

All screens are fully functional, overflow-proof, and optimized for various screen sizes, providing a seamless user experience across all roles.

---

**Last Updated**: February 2026
**Version**: 1.0.0
**Flutter Version**: 3.35.2
**Dart Version**: 3.9.0