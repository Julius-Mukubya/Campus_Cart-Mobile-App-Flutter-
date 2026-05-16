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
  "staffType": "string (enum: pickup_delivery, final_delivery, support, coordinator) - only for staff role",
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
  
  "status": "string (enum: pending, vendor_approved, vendor_rejected, assigned_for_pickup, picked_up, at_hq, packaged, assigned_for_delivery, out_for_delivery, delivered, cancelled, returned)",
  "statusHistory": "array of maps [
    {
      status: string,
      timestamp: timestamp,
      note: string,
      updatedBy: string (userId),
      qrCodeUsed: boolean (optional)
    }
  ]",
  
  // Vendor approval
  "vendorApprovalStatus": "string (enum: pending, approved, rejected)",
  "vendorApprovedAt": "timestamp (optional)",
  "vendorApprovedBy": "string (userId, optional)",
  "vendorRejectionReason": "string (optional)",
  
  // Pickup tracking
  "pickupStaffId": "string (reference to users collection, for pickup delivery)",
  "pickupStaffName": "string",
  "assignedForPickupAt": "timestamp (optional)",
  "pickedUpAt": "timestamp (optional)",
  "pickupQrCode": "string (unique QR code for vendor confirmation)",
  "pickupConfirmedByVendor": "boolean",
  "pickupConfirmedAt": "timestamp (optional)",
  
  // HQ and packaging
  "arrivedAtHqAt": "timestamp (optional)",
  "packagedAt": "timestamp (optional)",
  "packagedBy": "string (userId, optional)",
  "hqLocation": "string (HQ location identifier)",
  
  // Final delivery tracking
  "finalDeliveryStaffId": "string (reference to users collection, for final delivery)",
  "finalDeliveryStaffName": "string",
  "assignedForDeliveryAt": "timestamp (optional)",
  "deliveryQrCode": "string (unique QR code for customer confirmation)",
  "deliveryConfirmedByCustomer": "boolean",
  
  "assignedStaffId": "string (reference to users collection, for delivery) - DEPRECATED, use finalDeliveryStaffId",
  "assignedStaffName": "string - DEPRECATED, use finalDeliveryStaffName",
  "estimatedDeliveryDate": "timestamp",
  "actualDeliveryDate": "timestamp (optional)",
  
  "notes": "string (customer notes)",
  "internalNotes": "string (staff/admin notes)",
  
  // Bulk order management
  "batchId": "string (reference to orderBatches collection, optional)",
  "scheduledDeliveryDate": "timestamp (for next-day delivery scheduling)",
  
  "requiresDualConfirmation": "boolean (true for QR-based confirmations)",
  "customerConfirmed": "boolean",
  "staffConfirmed": "boolean - DEPRECATED",
  "confirmationCode": "string (6-digit code) - DEPRECATED, use QR codes",
  
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

### 13. Order Batches Collection
**Path:** `/orderBatches/{batchId}`

For managing bulk order assignments and next-day delivery scheduling.

```json
{
  "batchId": "string (auto-generated)",
  "batchNumber": "string (unique, e.g., BATCH-2024-001234)",
  "type": "string (enum: pickup, delivery)",
  "status": "string (enum: pending, assigned, in_progress, completed, cancelled)",
  "createdDate": "timestamp",
  "scheduledDate": "timestamp (for next-day delivery)",
  
  // For pickup batches
  "pickupStaffId": "string (reference to users collection, optional)",
  "pickupStaffName": "string (optional)",
  
  // For delivery batches
  "deliveryStaffId": "string (reference to users collection, optional)",
  "deliveryStaffName": "string (optional)",
  
  "orderIds": "array of strings (references to orders collection)",
  "totalOrders": "number",
  "completedOrders": "number",
  
  // Location tracking
  "hqLocation": "string (HQ location identifier)",
  "region": "string (delivery region/zone)",
  
  "assignedAt": "timestamp (optional)",
  "assignedBy": "string (userId, coordinator who assigned)",
  "startedAt": "timestamp (optional)",
  "completedAt": "timestamp (optional)",
  
  "notes": "string (optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

---

### 14. QR Confirmations Collection
**Path:** `/qrConfirmations/{confirmationId}`

For tracking QR code scans and confirmations.

```json
{
  "confirmationId": "string (auto-generated)",
  "orderId": "string (reference to orders collection)",
  "qrCode": "string (the QR code that was scanned)",
  "type": "string (enum: pickup, delivery)",
  
  // Pickup confirmation
  "vendorId": "string (reference to users collection, for pickup)",
  "pickupStaffId": "string (reference to users collection, for pickup)",
  
  // Delivery confirmation
  "customerId": "string (reference to users collection, for delivery)",
  "deliveryStaffId": "string (reference to users collection, for delivery)",
  
  "confirmedBy": "string (userId who scanned the QR)",
  "confirmedByRole": "string (enum: vendor, customer, staff)",
  "confirmedAt": "timestamp",
  
  "location": "map (optional) {
    latitude: number,
    longitude: number,
    address: string
  }",
  
  "deviceInfo": "map (optional) {
    deviceId: string,
    platform: string,
    appVersion: string
  }",
  
  "isValid": "boolean (true if QR code matched)",
  "failureReason": "string (optional, if scan failed)",
  
  "createdAt": "timestamp"
}
```

---

### 15. HQ Locations Collection
**Path:** `/hqLocations/{locationId}`

For managing headquarters and packaging centers.

```json
{
  "locationId": "string (auto-generated)",
  "name": "string (e.g., Main HQ, North Campus Hub)",
  "code": "string (unique location code)",
  "address": "map {
    addressLine1: string,
    addressLine2: string,
    city: string,
    state: string,
    postalCode: string,
    latitude: number,
    longitude: number
  }",
  "type": "string (enum: main_hq, regional_hub, packaging_center)",
  "capacity": "number (max orders per day)",
  "currentLoad": "number (current orders being processed)",
  "operatingHours": "map {
    openTime: string (e.g., 08:00),
    closeTime: string (e.g., 18:00),
    workingDays: array of strings (e.g., [Mon, Tue, Wed, Thu, Fri])
  }",
  "contactPerson": "string",
  "contactPhone": "string",
  "isActive": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
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
    
    // Order batches collection
    match /orderBatches/{batchId} {
      allow read: if isStaff() || isAdmin();
      allow create, update: if isStaff() || isAdmin();
      allow delete: if isAdmin();
    }
    
    // QR confirmations collection
    match /qrConfirmations/{confirmationId} {
      allow read: if isStaff() || isAdmin() || isOwner(resource.data.confirmedBy);
      allow create: if isSignedIn();
      allow update, delete: if isAdmin();
    }
    
    // HQ locations collection
    match /hqLocations/{locationId} {
      allow read: if isSignedIn();
      allow write: if isAdmin();
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
  { fields: ['vendorApprovalStatus', 'createdAt'], order: 'desc' },
  { fields: ['pickupStaffId', 'status', 'createdAt'], order: 'desc' },
  { fields: ['finalDeliveryStaffId', 'status', 'createdAt'], order: 'desc' },
  { fields: ['items.sellerId', 'vendorApprovalStatus', 'createdAt'], order: 'desc' },
  { fields: ['batchId', 'status'], order: 'desc' },
  { fields: ['scheduledDeliveryDate', 'status'], order: 'asc' },
  { fields: ['status', 'vendorApprovedAt'], order: 'desc' }
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

// Order Batches
orderBatches: [
  { fields: ['type', 'status', 'createdDate'], order: 'desc' },
  { fields: ['scheduledDate', 'status'], order: 'asc' },
  { fields: ['pickupStaffId', 'status', 'scheduledDate'] },
  { fields: ['deliveryStaffId', 'status', 'scheduledDate'] },
  { fields: ['region', 'scheduledDate', 'status'] }
]

// QR Confirmations
qrConfirmations: [
  { fields: ['orderId', 'type', 'confirmedAt'], order: 'desc' },
  { fields: ['confirmedBy', 'confirmedAt'], order: 'desc' },
  { fields: ['type', 'confirmedAt'], order: 'desc' }
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

## Additional Collections for Enhanced Functionality

### 13. Promotions Collection
**Path:** `/promotions/{promotionId}`

For managing discounts, coupons, and promotional campaigns.

```json
{
  "promotionId": "string (auto-generated)",
  "code": "string (unique coupon code, optional)",
  "title": "string (required)",
  "description": "string",
  "type": "string (enum: percentage, fixed_amount, free_shipping, buy_x_get_y)",
  "value": "number (discount percentage or fixed amount)",
  "minimumOrderAmount": "number (optional)",
  "maximumDiscountAmount": "number (optional, for percentage discounts)",
  "applicableProducts": "array of strings (productIds, empty = all products)",
  "applicableCategories": "array of strings (categoryIds, empty = all categories)",
  "applicableStores": "array of strings (storeIds, empty = all stores)",
  "usageLimit": "number (total usage limit, optional)",
  "usageLimitPerUser": "number (per user limit, optional)",
  "currentUsage": "number (default: 0)",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "isActive": "boolean",
  "createdBy": "string (userId)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### 14. Inventory Tracking Collection
**Path:** `/inventory/{inventoryId}`

For detailed stock management and tracking.

```json
{
  "inventoryId": "string (auto-generated)",
  "productId": "string (reference to products collection)",
  "storeId": "string (reference to stores collection)",
  "type": "string (enum: stock_in, stock_out, adjustment, return)",
  "quantity": "number (positive for in, negative for out)",
  "previousStock": "number",
  "newStock": "number",
  "reason": "string (enum: purchase, sale, return, damaged, expired, adjustment)",
  "orderId": "string (reference to orders collection, optional)",
  "notes": "string (optional)",
  "performedBy": "string (userId)",
  "createdAt": "timestamp"
}
```

### 15. Return Requests Collection
**Path:** `/returnRequests/{returnId}`

For handling product returns and refunds.

```json
{
  "returnId": "string (auto-generated)",
  "returnNumber": "string (unique, e.g., RET-2024-001234)",
  "orderId": "string (reference to orders collection)",
  "customerId": "string (reference to users collection)",
  "items": "array of maps [
    {
      productId: string,
      productName: string,
      quantity: number,
      reason: string,
      condition: string (enum: unopened, opened, damaged)
    }
  ]",
  "reason": "string (enum: defective, wrong_item, not_as_described, changed_mind, damaged_in_shipping)",
  "description": "string",
  "images": "array of strings (URLs, proof images)",
  "refundAmount": "number",
  "refundMethod": "string (enum: original_payment, store_credit, bank_transfer)",
  "status": "string (enum: requested, approved, rejected, processing, completed)",
  "approvedBy": "string (userId, optional)",
  "processedBy": "string (userId, optional)",
  "requestedAt": "timestamp",
  "approvedAt": "timestamp (optional)",
  "completedAt": "timestamp (optional)"
}
```

### 16. Vendor Applications Collection
**Path:** `/vendorApplications/{applicationId}`

For managing seller registration requests.

```json
{
  "applicationId": "string (auto-generated)",
  "applicantId": "string (reference to users collection)",
  "businessName": "string",
  "businessType": "string (enum: individual, company, partnership)",
  "businessRegistrationNumber": "string (optional)",
  "taxId": "string (optional)",
  "contactPerson": "string",
  "email": "string",
  "phone": "string",
  "address": "map {
    addressLine1: string,
    addressLine2: string,
    city: string,
    state: string,
    postalCode: string
  }",
  "documents": "map {
    businessLicense: string (URL),
    taxCertificate: string (URL),
    bankStatement: string (URL),
    identityDocument: string (URL)
  }",
  "productCategories": "array of strings (intended categories)",
  "estimatedMonthlyVolume": "number",
  "status": "string (enum: pending, under_review, approved, rejected, requires_documents)",
  "reviewNotes": "string (admin notes)",
  "reviewedBy": "string (userId, optional)",
  "submittedAt": "timestamp",
  "reviewedAt": "timestamp (optional)"
}
```

---

## Enhanced Security Rules

### Additional Security Functions

```javascript
// Enhanced security rules with more granular permissions
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Enhanced helper functions
    function isSignedIn() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function hasRole(role) {
      return isSignedIn() && getUserData().role == role;
    }
    
    function isAdmin() {
      return hasRole('admin');
    }
    
    function isStaff() {
      return hasRole('staff') || isAdmin();
    }
    
    function isSeller() {
      return hasRole('seller');
    }
    
    function isCustomer() {
      return hasRole('customer');
    }
    
    function isStoreOwner(storeId) {
      return isSeller() && getUserData().storeId == storeId;
    }
    
    function isOrderParticipant(orderData) {
      return isOwner(orderData.customerId) || 
             isStoreOwner(orderData.items[0].storeId) ||
             isStaff();
    }
    
    // Promotions collection
    match /promotions/{promotionId} {
      allow read: if true; // Public read for active promotions
      allow create, update: if isAdmin() || isSeller();
      allow delete: if isAdmin();
    }
    
    // Inventory tracking collection
    match /inventory/{inventoryId} {
      allow read: if isStoreOwner(resource.data.storeId) || isStaff();
      allow create: if isStoreOwner(request.resource.data.storeId) || isStaff();
      allow update, delete: if isAdmin();
    }
    
    // Return requests collection
    match /returnRequests/{returnId} {
      allow read: if isOwner(resource.data.customerId) || isStaff();
      allow create: if isCustomer();
      allow update: if isStaff();
      allow delete: if isAdmin();
    }
    
    // Vendor applications collection
    match /vendorApplications/{applicationId} {
      allow read: if isOwner(resource.data.applicantId) || isStaff();
      allow create: if isSignedIn();
      allow update: if isStaff();
      allow delete: if isAdmin();
    }
  }
}
```

---

## Performance Optimization Strategies

### 1. Data Denormalization Examples

```javascript
// In orders collection, denormalize frequently accessed data
{
  "orderId": "order123",
  "customerId": "user123",
  "customerName": "John Doe", // Denormalized from users collection
  "customerEmail": "john@example.com", // Denormalized
  "items": [
    {
      "productId": "prod123",
      "productName": "Campus T-Shirt", // Denormalized from products
      "productImage": "https://...", // Denormalized
      "storeName": "Campus Store", // Denormalized from stores
      "quantity": 2,
      "price": 25000
    }
  ]
}
```

### 2. Aggregation Collections

```javascript
// Daily aggregations for analytics
/aggregations/daily/{date}
{
  "date": "2024-03-05",
  "totalOrders": 150,
  "totalRevenue": 2500000,
  "newUsers": 25,
  "topProducts": [
    { "productId": "prod123", "sales": 50 },
    { "productId": "prod456", "sales": 35 }
  ],
  "topCategories": [
    { "categoryId": "cat123", "sales": 100 },
    { "categoryId": "cat456", "sales": 75 }
  ]
}
```

### 3. Search Optimization

```javascript
// Add search-friendly fields to products
{
  "productId": "prod123",
  "name": "Campus T-Shirt Blue Large",
  "searchKeywords": ["campus", "t-shirt", "blue", "large", "clothing"], // For search
  "searchText": "campus t-shirt blue large clothing apparel", // Lowercase for search
  "category": "clothing",
  "subcategory": "t-shirts"
}
```

---

## Cloud Functions Implementation Examples

### 1. Order Creation Function

```javascript
exports.onOrderCreate = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const order = snap.data();
    const batch = admin.firestore().batch();
    
    try {
      // Update product stock
      for (const item of order.items) {
        const productRef = admin.firestore().doc(`products/${item.productId}`);
        batch.update(productRef, {
          stock: admin.firestore.FieldValue.increment(-item.quantity),
          totalSales: admin.firestore.FieldValue.increment(item.quantity)
        });
        
        // Add inventory tracking
        const inventoryRef = admin.firestore().collection('inventory').doc();
        batch.set(inventoryRef, {
          productId: item.productId,
          storeId: item.storeId,
          type: 'stock_out',
          quantity: -item.quantity,
          reason: 'sale',
          orderId: context.params.orderId,
          performedBy: 'system',
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      }
      
      // Create notification for customer
      const notificationRef = admin.firestore().collection('notifications').doc();
      batch.set(notificationRef, {
        userId: order.customerId,
        type: 'order',
        title: 'Order Confirmed',
        message: `Your order #${order.orderNumber} has been confirmed`,
        data: { orderId: context.params.orderId },
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
      
      await batch.commit();
      
      // Send push notification
      await sendPushNotification(order.customerId, {
        title: 'Order Confirmed',
        body: `Your order #${order.orderNumber} has been confirmed`,
        data: { orderId: context.params.orderId }
      });
      
    } catch (error) {
      console.error('Error processing order creation:', error);
    }
  });
```

### 2. Product Rating Update Function

```javascript
exports.onReviewCreate = functions.firestore
  .document('products/{productId}/reviews/{reviewId}')
  .onCreate(async (snap, context) => {
    const review = snap.data();
    const productId = context.params.productId;
    
    try {
      // Get all reviews for this product
      const reviewsSnapshot = await admin.firestore()
        .collection(`products/${productId}/reviews`)
        .get();
      
      let totalRating = 0;
      let reviewCount = 0;
      
      reviewsSnapshot.forEach(doc => {
        totalRating += doc.data().rating;
        reviewCount++;
      });
      
      const averageRating = totalRating / reviewCount;
      
      // Update product rating
      await admin.firestore().doc(`products/${productId}`).update({
        rating: Math.round(averageRating * 10) / 10, // Round to 1 decimal
        totalReviews: reviewCount
      });
      
    } catch (error) {
      console.error('Error updating product rating:', error);
    }
  });
```

---

## Mobile App Integration Guidelines

### 1. Offline Support Strategy

```dart
// Enable offline persistence
await FirebaseFirestore.instance.enablePersistence();

// Use cached data when offline
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 2. Real-time Updates

```dart
// Listen to order status changes
Stream<DocumentSnapshot> orderStream = FirebaseFirestore.instance
    .collection('orders')
    .doc(orderId)
    .snapshots();

orderStream.listen((snapshot) {
  if (snapshot.exists) {
    final order = snapshot.data() as Map<String, dynamic>;
    // Update UI based on order status
    updateOrderStatus(order['status']);
  }
});
```

### 3. Pagination Implementation

```dart
// Implement pagination for products
Query query = FirebaseFirestore.instance
    .collection('products')
    .where('isActive', isEqualTo: true)
    .orderBy('createdAt', descending: true)
    .limit(20);

// For next page
if (lastDocument != null) {
  query = query.startAfterDocument(lastDocument);
}
```

---

**Document Version:** 1.0  
**Last Updated:** 2024  
**Author:** Campus Cart Development Team


---

## Bulk Order Fulfillment Workflow

### Overview
Campus Cart uses a two-stage delivery system with QR code confirmations for secure order tracking.

### Workflow Stages

#### Stage 1: Order Placement & Vendor Approval
1. **Customer** places order → Status: `pending`
2. **Vendor** reviews order → Updates `vendorApprovalStatus`
   - Approved → Status: `vendor_approved`
   - Rejected → Status: `vendor_rejected`

#### Stage 2: Pickup Assignment (Day 1)
3. **Order Manager (Coordinator)** views approved orders from previous day
   - Filters: `vendorApprovalStatus = 'approved'` AND `vendorApprovedAt = yesterday`
4. **Order Manager** creates pickup batch and assigns to **Pickup Delivery Boy**
   - Creates `orderBatch` document (type: `pickup`)
   - Updates orders: `status = 'assigned_for_pickup'`
   - Sets `pickupStaffId` and generates `pickupQrCode`

#### Stage 3: Vendor Pickup
5. **Pickup Delivery Boy** goes to vendor location
6. **Vendor** scans `pickupQrCode` to confirm pickup
   - Creates `qrConfirmation` document (type: `pickup`)
   - Updates order: `status = 'picked_up'`, `pickedUpAt = timestamp`
   - Updates order: `pickupConfirmedByVendor = true`

#### Stage 4: HQ Processing
7. **Pickup Delivery Boy** delivers to HQ
   - Updates order: `status = 'at_hq'`, `arrivedAtHqAt = timestamp`
8. **HQ Staff** packages orders
   - Updates order: `status = 'packaged'`, `packagedAt = timestamp`

#### Stage 5: Final Delivery Assignment (Day 2)
9. **Order Manager** views packaged orders
   - Filters: `status = 'packaged'` AND `packagedAt = yesterday`
10. **Order Manager** creates delivery batch and assigns to **Delivery Person**
    - Creates `orderBatch` document (type: `delivery`)
    - Updates orders: `status = 'assigned_for_delivery'`
    - Sets `finalDeliveryStaffId`, `scheduledDeliveryDate`, and generates `deliveryQrCode`

#### Stage 6: Customer Delivery
11. **Delivery Person** delivers to customer
    - Updates order: `status = 'out_for_delivery'`
12. **Customer** scans `deliveryQrCode` to confirm delivery
    - Creates `qrConfirmation` document (type: `delivery`)
    - Updates order: `status = 'delivered'`, `actualDeliveryDate = timestamp`
    - Updates order: `deliveryConfirmedByCustomer = true`

### Key Features

#### QR Code System
- **Pickup QR Code**: Generated when order assigned for pickup
  - Scanned by vendor to confirm pickup
  - Validates pickup staff identity
  
- **Delivery QR Code**: Generated when order assigned for delivery
  - Scanned by customer to confirm delivery
  - Validates delivery staff identity

#### Batch Management
- **Pickup Batches**: Group orders by vendor/region for efficient pickup
- **Delivery Batches**: Group orders by delivery zone for next-day delivery
- Tracks batch progress and completion

#### Role Definitions
- **Customer**: Places orders, confirms delivery via QR
- **Vendor/Seller**: Approves orders, confirms pickup via QR
- **Pickup Delivery Boy** (staffType: `pickup_delivery`): Collects from vendors, delivers to HQ
- **Delivery Person** (staffType: `final_delivery`): Delivers from HQ to customers
- **Order Manager/Coordinator** (staffType: `coordinator`): Assigns batches, manages workflow
- **HQ Staff**: Packages orders at headquarters

### Order Status Flow

```
pending
  ↓
vendor_approved (or vendor_rejected)
  ↓
assigned_for_pickup
  ↓
picked_up (QR confirmed by vendor)
  ↓
at_hq
  ↓
packaged
  ↓
assigned_for_delivery
  ↓
out_for_delivery
  ↓
delivered (QR confirmed by customer)
```

### Query Examples

#### Get Yesterday's Approved Orders (for pickup assignment)
```javascript
const yesterday = new Date();
yesterday.setDate(yesterday.getDate() - 1);
yesterday.setHours(0, 0, 0, 0);

const nextDay = new Date(yesterday);
nextDay.setDate(nextDay.getDate() + 1);

const orders = await firestore
  .collection('orders')
  .where('vendorApprovalStatus', '==', 'approved')
  .where('vendorApprovedAt', '>=', yesterday)
  .where('vendorApprovedAt', '<', nextDay)
  .where('status', '==', 'vendor_approved')
  .get();
```

#### Get Packaged Orders (for delivery assignment)
```javascript
const orders = await firestore
  .collection('orders')
  .where('status', '==', 'packaged')
  .orderBy('packagedAt', 'desc')
  .get();
```

#### Get Orders in a Batch
```javascript
const batch = await firestore
  .collection('orderBatches')
  .doc(batchId)
  .get();

const orderIds = batch.data().orderIds;
const orders = await Promise.all(
  orderIds.map(id => firestore.collection('orders').doc(id).get())
);
```

### Cloud Functions for Workflow Automation

#### Recommended Functions

1. **onOrderCreate**: Generate initial QR codes, send notifications
2. **onVendorApproval**: Update status, notify coordinator
3. **onPickupAssignment**: Generate pickup QR, notify pickup staff and vendor
4. **onPickupConfirmation**: Validate QR, update status, notify HQ
5. **onDeliveryAssignment**: Generate delivery QR, notify delivery staff and customer
6. **onDeliveryConfirmation**: Validate QR, update status, complete order
7. **scheduledBatchCreation**: Auto-create batches for next-day delivery
8. **sendDailyPickupReport**: Notify coordinator of pending pickups
9. **sendDailyDeliveryReport**: Notify coordinator of scheduled deliveries

### Security Considerations

1. **QR Code Validation**: Ensure QR codes are unique and time-limited
2. **Role-Based Access**: Only authorized staff can scan QR codes
3. **Location Verification**: Optional GPS validation for confirmations
4. **Audit Trail**: All QR scans logged in `qrConfirmations` collection
5. **Batch Integrity**: Prevent unauthorized batch modifications

---

**Document Version:** 2.0  
**Last Updated:** 2024  
**Author:** Campus Cart Development Team  
**Changelog:**
- v2.0: Added bulk order fulfillment workflow with QR confirmations
- v2.0: Added pickup/delivery staff separation
- v2.0: Added order batches and HQ location tracking
- v2.0: Added QR confirmation system
