# Campus Cart - Complete Screens & Features Documentation

## Table of Contents
1. [Authentication Screens](#authentication-screens)
2. [Customer Screens](#customer-screens)
3. [Seller Screens](#seller-screens)
4. [Staff Screens](#staff-screens)
5. [Admin Screens](#admin-screens)
6. [Feature Summary](#feature-summary)

---

## Authentication Screens

### 1. Splash Screen
**Purpose**: App loading and branding
**Features**:
- Campus Cart logo
- Loading animation
- 2-second display
- Auto-redirect to Sign In

**Navigation**: App entry point

---

### 2. Sign In Screen
**Purpose**: User authentication
**Features**:
- Email and password input fields
- Password visibility toggle
- "Forgot Password" link
- "Log In" button with loading state
- "Sign in with Google" button
- "Sign up here" link
- Test users display box showing:
  - Email addresses
  - Passwords
  - User roles (seller, coordinator, support, delivery, admin, customer)
- Form validation
- Error messages

**Navigation**: `/signin`

---

### 3. Sign Up Screen
**Purpose**: New user registration
**Features**:
- Name, email, phone, password fields
- Role selection (Customer/Seller)
- Terms and conditions checkbox
- Sign up button
- Redirect to sign in

**Navigation**: `/signup`

---

### 4. Forgot Password Screen
**Purpose**: Password recovery
**Features**:
- Email input
- Send reset link button
- Back to sign in link

**Navigation**: `/forgot-password`

---

## Customer Screens

### 1. Customer Home Screen
**Purpose**: Main shopping interface
**Features**:
- Search bar with real-time filtering
- Category quick access buttons (Electronics, Fashion, Books, Food, etc.)
- Featured products grid with:
  - Product images
  - Product name
  - Price
  - Rating stars
  - Add to cart button
  - Wishlist toggle
- Bottom navigation bar (Home, Categories, Cart, Wishlist, Profile)
- Responsive grid layout

**Navigation**: `/home`

---

### 2. Product Details Screen
**Purpose**: View detailed product information
**Features**:
- Product image gallery/carousel
- Product name and description
- Price with discount badge
- Star rating and review count
- Seller information and rating
- Stock availability indicator
- Size/color selection (if applicable)
- Quantity selector (+/-)
- Add to Cart button
- Add to Wishlist button
- Related products section
- Customer reviews section

**Navigation**: Tap product from home/categories

---

### 3. Cart Screen
**Purpose**: Review and manage cart items
**Features**:
- List of cart items with:
  - Product image
  - Name and variant
  - Price
  - Quantity adjustment (+/-)
  - Remove button
- Subtotal calculation
- Delivery fee
- Total amount
- Proceed to Checkout button
- Empty cart state with "Continue Shopping" button
- Apply coupon code field

**Navigation**: Cart icon in bottom navigation

---

### 4. Wishlist Screen
**Purpose**: Save products for later
**Features**:
- Grid of wishlist items
- Product cards with:
  - Product image
  - Name and price
  - Remove from wishlist button
  - Move to cart button
- Empty wishlist state
- Filter and sort options

**Navigation**: Wishlist icon in bottom navigation

---

### 5. Checkout Screen
**Purpose**: Complete purchase
**Features**:
- Delivery address form:
  - Street address
  - City, postal code
  - Phone number
  - Save address checkbox
- Payment method selection:
  - Mobile Money
  - Credit/Debit Card
  - Cash on Delivery
- Order summary:
  - Items list
  - Subtotal
  - Delivery fee
  - Total
- Place Order button
- Order confirmation dialog

**Navigation**: From cart screen

---

### 6. Order Tracking Screen
**Purpose**: Track order status in real-time
**Features**:
- Order status timeline:
  - Order Placed ✓
  - Seller Accepted ✓
  - Assigned to Delivery
  - Picked Up
  - Out for Delivery
  - Delivered
- Current status highlighted
- Estimated delivery time
- Order details:
  - Order ID
  - Items list
  - Total amount
- Delivery personnel info (when assigned):
  - Name
  - Phone number
  - Photo
- Contact delivery button
- Confirm delivery receipt button (dual confirmation)
- Track on map button

**Navigation**: From customer orders

---

### 7. Customer Profile Screen
**Purpose**: Manage account information
**Features**:
- Profile picture with edit option
- User information:
  - Name
  - Email
  - Phone number
- Edit Profile button
- Menu options:
  - My Orders
  - Saved Addresses
  - Payment Methods
  - Notifications Settings
  - Help & Support
  - About
  - Logout
- Order statistics

**Navigation**: Profile icon in bottom navigation

---

### 8. Customer Orders History
**Purpose**: View past and current orders
**Features**:
- Order cards with:
  - Order ID
  - Date
  - Status badge
  - Items count
  - Total amount
  - View Details button
- Filter by status: All, Pending, Delivered, Cancelled
- Search orders
- Reorder button
- Rate order button (for delivered orders)

**Navigation**: From profile screen

---

### 9. Customer Support Screen
**Purpose**: Get help and support
**Features**:
- FAQ section
- Contact support button
- Live chat option
- Submit ticket form
- Help articles
- Call support button

**Navigation**: From profile menu

---

### 10. Settings Screen
**Purpose**: App preferences
**Features**:
- Notification preferences
- Language selection
- Theme (Light/Dark)
- Privacy settings
- Terms and conditions
- Privacy policy

**Navigation**: From profile menu

---

## Seller Screens

### 1. Seller Dashboard
**Purpose**: Overview of seller business
**Features**:
- Welcome banner with seller name
- Summary cards (responsive, overflow-protected):
  - Total Sales (UGX 2.5M) - Green icon
  - Active Orders (12) - Orange icon
  - Products (45) - Blue icon
  - Customers (128) - Purple icon
- Quick actions grid:
  - My Orders
  - My Products
  - Add Product
  - Analytics
- Recent orders preview
- Low stock alerts
- Notification icon in app bar

**Navigation**: `/seller/dashboard`

**Responsive Features**:
- Reduced padding (14px → 12px)
- Smaller icons (20px → 18px for cards, 22px → 20px for actions)
- Smaller fonts (22px → 20px for values, 13px → 11px for titles)
- FittedBox for text scaling
- Spacer for flexible spacing

---

### 2. Seller Orders Screen (My Orders)
**Purpose**: Manage incoming orders
**Features**:
- Filter tabs: All, Pending, Accepted, Ready, Completed
- Order cards with:
  - Order ID with urgent badge (if applicable)
  - Customer name and address
  - Order status badge (color-coded)
  - Items count and date (below status)
  - Total amount
  - Customer phone number
- Action buttons based on status:
  - Pending → Accept / Reject
  - Accepted → Mark as Ready
  - Ready → Confirm Handover (to delivery personnel)
- View order details button
- Order details modal with:
  - Full order information
  - Customer details
  - Delivery address
  - Items list with quantities
- Dual confirmation for handover:
  - Seller confirms handover
  - Delivery personnel confirms pickup
- Responsive layout with overflow protection

**Navigation**: `/seller/orders`

---

### 3. Seller Products Screen (My Products)
**Purpose**: Manage product inventory
**Features**:
- Product list/grid view toggle
- Product cards with:
  - Product image
  - Name and category
  - Price
  - Stock quantity
  - Status (Active/Inactive)
  - Edit button
  - Delete button
- Add new product FAB (Floating Action Button)
- Search products by name
- Filter by:
  - Category
  - Stock status (In Stock, Low Stock, Out of Stock)
  - Status (Active/Inactive)
- Sort by:
  - Name
  - Price
  - Stock
  - Date added
- Bulk actions (select multiple)

**Navigation**: `/seller/products`

---

### 4. Add/Edit Product Screen
**Purpose**: Create or modify products
**Features**:
- Product image upload (multiple images)
- Product information form:
  - Product name
  - Description
  - Category selection
  - Price
  - Discount percentage
  - Stock quantity
  - SKU
  - Variants (size, color)
- Save as draft option
- Publish button
- Form validation
- Image preview and reorder

**Navigation**: From products screen

---

### 5. Seller Analytics Screen
**Purpose**: View business performance
**Features**:
- Date range selector
- Revenue chart (line/bar graph)
- Top selling products
- Sales by category (pie chart)
- Customer demographics
- Order statistics:
  - Total orders
  - Average order value
  - Conversion rate
- Export data button

**Navigation**: From dashboard

---

### 6. Seller Profile Screen
**Purpose**: Manage seller account
**Features**:
- Store logo upload
- Store information:
  - Store name
  - Description
  - Category
  - Location
  - Phone number
  - Email
- Business hours
- Store rating and reviews
- Edit store info button
- Bank account details (for payments)

**Navigation**: From seller menu

---

### 7. Seller Settings Screen
**Purpose**: Configure seller preferences
**Features**:
- Notification settings
- Order auto-accept toggle
- Store visibility toggle
- Payment preferences
- Shipping settings
- Tax settings

**Navigation**: From seller menu

---

### 8. Seller Earnings Screen
**Purpose**: Track earnings and payouts
**Features**:
- Total earnings
- Pending payouts
- Completed payouts
- Transaction history
- Payout request button
- Earnings breakdown by period
- Download statements

**Navigation**: From seller menu

---

## Staff Screens

### 1. Order Coordinator Dashboard
**Purpose**: Coordinate order processing and delivery assignments
**Features**:
- Welcome banner: "Coordinate orders and deliveries"
- Dashboard icon: Assignment turned in
- Summary cards (responsive):
  - Pending Orders (12) - Orange
  - Processing (8) - Blue
  - Ready for Delivery (5) - Green
  - Assigned to Delivery (15) - Blue
- Quick actions grid:
  - Process Orders → `/staff/orders`
  - Assign Delivery → `/staff/orders`
  - View Analytics (placeholder)
  - Manage Sellers (placeholder)
- Notification icon

**Navigation**: `/staff/dashboard` (staffType: 'coordinator' or null)

**Responsibilities**:
- View accepted orders from sellers
- Assign accepted orders to available delivery personnel
- Monitor delivery assignments
- Coordinate between sellers and delivery personnel

---

### 2. Customer Support Dashboard
**Purpose**: Handle customer inquiries and issues
**Features**:
- Welcome banner: "Help customers and resolve issues"
- Dashboard icon: Headset mic
- Summary cards:
  - Open Tickets (8) - Orange
  - In Progress (5) - Orange
  - Resolved (12) - Green
  - Avg Response Time (5 min) - Blue
- Quick actions grid:
  - Support Tickets → `/staff/tickets`
  - Live Chat → `/staff/chat`
  - Moderation → `/staff/moderation`
  - Help Center → `/staff/help-center`

**Navigation**: `/staff/dashboard` (staffType: 'support')

---

### 3. Delivery Personnel Dashboard
**Purpose**: Manage pickups and deliveries
**Features**:
- Welcome banner: "Manage pickups and deliveries"
- Dashboard icon: Local shipping
- Summary cards:
  - Pending Pickups (6) - Orange
  - In Transit (4) - Blue
  - Delivered Today (15) - Green
  - Distance Today (45 km) - Blue
- Quick actions grid:
  - Route Planner → `/staff/route-planner` (Primary)
  - My Orders → `/staff/orders`
  - History → `/staff/delivery-history`
  - Statistics (placeholder)
- Larger icons (22px for cards, 30px for actions)

**Navigation**: `/staff/dashboard` (staffType: 'delivery')

**Responsibilities**:
- Accept delivery assignments
- Pick up orders from seller stores
- Deliver orders to customer locations
- Confirm pickups and deliveries (dual confirmation)
- Follow optimized routes

---

### 4. Orders to Process Screen / My Assigned Orders
**Purpose**: Process orders (Coordinator) or manage assigned deliveries (Delivery Personnel)

**For Order Coordinators**:
**Features**:
- Screen title: "Orders to Process"
- Filter chips: All, Accepted, Assigned
- Order cards with:
  - Order ID
  - Priority badge (High/Medium/Low)
  - Status badge (Accepted/Assigned)
  - Customer name
  - Seller name
  - Items count and date
  - Total amount
  - Customer address
  - Seller address
- Action buttons:
  - Assign Delivery (opens personnel selection dialog)
  - View Details
- Assign delivery dialog:
  - List of available delivery personnel
  - Select and assign

**For Delivery Personnel**:
**Features**:
- Screen title: "My Assigned Orders"
- Filter chips: All, Pending Accept, Accepted, Picked Up, Delivered
- Only shows orders assigned to logged-in deliverer
- Order cards with:
  - Order ID
  - Priority badge
  - Customer name
  - Seller name
  - Items count and date
  - Total amount
  - Customer address and phone
  - Seller address and phone
- Confirmation status box (when accepted):
  - Pickup confirmed ✓/✗
  - Delivery confirmed ✓/✗
- Action buttons based on status:
  - Not accepted → "Accept Order" (full width)
  - Accepted → "Confirm Pickup" + "Confirm Delivery" (side by side)
  - Pickup confirmed → "Confirm Pickup" disabled
  - Delivery locked → "Confirm Delivery" disabled (until pickup complete)
- Dual confirmation dialogs:
  - Pickup: Deliverer confirms → Wait for seller confirmation (2s simulation)
  - Delivery: Deliverer confirms → Wait for customer confirmation (2s simulation)
- Real-time status updates
- Success/waiting snackbar messages

**Navigation**: `/staff/orders`

**Workflow**:
1. Coordinator assigns order to deliverer
2. Deliverer sees order in "Pending Accept" filter
3. Deliverer clicks "Accept Order"
4. Order moves to "Accepted" filter
5. Deliverer clicks "Confirm Pickup" at seller location
6. System waits for seller confirmation
7. Both confirmations received → Pickup complete
8. "Confirm Delivery" button unlocks
9. Deliverer clicks "Confirm Delivery" at customer location
10. System waits for customer confirmation
11. Both confirmations received → Delivery complete
12. Order moves to "Delivered" filter

---

### 5. Support Tickets Screen
**Purpose**: Manage customer support tickets
**Features**:
- Filter chips: All, Open, In Progress, Resolved
- Ticket cards with:
  - Ticket ID
  - Category icon and badge (Technical, Billing, General, etc.)
  - Priority badge (High/Medium/Low) - color-coded
  - Status badge (Open/In Progress/Resolved)
  - Subject line
  - Customer name
  - Date submitted
  - Last message preview
  - Action buttons:
    - Open → "Take Ticket"
    - In Progress → "Mark Resolved"
    - All → "View Details"
- Ticket details modal:
  - Full ticket information
  - Conversation thread
  - Reply text field
  - Send button
  - Change status dropdown
  - Assign to agent dropdown
- Responsive layout with Wrap widgets
- Overflow protection

**Navigation**: `/staff/tickets`

---

### 6. Live Chat Screen
**Purpose**: Real-time customer support chat
**Features**:
- Stats cards:
  - Active Chats (5)
  - Waiting (3)
- Active chats list with:
  - Customer avatar with online status indicator (green dot)
  - Customer name
  - Last message preview
  - Timestamp
  - Unread message badge (red circle with count)
- Tap chat to open chat interface modal:
  - Customer info header
  - Message area with scrollable conversation
  - Message bubbles (customer vs agent)
  - Timestamps
  - Message input field
  - Send button
  - Typing indicator
- Real-time updates
- Sound notifications

**Navigation**: `/staff/chat`

---

### 7. Moderation Screen
**Purpose**: Review and moderate flagged content
**Features**:
- Pending items banner showing count
- Filter chips: All, Products, Reviews, Comments
- Flagged item cards with:
  - Item ID
  - Type badge (Product/Review/Comment) - color-coded
  - Status badge (Pending/Reviewed)
  - Item image (if applicable)
  - Title/content preview
  - Reason for flagging
  - Description
  - Reporter name
  - Date flagged
  - Action buttons:
    - Approve (green)
    - Remove (red)
- Confirmation dialogs for actions
- Responsive layout with Wrap widgets
- Overflow protection

**Navigation**: `/staff/moderation`

---

### 8. Help Center Screen
**Purpose**: Knowledge base for support staff
**Features**:
- Search bar for articles
- Category filter chips: All, Getting Started, Orders, Payments, Technical, Policies
- Article cards with:
  - Title
  - Category badge
  - View count
  - Last updated date
  - Read article button
- Article viewer modal:
  - Article title
  - Content
  - Related articles
  - Helpful/Not helpful buttons
- Searchable knowledge base
- Article categories

**Navigation**: `/staff/help-center`

---

### 9. Route Planner Screen
**Purpose**: Optimize delivery routes with pickup and delivery stops
**Features**:
- Route summary card:
  - Pending deliveries count (4)
  - Completed deliveries count (2)
  - Total distance (13.3 km)
  - Total estimated time (50 min)
  - Optimize Route button
- Delivery stop cards with:
  - Priority number badge (1, 2, 3, 4...)
  - Stop type badge:
    - PICKUP (orange) - from seller
    - DELIVERY (blue) - to customer
  - Order ID
  - Location name (seller name or customer name)
  - Address
  - Phone number
  - Distance and estimated time badges
  - Items count badge
  - Status indicator:
    - Pending (priority number)
    - Locked (lock icon, grey) - delivery locked until pickup complete
    - Completed (checkmark, green border)
- Confirmation status box (for pending stops):
  - Deliverer confirmed ✓/✗
  - Seller/Customer confirmed ✓/✗
- Action buttons:
  - Navigate (opens maps)
  - Confirm Pickup / Complete Delivery
- Dual confirmation dialogs:
  - Pickup confirmation:
    - "Have you picked up items from [Seller]?"
    - Info: "Seller must also confirm handover"
    - Confirm button
  - Delivery confirmation:
    - "Have you delivered items to [Customer]?"
    - Info: "Customer must also confirm receipt"
    - Confirm button
- Automatic unlocking:
  - When pickup confirmed by both parties → Delivery stop unlocks
- Visual indicators:
  - Locked stops are greyed out
  - Completed stops have green border and checkmark
  - Active stops have priority numbers
- Two stops per order workflow

**Navigation**: `/staff/route-planner`

**Workflow**:
1. Deliverer sees list of stops in priority order
2. Each order has 2 stops: PICKUP → DELIVERY
3. Delivery stop is locked until pickup is complete
4. Deliverer clicks "Navigate" to open maps
5. Arrives at seller location
6. Clicks "Confirm Pickup"
7. Waits for seller confirmation (2s simulation)
8. Both confirmations received → Pickup complete
9. Delivery stop unlocks
10. Deliverer navigates to customer location
11. Clicks "Complete Delivery"
12. Waits for customer confirmation (2s simulation)
13. Both confirmations received → Delivery complete
14. Stop marked as completed with checkmark

---

### 10. Active Deliveries Screen
**Purpose**: Track ongoing deliveries
**Features**:
- Placeholder screen
- "Coming Soon" message
- Will show orders currently in transit
- Real-time tracking

**Navigation**: `/staff/active-deliveries`

---

### 11. Delivery History Screen
**Purpose**: View completed deliveries
**Features**:
- Placeholder screen
- "Coming Soon" message
- Will show completed delivery history
- Performance metrics
- Earnings summary

**Navigation**: `/staff/delivery-history`

---

### 12. Staff Profile Screen
**Purpose**: Manage staff account
**Features**:
- Profile picture
- Staff information:
  - Name
  - Email
  - Phone
  - Staff type (Coordinator/Support/Delivery)
- Edit profile button
- Performance statistics
- Logout button

**Navigation**: From staff menu

---

## Admin Screens

### 1. Admin Dashboard
**Purpose**: Platform-wide overview and management
**Features**:
- Welcome banner
- Summary cards (responsive):
  - Total Users (1,234) - Blue
  - Active Sellers (89) - Green
  - Total Orders (456) - Orange
  - Revenue (UGX 45.6M) - Purple
- Quick actions grid:
  - Manage Sellers
  - View Analytics
  - User Management
  - Platform Settings
- Recent activity feed
- System health indicators
- Notification icon

**Navigation**: `/admin/dashboard`

---

### 2. Seller Management Screen
**Purpose**: Approve and manage sellers
**Features**:
- Pending applications tab
- Active sellers tab
- Suspended sellers tab
- Seller cards with:
  - Store name and logo
  - Owner name
  - Registration date
  - Status
  - Rating
  - Total sales
  - Action buttons:
    - Approve/Reject (for pending)
    - View Details
    - Suspend/Activate
- Seller details modal:
  - Full store information
  - Business documents
  - Sales history
  - Customer reviews
  - Compliance status
- Bulk actions
- Search and filter

**Navigation**: `/admin/sellers`

---

### 3. User Management Screen
**Purpose**: Manage all platform users
**Features**:
- User list with:
  - Name and email
  - Role (Customer/Seller/Staff/Admin)
  - Registration date
  - Status (Active/Suspended)
  - Last login
  - Action buttons
- Filter by role and status
- Search users
- User details modal
- Suspend/activate users
- Reset password
- View user activity

**Navigation**: `/admin/users`

---

### 4. Platform Analytics Screen
**Purpose**: View platform-wide analytics
**Features**:
- Date range selector
- Key metrics:
  - Total revenue
  - Total orders
  - Active users
  - Growth rate
- Revenue chart (line graph)
- Orders by status (pie chart)
- Top sellers leaderboard
- Top products
- User growth chart
- Geographic distribution map
- Export reports button

**Navigation**: `/admin/analytics`

---

### 5. Admin Settings Screen
**Purpose**: Configure platform settings
**Features**:
- General settings:
  - Platform name
  - Logo
  - Contact information
- Commission settings:
  - Seller commission percentage
  - Delivery fee
- Payment settings:
  - Payment gateways
  - Payout schedule
- Email settings:
  - SMTP configuration
  - Email templates
- Security settings:
  - Password requirements
  - Session timeout
- Feature toggles:
  - Enable/disable features
- Backup and restore

**Navigation**: `/admin/settings`

---

## Feature Summary

### Core Features

#### 1. Multi-Role Authentication
- 6 user types: Customer, Seller, Order Coordinator, Customer Support, Delivery Personnel, Admin
- Role-based dashboards and permissions
- Test accounts for all roles
- Secure login with password visibility toggle
- Google Sign-In integration (UI ready)

#### 2. Dual Confirmation System
**Pickup Confirmation**:
- Deliverer confirms pickup at seller location
- Seller confirms handover
- Both confirmations required to mark pickup complete
- 2-second simulation for seller confirmation

**Delivery Confirmation**:
- Deliverer confirms delivery at customer location
- Customer confirms receipt
- Both confirmations required to mark delivery complete
- 2-second simulation for customer confirmation

**Benefits**:
- Accountability and transparency
- Prevents disputes
- Clear chain of custody
- Real-time status tracking

#### 3. Order Management
**For Customers**:
- Place orders
- Track order status
- Confirm delivery receipt
- Rate and review

**For Sellers**:
- Accept/reject orders
- Mark orders as ready
- Confirm handover to delivery personnel
- View order history

**For Order Coordinators**:
- View all accepted orders
- Assign orders to delivery personnel
- Monitor order flow
- Coordinate between parties

**For Delivery Personnel**:
- Accept delivery assignments
- Confirm pickups from sellers
- Confirm deliveries to customers
- Follow optimized routes
- View delivery history

#### 4. Route Optimization
- Two stops per order: PICKUP → DELIVERY
- Priority-based ordering
- Distance and time estimates
- Navigate button (opens maps)
- Locked delivery stops until pickup complete
- Visual status indicators
- Optimize route button

#### 5. Customer Support
**Support Tickets**:
- Create and track tickets
- Priority levels (High/Medium/Low)
- Status tracking (Open/In Progress/Resolved)
- Category-based organization
- Conversation threads

**Live Chat**:
- Real-time messaging
- Online status indicators
- Unread message badges
- Typing indicators
- Chat history

**Help Center**:
- Searchable knowledge base
- Category-based articles
- View counts
- Related articles

#### 6. Content Moderation
- Flag inappropriate content
- Review flagged items
- Approve or remove content
- Filter by type (Products/Reviews/Comments)
- Reporter information
- Moderation history

#### 7. Analytics & Reporting
**For Sellers**:
- Revenue charts
- Top selling products
- Sales by category
- Customer demographics
- Export data

**For Admins**:
- Platform-wide metrics
- Revenue tracking
- User growth
- Geographic distribution
- Export reports

#### 8. Responsive Design
- Overflow protection on all screens
- Flexible layouts
- FittedBox for text scaling
- Spacer for dynamic spacing
- Wrap widgets for flexible content
- Tested on multiple screen sizes

#### 9. Real-Time Updates
- Order status changes
- Delivery tracking
- Chat messages
- Notifications
- Confirmation status

#### 10. Security Features
- Role-based access control
- Secure authentication
- Password encryption (ready)
- Session management
- Data validation

### Technical Features

#### UI/UX
- Material Design 3
- Custom color scheme
- Consistent styling
- Smooth animations
- Loading states
- Error handling
- Success/error snackbars
- Modal dialogs
- Bottom sheets

#### Navigation
- Named routes
- Bottom navigation bar
- Drawer navigation
- Back button handling
- Deep linking ready

#### State Management
- StatefulWidget for local state
- UserManager service for user data
- Real-time updates with setState

#### Data Management
- Mock data for testing
- Ready for API integration
- Data models
- Service layer architecture

---

## Screen Count Summary

- **Authentication**: 4 screens
- **Customer**: 10 screens
- **Seller**: 8 screens
- **Staff**: 12 screens (3 dashboard variants + 9 functional screens)
- **Admin**: 5 screens

**Total**: 39 screens (30+ unique screens, some with variants)

---

## Key Workflows

### 1. Order Placement to Delivery
1. Customer browses products → Adds to cart → Checks out
2. Seller receives order → Accepts order → Prepares items
3. Order Coordinator assigns order to delivery personnel
4. Delivery personnel accepts assignment
5. Delivery personnel goes to seller → Confirms pickup
6. Seller confirms handover → Pickup complete
7. Delivery personnel goes to customer → Confirms delivery
8. Customer confirms receipt → Delivery complete

### 2. Customer Support
1. Customer submits ticket or starts chat
2. Support staff receives notification
3. Support staff takes ticket or responds to chat
4. Conversation continues until resolved
5. Support staff marks ticket as resolved
6. Customer rates support experience

### 3. Content Moderation
1. User flags inappropriate content
2. Moderator receives notification
3. Moderator reviews flagged content
4. Moderator approves or removes content
5. User receives notification of decision

### 4. Seller Onboarding
1. User signs up as seller
2. Admin reviews application
3. Admin approves or rejects
4. Seller receives notification
5. Seller sets up store
6. Seller adds products
7. Store goes live

---

## Future Enhancements

### Planned Features
1. Real-time GPS tracking for deliveries
2. In-app calling between deliverer and customer
3. Push notifications
4. Payment gateway integration
5. Rating and review system
6. Wishlist sync across devices
7. Order scheduling
8. Bulk order management
9. Advanced analytics with AI insights
10. Multi-language support
11. Dark mode
12. Offline mode
13. Voice search
14. AR product preview
15. Social sharing

### Technical Improvements
1. API integration
2. Database implementation
3. Cloud storage for images
4. Real-time database for chat
5. Caching strategy
6. Performance optimization
7. Automated testing
8. CI/CD pipeline
9. Error tracking
10. Analytics integration

---

**Last Updated**: February 26, 2026
**Version**: 1.0.0
**Platform**: Flutter (iOS & Android)
