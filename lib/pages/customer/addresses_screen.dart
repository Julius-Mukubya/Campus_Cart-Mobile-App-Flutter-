import 'package:flutter/material.dart';

/// This screen has been deprecated — delivery addresses are not used in Campus Cart.
class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Addresses')),
      body: const Center(child: Text('Addresses not available')),
    );
  }
}
