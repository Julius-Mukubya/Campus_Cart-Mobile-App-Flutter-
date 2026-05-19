# Campus Cart — App Requirements

## 1. Overview
Campus Cart is a campus-focused marketplace mobile application that connects buyers (customers) with sellers. The app acts as a platform for product discovery, ordering, and communication — no delivery or payment handling is included.

## 2. User Roles

### 2.1 Customer
- Browse products, search, filter by category
- Add/remove products from cart and wishlist
- Place orders (simplified checkout — no address, no payment)
- View order history and status
- Communicate with seller via order-specific chat
- Request follow-up chat after order completion
- Leave a review when notified after order completion
- Message seller directly via store page ("Message" button)
- Privacy toggle: choose whether to show contact info to sellers

### 2.2 Seller
- Manage products (add/edit/delete)
- View incoming orders
- Accept or reject orders (with required reason if rejected)
- Communicate with customer via order-specific chat
- Confirm order completion (dual confirmation with customer)
- View their store page as customers see it
- Receive notifications of new orders

### 2.3 Admin
- Full system access
- Manage users (view, suspend, approve seller requests)
- View all orders and products
- Communicate directly with any user (customer or seller) via chat
- Manage seller applications (approve/reject)

## 3. Authentication & Onboarding

### 3.1 Sign In
- Required to use the app (no guest browsing)
- Email + password authentication via Firebase Auth
- "Forgot password" flow with email reset
- Password visibility toggle

### 3.2 Sign Up
- Fields: Name, Email, Phone, Password
- Role selection: **Customer** or **Seller**
- If **Customer** selected → account created immediately with role `customer`
- If **Seller** selected → account created with role `customer`, and a **seller request** is sent to admin for approval
- Admin approves/rejects seller requests → upon approval, user role changes to `seller`

### 3.3 Seller Approval Flow
- Admin sees pending seller requests with user details (name, email, phone, date requested)
- Admin can approve (user becomes seller) or reject (with reason)
- User receives notification of approval/rejection

## 4. Order Flow

### 4.1 Order Statuses
| Status | Description | Who Can Trigger |
|--------|-------------|-----------------|
| `pending` | Customer has placed the order | Customer |
| `accepted` | Seller has accepted the order | Seller |
| `rejected` | Seller has rejected (with reason) | Seller |
| `cancelled` | Customer cancelled before acceptance | Customer |
| `completed` | Both customer and seller confirmed completion | Both (dual confirm) |

### 4.2 Placing an Order
1. Customer adds products to cart
2. Customer proceeds to simplified checkout
3. Checkout shows: order summary (items, quantities, totals) + contact visibility toggle
4. No address form, no payment method selection, no delivery fee
5. Customer taps "Place Order"
6. Order created with status `pending`
7. Seller receives instant notification: "New order from [Customer Name]"

### 4.3 Seller Actions on Order
- Seller sees order in their orders list
- **Accept**: Changes status to `accepted`. Customer notified.
- **Reject**: Required text reason. Changes status to `rejected`. Customer notified with reason.

### 4.4 Customer Actions on Order
- **Cancel**: Only available when status is `pending`. Changes status to `cancelled`.

### 4.5 Order Completion (Dual Confirmation)
- Both customer and seller have a **"Mark as Complete"** button inside the order-specific chat
- Order only moves to `completed` status when **both parties** have clicked their button
- When completed:
  - Chat becomes **read-only (disabled)** — no new messages can be sent
  - Customer receives notification: "Your order is complete! Leave a review"
  - Both parties can still view the chat history

### 4.6 Follow-up Chat
- After order completion, customer sees a **"Follow-up"** button
- Tapping it re-enables the chat so both parties can continue communicating
- The chat remains in "follow-up" mode (no further completion confirmation needed)

## 5. Chat System

### 5.1 Chat Types

| Chat Type | Participants | Created Via | Persistence |
|-----------|-------------|-------------|-------------|
| **Order Chat** | Customer ↔ Seller | Auto-created when order placed | Disabled after completion; re-enable via follow-up |
| **Store Direct Chat** | Customer → Seller | Customer taps "Message" on store page | Always enabled |
| **Admin Direct Chat** | Admin ↔ Any User | Admin initiates from user list | Always enabled |

### 5.2 Chat List Screen
- Every user has a chat list screen showing all their conversations
- Each chat entry shows: other participant's name, last message preview, timestamp
- Tapping a chat opens the conversation

### 5.3 Chat Interface Features
- Text messages with timestamps
- Sender name displayed for each message
- Real-time updates via Firestore listener
- Messages stored in: `chats/{chatId}/messages/{messageId}`

### 5.4 Order Chat Specifics
- Contains "Mark as Complete" button for each party
- Shows confirmation status: "Seller confirmed ✓" / "Customer confirmed ✓"
- When both confirmed → chat disables (read-only mode)
- Customer can re-enable with "Follow-up" button

### 5.5 Store Page & Direct Chat
- Each seller has a store page showing their products and info
- Store page displays seller name and (if they've opted in) contact details
- **"Message" button** → creates or opens a direct chat between customer and seller
- No order required for this chat

### 5.6 Admin Chat
- Admin can start a chat with any customer or seller
- Admin sees a user list to select who to message
- No restrictions on admin chat access

## 6. Review System

### 6.1 Trigger
- When an order status changes to `completed`, the customer receives a notification:
  "Your order [order ID] is complete! Please leave a review"

### 6.2 Review Screen
- Customer taps notification → navigated to review screen
- Customer selects a product from the completed order
- Provides: Star rating (1-5) + optional text review
- Review saved to Firestore under the product

### 6.3 Where Reviews Display
- On the product details page (average rating + individual reviews)
- On the seller's store page (overall seller rating)

## 7. Notification System

### 7.1 Notification Types
| Trigger | Recipient | Content |
|---------|-----------|---------|
| New order placed | Seller | "New order from [Customer Name]" |
| Order accepted | Customer | "Order accepted by [Seller Name] — Contact: [seller phone]" |
| Order rejected | Customer | "Order rejected: [reason]" |
| Order completed | Customer | "Order complete! Leave a review" |
| Seller request approved | User | "You are now a seller!" |
| Seller request rejected | User | "Seller request rejected: [reason]" |

### 7.2 Contact Privacy
- Customer has a toggle in profile: **"Show my contact info to sellers"**
- If OFF → seller sees "Customer" instead of name, contact info hidden
- If ON → seller sees customer name and phone number
- Notifications respect this setting

## 8. UI Navigation (Screens)

### 8.1 Customer Screens
| Screen | Purpose |
|--------|---------|
| Home | Product browsing, categories, search |
| Categories | Category listing with product counts |
| Product Details | Full product info, add to cart/wishlist |
| Cart | Cart items, quantity controls, proceed to checkout |
| Checkout | Simplified order summary + place order |
| Wishlist | Saved products |
| My Orders | Order history with status filters |
| Order Details | Order info + integrated order-specific chat |
| Store Page | Seller's store with products + Message button |
| Chat List | All conversations (order chats + direct chats) |
| Profile | User info, settings, logout |
| Edit Profile | Update name, email, phone, contact privacy toggle |
| Review Product | Star rating + text review (from notification) |
| Notifications | All received notifications |

### 8.2 Seller Screens
| Screen | Purpose |
|--------|---------|
| Dashboard | Sales overview, quick actions |
| My Products | Product management (add/edit/delete) |
| Add Product | Product creation form |
| Edit Product | Product editing form |
| Orders | Incoming orders with status filters |
| Order Details | Order info + integrated order-specific chat |
| Chat List | All conversations (order chats + direct chats) |
| Profile | Seller info, settings |

### 8.3 Admin Screens
| Screen | Purpose |
|--------|---------|
| Dashboard | Platform overview, manage sellers |
| Manage Sellers | Approve/reject seller requests |
| Seller Details | Full seller info |
| Chat List | All conversations with any user |
| Profile | Admin settings |

### 8.4 Auth Screens
| Screen | Purpose |
|--------|---------|
| Splash | App loading → redirect to sign in |
| Sign In | Email/password login |
| Sign Up | Registration with role selection |
| Forgot Password | Password reset via email |
| Access Denied | Unauthorized access page |

## 9. Architecture
- **Framework**: Flutter 3.x (null-safe)
- **State Management**: Riverpod
- **Backend**: Firebase (Firestore, Auth, Storage)
- **Local DB**: SQLite via sqflite
- **Data Flow**: UI → Providers (Riverpod) → Services → Repositories → Firebase/SQLite
- **Navigation**: GoRouter with role-based redirect guards

## 10. What Is NOT Included
- No delivery tracking or logistics
- No payment gateway integration (MTN, Airtel, card, etc.)
- No staff, coordinator, delivery personnel, or customer support roles
- No address management
- No in-app calling or GPS tracking