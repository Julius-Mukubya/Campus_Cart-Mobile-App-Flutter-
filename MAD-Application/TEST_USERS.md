# Test Users for Role-Based Authentication

Use these credentials to test different user roles in the app:

## 🔐 Test User Credentials

### 👤 **Customer User**
- **Email**: `customer@test.com`
- **Password**: `customer123`
- **Role**: Customer
- **Name**: Sarah Customer
- **Features**: Standard shopping features only (no Business/Management section)

### 🏪 **Seller User**
- **Email**: `seller@test.com`
- **Password**: `seller123`
- **Role**: Seller
- **Name**: John Seller
- **Features**: 
  - Seller Dashboard
  - My Products
  - Add Product
  - Seller Orders
  - Earnings / Payouts
  - Store Settings

### 🎧 **Customer Support Staff**
- **Email**: `support@test.com`
- **Password**: `support123`
- **Role**: Staff (Customer Support)
- **Name**: Jane Support
- **Features**:
  - Staff Dashboard
  - Support Tickets (handle customer inquiries)
  - Live Chat (real-time customer support)
  - Moderation Queue (review flagged content)

### 🚚 **Delivery Personnel**
- **Email**: `delivery@test.com`
- **Password**: `delivery123`
- **Role**: Staff (Delivery)
- **Name**: Tom Delivery
- **Features**:
  - Staff Dashboard
  - Orders to Deliver (pick up & deliver)
  - Active Deliveries (track ongoing)
  - Delivery History (completed deliveries)

### 👑 **Admin User**
- **Email**: `admin@test.com`
- **Password**: `admin123`
- **Role**: Admin
- **Name**: Mike Admin
- **Features**:
  - Admin Dashboard
  - Manage Sellers
  - Manage Categories
  - Manage Products
  - Manage Orders
  - Payments / Refunds
  - Reports
  - System Settings

## 🧪 How to Test

1. **Open the app** and go to the Sign In screen
2. **Enter credentials** from any of the test users above
3. **Tap "Log In"** - you'll see a success message with the user's role
4. **Navigate to Profile** to see the role-specific "Business / Management" section
5. **Try different roles** to see different menu options and screens
6. **Test access control** by trying to access unauthorized features

## 📱 What You'll See

### Sign In Screen
- Test user credentials are displayed at the bottom for easy reference
- Color-coded role badges for quick identification
- Loading indicator during authentication
- Success/error messages with role information

### Profile Screen
- **Customer**: Only sees Account and Settings sections
- **Seller**: Additional "Business / Management" section with seller-specific menu items
- **Customer Support Staff**: Dashboard, Support Tickets, Live Chat, Moderation Queue
- **Delivery Personnel**: Dashboard, Orders to Deliver, Active Deliveries, Delivery History
- **Admin**: Full administrative menu with all management features

### Navigation
- Role-based menu items in the Business/Management section
- Access denied screen for unauthorized routes
- Proper user information display throughout the app

## 🔄 Switching Users

To test different roles:
1. **Logout** from current user (Profile → Logout)
2. **Sign in** with different test user credentials
3. **Navigate to Profile** to see the new role's features

## 🛡️ Security Features

- **Authentication**: Email/password validation
- **Role-based access**: Different features per role
- **Route protection**: Unauthorized access blocked
- **User session**: Proper login/logout flow
- **Data persistence**: User info maintained during session

The authentication system is fully functional and ready for testing!