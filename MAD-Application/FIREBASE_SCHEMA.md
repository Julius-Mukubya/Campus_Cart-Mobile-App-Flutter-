# Campus Cart - Firebase Schema Documentation

## Overview
This document outlines the complete Firebase Firestore database schema for the Campus Cart mobile application. The schema is designed to support a multi-role e-commerce platform with customers, sellers, staff (delivery personnel, support, coordinators), and administrators.

---

## Collections Structure

### 1. Users Collection
**Path:** `/users/{userId}`

Stores all user information regardless of role.

```json
{
  "userId": "string (auto-generated)",
  "email": "string (unique, required)",
  "name": "string (required)",
  "phone": "string (optional)",
  "role": "string (enum: customer, seller, staff, admin)",
  "profileImage": "string (URL, optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "isActive": "boolean (default: true)",
  "isEmailVerified": "boolean (default: false)",
  
  // Role-specific fields
  "staffType": "string (enum: delivery, support, coordinator) - only for staff role",
  "storeId": "string (reference to stores collection) - only for seller role",
  
  // Customer-specific fields
  "defaultAddressId": "string (reference to addresses subcollection)",
  "defaultPaymentMethodId": "string (reference to paymentMethods subcollection)",
  
  // Statistics
  "totalOrders": "number (default: 0)",
  "totalSpent": "number (default: 0)",
  "rating": "number (default: 0, for delivery staff)",
  "completedDeliveries": "number (default: 0, for delivery staff)"
}
```

#### Subcollections:

##### 1.1 Addresses
**Path:** `/users/{userId}/addresses/{addressId}`

```json
{
  "addressId": "string (auto-generated)",
  "label": "string (e.g., Home, Work, Dorm)",
  "fullName": "string",
  "phone": "string",
  "addressLine1": "string",
  "addressLine2": "string (optional)",
  "city": "string",
  "state": "string",
  "postalCode": "string",
  "country": "string (default: Uganda)",
  "latitude": "number (optional)",
  "longitude": "number (optional)",
  "isDefault": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

##### 1.2 Payment Methods
**Path:** `/users/{userId}/paymentMethods/{paymentMethodId}`

```json
{
  "paymentMethodId": "string (auto-generated)",
  "type": "string (enum: mobile_money, card, cash_on_delivery)",
  "provider": "string (e.g., MTN, Airtel, Visa, Mastercard)",
  "accountNumber": "string (masked, e.g., **** **** **** 1234)",
  "accountName": "string",
  "isDefault": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

##### 1.3 Wishlist
**Path:** `/users/{userId}/wishlist/{productId}`

```json
{
  "productId": "string (reference to products collection)",
  "addedAt": "timestamp"
}
```

##### 1.4 Cart
**Path:** `/users/{userId}/cart/{cartItemId}`

```json
{
  "cartItemId": "string (auto-generated)",
  "productId": "string (reference to products collection)",
  "quantity": "number",
  "selectedVariant": "map (optional) {
    size: string,
    color: string,
    etc.
  }",
  "addedAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 2. Stores Collection
**Path:** `/stores/{storeId}`

Stores information for sellers.

```json
{
  "storeId": "string (auto-generated)",
  "sellerId": "string (reference to users collection)",
  "storeName": "string (required)",
  "description": "string",
  "logo": "string (URL)",
  "banner": "string (URL)",
  "email": "string",
  "phone": "string",
  "address": "map {
    addressLine1: string,
    addressLine2: string,
    city: string,
    state: string,
    postalCode: string
  }",
  "businessLicense": "string (document URL)",
  "taxId": "string",
  "status": "string (enum: pending, approved, suspended, rejected)",
  "rating": "number (0-5)",
  "totalReviews": "number",
  "totalProducts": "number",
  "totalSales": "number",
  "totalRevenue": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 3. Products Collection
**Path:** `/products/{productId}`

```json
{
  "productId": "string (auto-generated)",
  "storeId": "string (reference to stores collection)",
  "sellerId": "string (reference to users collection)",
  "name": "string (required)",
  "description": "string",
  "category": "string (reference to categories collection)",
  "subcategory": "string (optional)",
  "images": "array of strings (URLs)",
  "price": "number (required)",
  "compareAtPrice": "number (original price, optional)",
  "discount": "number (percentage, optional)",
  "currency": "string (default: UGX)",
  
  "stock": "number (required)",
  "sku": "string (unique)",
  "barcode": "string (optional)",
  
  "variants": "array of maps (optional) [
    {
      name: string (e.g., Size, Color),
      options: array of strings (e.g., [S, M, L])
    }
  ]",
  
  "specifications": "map (optional) {
    weight: string,
    dimensions: string,
    material: string,
    etc.
  }",
  
  "tags": "array of strings",
  "isFeatured": "boolean",
  "isActive": "boolean",
  "status": "string (enum: active, out_of_stock, discontinued)",
  
  "rating": "number (0-5)",
  "totalReviews": "number",
  "totalSales": "number",
  "views": "number",
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### Subcollections:

##### 3.1 Reviews
**Path:** `/products/{productId}/reviews/{reviewId}`

```json
{
  "reviewId": "string (auto-generated)",
  "userId": "string (reference to users collection)",
  "userName": "string",
  "userImage": "string (URL, optional)",
  "orderId": "string (reference to orders collection)",
  "rating": "number (1-5, required)",
  "title": "string (optional)",
  "comment": "string",
  "images": "array of strings (URLs, optional)",
  "isVerifiedPurchase": "boolean",
  "helpfulCount": "number (default: 0)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 4. Categories Collection
**Path:** `/categories/{categoryId}`

```json
{
  "categoryId": "string (auto-generated)",
  "name": "string (required, unique)",
  "description": "string",
  "icon": "string (icon name or URL)",
  "image": "string (URL)",
  "parentCategoryId": "string (reference to parent category, optional)",
  "order": "number (for sorting)",
  "isActive": "boolean",
  "productCount": "number",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 5. Orders Collection
**Path:** `/orders/{orderId}`

```json
{
  "orderId": "string (auto-generated)",
  "orderNumber": "string (unique, e.g., ORD-2024-001234)",
  "customerId": "string (reference to users collection)",
  "customerName": "string",
  "customerEmail": "string",
  "customerPhone": "string",
  
  "items": "array of maps [
    {
      productId: string,
      productName: string,
      productImage: string,
      storeId: string,
      sellerId: string,
      quantity: number,
      price: number,
      discount: number,
      subtotal: number,
      variant: map (optional)
    }
  ]",
  
  "subtotal": "number",
  "discount": "number",
  "shippingFee": "number",
  "tax": "number",
  "total": "number",
  "currency": "string (default: UGX)",
  
  "shippingAddress": "map {
    fullName: string,
    phone: string,
    addressLine1: string,
    addressLine2: string,
    city: string,
    state: string,
    postalCode: string,
    latitude: number,
    longitude: number
  }",
  
  "paymentMethod": "string (enum: mobile_money, card, cash_on_delivery)",
  "paymentStatus": "string (enum: pending, paid, failed, refunded)",
  "paymentDetails": "map {
    provider: string,
    transactionId: string,
    paidAt: timestamp
  }",
  
  "status": "string (enum: pending, confirmed, processing, ready_for_pickup, out_for_delivery, delivered, cancelled, returned)",
  "statusHistory": "array of maps [
    {
      status: string,
      timestamp: timestamp,
      note: string,
      updatedBy: string (userId)
    }
  ]",
  
  "assignedStaffId": "string (reference to users collection, for delivery)",
  "assignedStaffName": "string",
  "estimatedDeliveryDate": "timestamp",
  "actualDeliveryDate": "timestamp (optional)",
  
  "notes": "string (customer notes)",
  "internalNotes": "string (staff/admin notes)",
  
  "requiresDualConfirmation": "boolean",
  "customerConfirmed": "boolean",
  "staffConfirmed": "boolean",
  "confirmationCode": "string (6-digit code)",
  
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 6. Notifications Collection
**Path:** `/notifications/{notificationId}`

```json
{
  "notificationId": "string (auto-generated)",
  "userId": "string (reference to users collection)",
  "type": "string (enum: order, delivery, promotion, system, support)",
  "title": "string",
  "message": "string",
  "icon": "string (icon name)",
  "color": "string (hex color)",
  "data": "map (optional, additional data) {
    orderId: string,
    productId: string,
    etc.
  }",
  "isRead": "boolean (default: false)",
  "actionUrl": "string (optional, deep link)",
  "createdAt": "timestamp"
}
```

---

### 7. Support Tickets Collection
**Path:** `/supportTickets/{ticketId}`

```json
{
  "ticketId": "string (auto-generated)",
  "ticketNumber": "string (unique, e.g., TKT-2024-001234)",
  "userId": "string (reference to users collection)",
  "userName": "string",
  "userEmail": "string",
  "subject": "string",
  "category": "string (enum: order_issue, product_issue, payment_issue, delivery_issue, account_issue, other)",
  "priority": "string (enum: low, medium, high, urgent)",
  "status": "string (enum: open, in_progress, waiting_customer, resolved, closed)",
  "assignedStaffId": "string (reference to users collection, optional)",
  "assignedStaffName": "string",
  "orderId": "string (reference to orders collection, optional)",
  "productId": "string (reference to products collection, optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "resolvedAt": "timestamp (optional)"
}
```

#### Subcollections:

##### 7.1 Messages
**Path:** `/supportTickets/{ticketId}/messages/{messageId}`

```json
{
  "messageId": "string (auto-generated)",
  "senderId": "string (reference to users collection)",
  "senderName": "string",
  "senderRole": "string (enum: customer, staff, admin)",
  "message": "string",
  "attachments": "array of strings (URLs, optional)",
  "isInternal": "boolean (staff-only notes)",
  "createdAt": "timestamp"
}
```

---

### 8. Chat Support Collection
**Path:** `/chatSupport/{chatId}`

For customer support chat (AI or human).

```json
{
  "chatId": "string (auto-generated)",
  "userId": "string (reference to users collection)",
  "userName": "string",
  "status": "string (enum: active, closed)",
  "assignedStaffId": "string (reference to users collection, optional)",
  "isAiHandled": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "closedAt": "timestamp (optional)"
}
```

#### Subcollections:

##### 8.1 Messages
**Path:** `/chatSupport/{chatId}/messages/{messageId}`

```json
{
  "messageId": "string (auto-generated)",
  "senderId": "string (reference to users collection or 'ai')",
  "senderName": "string",
  "senderType": "string (enum: customer, staff, ai)",
  "message": "string",
  "timestamp": "timestamp"
}
```

---

### 9. Delivery Routes Collection
**Path:** `/deliveryRoutes/{routeId}`

For delivery personnel route planning.

```json
{
  "routeId": "string (auto-generated)",
  "staffId": "string (reference to users collection)",
  "staffName": "string",
  "date": "timestamp",
  "status": "string (enum: planned, in_progress, completed)",
  "orders": "array of strings (orderIds)",
  "stops": "array of maps [
    {
      orderId: string,
      address: string,
      latitude: number,
      longitude: number,
      sequence: number,
      status: string (enum: pending, completed, failed),
      arrivedAt: timestamp,
      completedAt: timestamp
    }
  ]",
  "totalDistance": "number (km)",
  "estimatedDuration": "number (minutes)",
  "startedAt": "timestamp",
  "completedAt": "timestamp",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 10. FAQ Articles Collection
**Path:** `/faqArticles/{articleId}`

```json
{
  "articleId": "string (auto-generated)",
  "title": "string",
  "content": "string",
  "category": "string (enum: Orders, Products, Payments, Shipping, Returns)",
  "icon": "string (icon name)",
  "color": "string (hex color)",
  "views": "number (default: 0)",
  "helpfulCount": "number (default: 0)",
  "order": "number (for sorting)",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 11. System Settings Collection
**Path:** `/systemSettings/{settingId}`

```json
{
  "settingId": "string (e.g., shipping_config, tax_config, payment_config)",
  "type": "string",
  "config": "map {
    // Dynamic configuration based on type
  }",
  "isActive": "boolean",
  "updatedAt": "timestamp",
  "updatedBy": "string (userId)"
}
```

**Example - Shipping Config:**
```json
{
  "settingId": "shipping_config",
  "type": "shipping",
  "config": {
    "freeShippingThreshold": 50000,
    "standardShippingFee": 5000,
    "expressShippingFee": 10000,
    "standardDeliveryDays": "2-5",
    "expressDeliveryDays": "1-2"
  },
  "isActive": true,
  "updatedAt": "timestamp",
  "updatedBy": "adminUserId"
}
```

---

### 12. Analytics Collection
**Path:** `/analytics/{analyticsId}`

For tracking various metrics.

```json
{
  "analyticsId": "string (auto-generated)",
  "type": "string (enum: daily_sales, product_views, user_activity, etc.)",
  "date": "timestamp",
  "metrics": "map {
    // Dynamic metrics based on type
    totalSales: number,
    totalOrders: number,
    totalRevenue: number,
    newUsers: number,
    etc.
  }",
  "createdAt": "timestamp"
}
```

---

## Security Rules

### Basic Security Rules Structure

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    function isAdmin() {
      return hasRole('admin');
    }
    
    function isStaff() {
      return hasRole('staff');
    }
    
    function isSeller() {
      return hasRole('seller');
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn() && request.auth.uid == userId;
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isAdmin();
      
      // Subcollections
      match /addresses/{addressId} {
        allow read, write: if isOwner(userId);
      }
      
      match /paymentMethods/{paymentMethodId} {
        allow read, write: if isOwner(userId);
      }
      
      match /wishlist/{productId} {
        allow read, write: if isOwner(userId);
      }
      
      match /cart/{cartItemId} {
        allow read, write: if isOwner(userId);
      }
    }
    
    // Stores collection
    match /stores/{storeId} {
      allow read: if isSignedIn();
      allow create: if isSeller();
      allow update: if isAdmin() || 
                      (isSeller() && resource.data.sellerId == request.auth.uid);
      allow delete: if isAdmin();
    }
    
    // Products collection
    match /products/{productId} {
      allow read: if true; // Public read
      allow create: if isSeller();
      allow update: if isAdmin() || 
                      (isSeller() && resource.data.sellerId == request.auth.uid);
      allow delete: if isAdmin() || 
                      (isSeller() && resource.data.sellerId == request.auth.uid);
      
      match /reviews/{reviewId} {
        allow read: if true;
        allow create: if isSignedIn();
        allow update, delete: if isOwner(resource.data.userId) || isAdmin();
      }
    }
    
    // Categories collection
    match /categories/{categoryId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // Orders collection
    match /orders/{orderId} {
      allow read: if isOwner(resource.data.customerId) || 
                    isStaff() || 
                    isAdmin() ||
                    (isSeller() && resource.data.items[0].sellerId == request.auth.uid);
      allow create: if isSignedIn();
      allow update: if isStaff() || isAdmin();
      allow delete: if isAdmin();
    }
    
    // Notifications collection
    match /notifications/{notificationId} {
      allow read: if isOwner(resource.data.userId);
      allow write: if isAdmin() || isStaff();
    }
    
    // Support tickets collection
    match /supportTickets/{ticketId} {
      allow read: if isOwner(resource.data.userId) || isStaff() || isAdmin();
      allow create: if isSignedIn();
      allow update: if isStaff() || isAdmin();
      
      match /messages/{messageId} {
        allow read: if isOwner(get(/databases/$(database)/documents/supportTickets/$(ticketId)).data.userId) || 
                      isStaff() || 
                      isAdmin();
        allow create: if isSignedIn();
      }
    }
    
    // Chat support collection
    match /chatSupport/{chatId} {
      allow read: if isOwner(resource.data.userId) || isStaff() || isAdmin();
      allow create: if isSignedIn();
      allow update: if isStaff() || isAdmin();
      
      match /messages/{messageId} {
        allow read: if isOwner(get(/databases/$(database)/documents/chatSupport/$(chatId)).data.userId) || 
                      isStaff() || 
                      isAdmin();
        allow create: if isSignedIn();
      }
    }
    
    // Delivery routes collection
    match /deliveryRoutes/{routeId} {
      allow read: if isStaff() || isAdmin();
      allow write: if isStaff() || isAdmin();
    }
    
    // FAQ articles collection
    match /faqArticles/{articleId} {
      allow read: if true;
      allow write: if isAdmin();
    }
    
    // System settings collection
    match /systemSettings/{settingId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
    }
    
    // Analytics collection
    match /analytics/{analyticsId} {
      allow read: if isAdmin();
      allow write: if isAdmin() || isStaff();
    }
  }
}
```

---

## Indexes

### Composite Indexes Required

```javascript
// Products
products: [
  { fields: ['category', 'createdAt'], order: 'desc' },
  { fields: ['storeId', 'isActive', 'createdAt'], order: 'desc' },
  { fields: ['isFeatured', 'isActive', 'rating'], order: 'desc' },
  { fields: ['tags', 'isActive', 'createdAt'], order: 'desc' }
]

// Orders
orders: [
  { fields: ['customerId', 'createdAt'], order: 'desc' },
  { fields: ['status', 'createdAt'], order: 'desc' },
  { fields: ['assignedStaffId', 'status', 'createdAt'], order: 'desc' },
  { fields: ['items.sellerId', 'createdAt'], order: 'desc' }
]

// Notifications
notifications: [
  { fields: ['userId', 'isRead', 'createdAt'], order: 'desc' }
]

// Support Tickets
supportTickets: [
  { fields: ['userId', 'status', 'createdAt'], order: 'desc' },
  { fields: ['assignedStaffId', 'status', 'createdAt'], order: 'desc' },
  { fields: ['status', 'priority', 'createdAt'], order: 'desc' }
]

// Delivery Routes
deliveryRoutes: [
  { fields: ['staffId', 'date', 'status'] },
  { fields: ['date', 'status'] }
]
```

---

## Cloud Functions Triggers

### Recommended Cloud Functions

1. **onUserCreate**: Initialize user profile, send welcome email
2. **onOrderCreate**: Send order confirmation, update product stock, create notification
3. **onOrderStatusUpdate**: Send status update notification, update analytics
4. **onProductCreate**: Update category product count, update store product count
5. **onReviewCreate**: Update product rating, send notification to seller
6. **onPaymentSuccess**: Update order payment status, send receipt
7. **calculateOrderTotals**: Calculate subtotal, tax, shipping, total
8. **assignDeliveryStaff**: Auto-assign orders to available delivery personnel
9. **sendDailyReports**: Generate and send daily sales reports
10. **cleanupOldNotifications**: Delete read notifications older than 30 days

---

## Best Practices

1. **Use Transactions** for operations that update multiple documents (e.g., order creation)
2. **Batch Writes** for bulk operations (e.g., updating multiple product stocks)
3. **Pagination** for large collections (use `startAfter` with limits)
4. **Denormalization** for frequently accessed data (e.g., store userName in orders)
5. **Subcollections** for one-to-many relationships (e.g., user addresses)
6. **Timestamps** use `FieldValue.serverTimestamp()` for consistency
7. **Soft Deletes** use `isActive` or `deletedAt` instead of actual deletion
8. **Caching** implement local caching for frequently accessed data
9. **Security** never trust client-side data, validate in security rules and cloud functions
10. **Monitoring** set up Firebase Performance Monitoring and Analytics

---

## Migration Strategy

1. Start with core collections: users, products, categories
2. Add e-commerce functionality: orders, cart, wishlist
3. Implement support features: tickets, chat, notifications
4. Add analytics and reporting
5. Optimize with indexes and caching
6. Set up cloud functions for automation
7. Implement security rules
8. Test thoroughly before production deployment

---

## Notes

- All timestamps should use Firebase server timestamp
- All IDs are auto-generated by Firestore unless specified
- Currency is UGX (Ugandan Shilling) by default
- All prices are stored as numbers (not strings)
- Images are stored as URLs (use Firebase Storage)
- Use Firebase Authentication for user management
- Implement offline persistence for better UX
- Use Firebase Cloud Messaging for push notifications

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Author:** Campus Cart Development Team
