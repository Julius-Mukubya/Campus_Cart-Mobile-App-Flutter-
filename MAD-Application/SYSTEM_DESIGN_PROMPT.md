# Campus Cart System Design Prompt for Stitch

## Overview
Create a comprehensive system architecture diagram for Campus Cart - a campus marketplace mobile application built with Flutter. The system supports multiple user roles and includes order management, delivery tracking, and real-time features.

## System Components to Include

### 1. User Roles & Access
- **Customer**: Browse products, place orders, track deliveries, confirm receipt
- **Seller**: Manage products, accept orders, confirm pickups
- **Order Coordinator (Staff)**: Assign orders to delivery personnel, process orders
- **Delivery Personnel (Staff)**: Accept deliveries, confirm pickups/deliveries, route planning
- **Admin**: Manage sellers, system oversight

### 2. Core Modules

#### Authentication & Authorization
- Sign In / Sign Up
- Password Reset (OTP verification)
- Role-based access control
- Test accounts for each role

#### Customer Module
- Product browsing and search
- Categories and filters
- Shopping cart management
- Wishlist functionality
- Order placement
- Live order tracking with map
- Delivery confirmation (QR code + OTP)
- Customer support chat
- Order history
- Profile management

#### Seller Module
- Product management (add, edit, delete)
- Order management (accept/reject orders)
- Pickup confirmation (dual confirmation with deliverer)
- Earnings tracking
- Store settings
- Dashboard with statistics

#### Staff Module (Order Coordinator)
- View all orders to process
- Assign orders to delivery personnel
- Order filtering (All, Pending Accept, Accepted, Picked Up, Delivered)
- Support ticket management
- Live chat support
- Content moderation
- Help center

#### Staff Module (Delivery Personnel)
- View assigned orders only
- Route planner with pickup and delivery stops
- Dual confirmation system:
  * Accept order assignment
  * Confirm pickup (+ seller confirms)
  * Confirm delivery (+ customer confirms)
- Active deliveries tracking
- Delivery history
- Statistics dashboard

#### Admin Module
- Seller management (approve/suspend)
- System analytics
- User management
- Platform oversight

### 3. Key Features & Workflows

#### Order Flow
1. Customer places order
2. Seller accepts order
3. Order Coordinator assigns to delivery personnel
4. Delivery personnel accepts assignment
5. Delivery personnel picks up from seller (dual confirmation)
6. Delivery personnel delivers to customer (dual confirmation)
7. Order completed

#### Dual Confirmation System
- Pickup: Deliverer confirms + Seller confirms (2-second simulation)
- Delivery: Deliverer confirms + Customer confirms (QR/OTP verification)
- Visual status indicators for both parties

#### Route Planning
- Two stops per order: PICKUP (seller location) → DELIVERY (customer location)
- Stop types with badges (orange PICKUP, blue DELIVERY)
- Locked delivery stops until pickup complete
- Priority-based ordering
- Visual indicators (locked, pending, completed)

### 4. Technical Architecture

#### Frontend (Flutter Mobile App)
- Material Design UI
- Bottom navigation
- Role-based screen routing
- Real-time updates
- Map integration for tracking
- QR code scanner
- Push notifications

#### State Management
- Local managers:
  * UserManager (role, authentication)
  * CartManager (shopping cart)
  * WishlistManager (saved items)
  * NotificationManager (alerts)
  * OrderManager (order tracking)

#### Data Flow
- User authentication → Role determination → Dashboard routing
- Order creation → Seller acceptance → Coordinator assignment → Delivery execution
- Real-time status updates across all stakeholders

### 5. Screen Architecture (39 Total Screens)

#### Authentication Screens (4)
- Sign In, Sign Up, Forgot Password, OTP Verification, Reset Password

#### Customer Screens (10)
- Home, Categories, Product Details, Cart, Wishlist, My Orders, Live Tracking, Delivery Confirmation, Support Chat, Profile

#### Seller Screens (8)
- Dashboard, My Products, Add/Edit Product, Orders, Order Details, Earnings, Store Settings

#### Staff Screens (12)
- Dashboard (role-specific), Orders to Process, Route Planner, Active Deliveries, Delivery History, Support Tickets, Live Chat, Moderation, Help Center, Statistics

#### Admin Screens (5)
- Dashboard, Manage Sellers, Analytics, User Management, System Settings

### 6. Design Requirements

#### Visual Elements
- Color scheme: Primary (blue), Secondary (purple), Accent (orange), Success (green), Error (red)
- Card-based layouts with shadows
- Gradient backgrounds
- Icon-based navigation
- Status badges and indicators
- Progress tracking visualizations

#### User Experience
- Intuitive navigation
- Clear status indicators
- Confirmation dialogs for critical actions
- Loading states
- Error handling with user-friendly messages
- Accessibility considerations

### 7. Integration Points
- Map services (for live tracking)
- QR code generation/scanning
- Push notifications
- Real-time chat
- Image upload (product photos)
- Payment gateway (future)

### 8. Security & Access Control
- Role-based route protection
- Access denied screens for unauthorized access
- Secure authentication
- Data validation
- Session management

## Diagram Requirements

### Create the following diagrams:

1. **System Architecture Diagram**
   - Show all user roles
   - Display main modules and their relationships
   - Include data flow between components
   - Show external integrations

2. **Order Flow Diagram**
   - Visualize the complete order lifecycle
   - Show all stakeholders and their actions
   - Include dual confirmation points
   - Display status transitions

3. **User Role Hierarchy**
   - Show access levels
   - Display role-specific features
   - Include permission boundaries

4. **Screen Navigation Flow**
   - Map out all 39 screens
   - Show navigation paths
   - Include role-based routing

5. **Delivery Workflow**
   - Detail the route planning process
   - Show pickup and delivery stops
   - Include confirmation mechanisms
   - Display status updates

## Design Style
- Use modern, clean design
- Color-code different user roles
- Use icons for visual clarity
- Include legends for symbols
- Make it presentation-ready
- Ensure readability at different zoom levels

## Output Format
- High-resolution diagrams
- Exportable as PNG/SVG
- Suitable for documentation
- Professional presentation quality
