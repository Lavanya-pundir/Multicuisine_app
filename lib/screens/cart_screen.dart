import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({super.key, required this.cartItems});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get netTotal {
    return widget.cartItems.fold<double>(
      0.0,
          (sum, item) {
        final itemPrice = (item['item_price'] as num?) ?? 0;
        final itemQty = (item['item_quantity'] as num?) ?? 0;
        return sum + (itemPrice * itemQty).toDouble();
      },
    );
  }

  int get totalItems {
    return widget.cartItems.fold<int>(
      0,
          (sum, item) => sum + (item['item_quantity'] as num).toInt(),
    );
  }

  double get tax => netTotal * 0.05;
  double get grandTotal => netTotal + tax;

  Future<void> placeOrder() async {
    final int totalAmount = widget.cartItems.fold<int>(
      0,
          (sum, item) {
        final price = (item['item price'] as num?) ?? 0;
        final qty = (item['item_quantity'] as num?) ?? 0;
        return sum + price.toInt() * qty.toInt();
      },
    );

    try {
      final response = await ApiService.makePayment(
        totalAmount.toDouble(),
        totalItems,
        widget.cartItems.map((item) {
          return {
            'cuisine_id': item['cuisine_id'],
            'item_id': item['item_id'],
            'item price': (item['item_price'] as num?)?.toInt() ?? 0,
            'item_quantity': (item['item_quantity'] as num?)?.toInt() ?? 0,
          };
        }).toList(),
      );

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Thank You! 😊"),
            content: const Text("Your order has been placed successfully."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Payment Error"),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Cart"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.cartItems.length,
                itemBuilder: (context, index) {
                  final item = widget.cartItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: Image.network(
                        item['item_image_url'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(item['item_name']),
                      subtitle: Text("₹${item['item_price']} x ${item['item_quantity']}"),
                      trailing: Text(
                        "₹${item['item_price'] * item['item_quantity']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Net Total"),
                Text("₹${netTotal.toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("CGST (2.5%)"),
                Text("₹${(netTotal * 0.025).toStringAsFixed(2)}"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("SGST (2.5%)"),
                Text("₹${(netTotal * 0.025).toStringAsFixed(2)}"),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Grand Total",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "₹${grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text("Place Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
