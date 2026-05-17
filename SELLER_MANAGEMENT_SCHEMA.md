# Campus Cart Firestore Schema - Seller Management System

## Overview
This document describes the Firestore database schema additions for the seller onboarding and management system in Campus Cart.

---

## Collections

### 1. `users` (Enhanced)
Existing collection with new seller-related fields.

**Document ID:** `{userId}`

**Fields:**
```
{
  userId: string               // Firebase Auth UID
  name: string                 // User's full name
  email: string                // User's email address
  phone: string                // User's phone number
  profileImage: string         // URL to profile image
  role: string                 // "customer" | "seller" | "admin"
  
  // Seller-specific fields
  sellerApproved: boolean      // true if seller request approved by admin
  sellerApprovedAt: timestamp  // When seller was approved
  storeCount: number           // Current number of active stores (0-maxStoresPerSeller)
  createdAt: timestamp         // Account creation date
  updatedAt: timestamp         // Last profile update
}
```

**Indexes:**
- `role` (for querying all sellers)
- `sellerApproved` (for listing approved sellers)

---

### 2. `seller_requests`
Stores seller upgrade requests from customers.

**Document ID:** Auto-generated

**Fields:**
```
{
  id: string                      // Unique request ID
  userId: string                  // User requesting to become seller
  userName: string                // User's full name
  userEmail: string               // User's email
  userPhone: string               // User's phone
  
  // Application status
  status: string                  // "pending" | "approved" | "rejected"
  adminNotes: string              // Notes from admin (rejection reason, etc.)
  createdAt: timestamp            // Request submission date
  reviewedAt: timestamp           // When admin reviewed it
  reviewedBy: string              // Admin user ID who reviewed it
}
```

**Indexes:**
- `userId, status` (for checking user's pending/approved requests)
- `status` (for admin viewing pending requests)
- `createdAt` (for sorting by date)

---

### 3. `seller_stores`
Individual stores created by approved sellers.

**Document ID:** Auto-generated

**Fields:**
```
{
  id: string                      // Store ID
  sellerId: string                // User ID of store owner
  
  // Store information
  storeName: string               // Name of the store
  storeDescription: string        // Description of store
  storeImage: string              // URL to store image/logo
  location: string                // Store location
  phone: string                   // Store phone number
  
  // Performance metrics
  rating: number                  // Average rating (0-5)
  reviewCount: number             // Number of reviews
  
  // Status
  isActive: boolean               // Whether store is active
  
  // Timestamps
  createdAt: timestamp            // When store was created
  updatedAt: timestamp            // Last update
}
```

**Indexes:**
- `sellerId, isActive` (for getting seller's stores)
- `location` (for location-based searches)
- `isActive` (for browsing active stores)

---

### 4. `admin_settings`
Global admin configuration settings.

**Document ID:** `seller_config`

**Fields:**
```
{
  maxStoresPerSeller: number      // Max stores each seller can create (default: 1)
  sellerApprovalRequired: boolean // Whether seller requests need admin approval
  lastUpdatedAt: timestamp        // Last time settings were changed
  lastUpdatedBy: string           // Admin user ID who made the change
}
```

**Subcollection:** `audit_log`
```
{
  setting: string                 // Which setting was changed
  newValue: string                // New value
  changedBy: string               // Admin user ID
  timestamp: timestamp            // When change was made
}
```

**Indexes:**
- None (single document lookup)

---

### 5. `seller_admin_chat` (New)
Messages between admin and sellers.

**Document ID:** Auto-generated

**Fields:**
```
{
  sellerId: string                // Seller ID
  adminId: string                 // Admin ID
  
  // Message content
  message: string                 // Message text
  senderRole: string              // "admin" | "seller"
  
  // Status
  isRead: boolean                 // Whether message has been read
  readAt: timestamp               // When message was read
  
  // Timestamps
  createdAt: timestamp            // Message sent date
  timestamp: timestamp            // Message timestamp (for ordering)
}
```

**Indexes:**
- `sellerId, createdAt` (for chat history per seller)
- `adminId, createdAt` (for admin viewing all seller chats)

---

### 6. `order_chat` (Enhanced)
Messages between sellers and buyers about specific orders.

**Document ID:** Auto-generated

**Fields:**
```
{
  orderId: string                 // Order ID this chat is about
  sellerId: string                // Seller ID
  customerId: string              // Customer ID
  
  // Message content
  message: string                 // Message text
  senderRole: string              // "seller" | "customer"
  
  // Status
  isRead: boolean                 // Whether message has been read
  readAt: timestamp               // When message was read
  
  // Timestamps
  createdAt: timestamp            // Message sent date
  timestamp: timestamp            // Message timestamp (for ordering)
}
```

**Indexes:**
- `orderId, createdAt` (for order-specific chat)
- `sellerId, customerId` (for seller-buyer chat history)

---

### 7. `products` (Enhanced)
Existing products collection with seller linkage.

**Document ID:** Auto-generated

**Fields:**
```
{
  id: string                      // Product ID
  
  // Basic info
  name: string                    // Product name
  description: string             // Product description
  image: string                   // Product image URL
  price: number                   // Product price
  
  // Seller information
  sellerId: string                // ID of seller offering this product
  storeId: string                 // Store ID (which of seller's stores)
  
  // Inventory
  quantity: number                // Stock quantity
  
  // Categorization
  category: string                // Product category
  
  // Performance
  rating: number                  // Average rating
  reviewCount: number             // Number of reviews
  
  // Status
  isActive: boolean               // Whether product is listed
  
  // Timestamps
  createdAt: timestamp            // When product was added
  updatedAt: timestamp            // Last update
}
```

**Indexes:**
- `sellerId, isActive` (for seller's product list)
- `storeId, isActive` (for store-specific products)
- `category` (for browsing by category)

---

### 8. `orders` (Enhanced)
Existing orders collection with approval workflow.

**Document ID:** Auto-generated

**Fields:**
```
{
  id: string                      // Order ID
  
  // Parties involved
  customerId: string              // Customer ID
  sellerId: string                // Seller ID
  
  // Order details
  items: array<{
    productId: string
    name: string
    price: number
    quantity: number
  }>
  totalAmount: number             // Total order amount
  
  // Approval workflow (NEW)
  status: string                  // "pending" | "approved" | "rejected" | "processing" | "delivered"
  approvalStatus: string          // "pending" | "approved" | "rejected"
  approvalMessage: string         // Message from seller on approval/rejection
  approvedAt: timestamp           // When seller approved
  rejectionReason: string         // If rejected, why
  
  // Delivery
  deliveryAddress: string         // Delivery address
  
  // Timestamps
  createdAt: timestamp            // When order was placed
  updatedAt: timestamp            // Last status update
}
```

**Indexes:**
- `customerId, createdAt` (for customer's order history)
- `sellerId, status` (for seller's pending orders)
- `status` (for filtering by status)

---

## Security Rules Overview

### `seller_requests`
- Customers can create requests (create own record)
- Customers can read own requests
- Admin can read all and update

### `seller_stores`
- Sellers can read/create their own stores
- Customers can read active stores
- Admin can read all

### `seller_admin_chat`
- Admin can read/write all
- Sellers can read/write own chats

### `products`
- Sellers can create/update own products
- Customers can read active products only
- Admin can read all

### `orders`
- Customers can read own orders
- Sellers can read/update own orders
- Admin can read all

---

## Data Flow Examples

### Seller Onboarding Flow
1. Customer submits seller request → `seller_requests` (status: pending)
2. Admin reviews and approves → Updates `seller_requests` (status: approved) + Updates `users` (sellerApproved: true)
3. Seller creates store → `seller_stores` document created + `users.storeCount` incremented
4. Seller adds products → `products` documents with sellerId + storeId

### Order Approval Flow
1. Customer places order → `orders` created (status: pending, approvalStatus: pending)
2. Seller receives order notification
3. Seller approves/rejects → Updates `orders` (approvalStatus: approved/rejected, approvalMessage)
4. Customer receives notification via `notifications` collection
5. Seller-buyer can chat via `order_chat` collection

---

## Constraints & Business Rules

| Rule | Implementation |
|------|-----------------|
| Max stores per seller | Enforced in `SellerStoreService.createStore()` by checking max vs existing |
| Seller must be approved | Verified before store/product creation |
| Admin configurable limits | Stored in `admin_settings.seller_config` |
| Store count tracking | Auto-incremented/decremented in `users.storeCount` |
| Product linked to seller | Every product must have `sellerId` and `storeId` |

---

## Migration Notes

- Existing `products` collection needs `sellerId` and `storeId` fields added
- Existing `orders` need `approvalStatus` and approval workflow fields added
- New `seller_requests`, `seller_stores`, `admin_settings`, `seller_admin_chat` collections created fresh
