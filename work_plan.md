# Work Plan — Order Flow + Chat + Seller Request

## ✅ Task 1: Fix Order Flow Gaps (COMPLETED)
- [x] Update `order_model.dart` — fix statuses, remove legacy fields
- [x] Fix acceptance notification in `order_service.dart` to include seller name + phone
- [x] Fix `checkout_screen.dart` dead code warning
- [x] Fix `cart_screen.dart` unused import warning
- [x] Add global contact privacy toggle to `edit_profile_screen.dart` + `user_provider.dart`
- [x] Add "Follow-up" button to customer `order_details_screen.dart`
- [x] Add `enableFollowUp` method to `order_provider.dart`

## ✅ Task 2: Order-Specific Chat Integration (COMPLETED)
- [x] Created reusable `OrderChatSection` widget in `lib/widgets/common/order_chat_section.dart`
- [x] Integrated chat into customer `order_details_screen.dart`
- [x] Integrated chat into seller `seller_order_details_screen.dart`
- [x] Chat read-only when order is rejected/cancelled/completed (without follow-up)
- [x] Mark as Complete buttons inside chat section for both roles
- [x] Show confirmation status chips ("Seller confirmed", "Customer confirmed")
- [x] Customer Follow-up button inside chat on completed orders
- [x] Real-time Firestore message streaming via chat provider

## ⏳ Task 3: Seller Request Flow (NEXT)
- [ ] Update `sign_up_screen.dart` with Customer/Seller role selection
- [ ] Create seller request service/repository
- [ ] Admin dashboard: pending seller requests with approve/reject
- [ ] On approve: change user role customer → seller
- [ ] On reject: send notification with reason

---

## ✅ flutter analyze: 62 issues (all info-level in scripts/ only) — 0 errors, 0 warnings
## ✅ Files Created:
  - `lib/widgets/common/order_chat_section.dart` — Reusable embedded chat for order details
## ✅ Files Modified:
  - `lib/pages/customer/order_details_screen.dart` — Imported + embedded OrderChatSection
  - `lib/pages/seller/seller_order_details_screen.dart` — Imported + embedded OrderChatSection