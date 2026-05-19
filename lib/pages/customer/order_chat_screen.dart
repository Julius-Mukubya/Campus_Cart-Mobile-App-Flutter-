import 'package:flutter/material.dart';

/// This screen has been deprecated — chat is now integrated directly in order details.
class OrderChatScreen extends StatelessWidget {
  final String orderId;
  final String sellerId;

  const OrderChatScreen({
    super.key,
    required this.orderId,
    required this.sellerId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Chat')),
      body: const Center(child: Text('Chat will be available in order details')),
    );
  }
}
