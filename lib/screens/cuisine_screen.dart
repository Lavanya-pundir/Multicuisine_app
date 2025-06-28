// cuisine_items_screen.dart
import 'package:flutter/material.dart';
import 'cart_screen.dart';

class CuisineItemsScreen extends StatefulWidget {
  final Map cuisineData;
  final List<Map<String, dynamic>> cartItems;
  final Function(Map dish, Map cuisine) addToCart;
  final Function(String itemId) removeFromCart;

  const CuisineItemsScreen({
    super.key,
    required this.cuisineData,
    required this.cartItems,
    required this.addToCart,
    required this.removeFromCart,
  });

  @override
  State<CuisineItemsScreen> createState() => _CuisineItemsScreenState();
}

class _CuisineItemsScreenState extends State<CuisineItemsScreen> {
  int getItemCount(String itemId) {
    final existingItem = widget.cartItems.firstWhere(
          (item) => item['item_id'] == itemId,
      orElse: () => {},
    );
    return existingItem.isNotEmpty ? existingItem['item_quantity'] : 0;
  }

  @override
  Widget build(BuildContext context) {
    final List items = widget.cuisineData['items'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cuisineData['cuisine_name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final dish = items[index];
            final count = getItemCount(dish['id']);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    dish['image_url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(dish['name']),
                subtitle:
                Text("₹${dish['price']} • ⭐ ${dish['rating']}"),
                trailing: count == 0
                    ? ElevatedButton.icon(
                  onPressed: () {
                    widget.addToCart(dish, widget.cuisineData);
                    setState(() {});
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        widget.removeFromCart(dish['id']);
                        setState(() {});
                      },
                    ),
                    Text('$count'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        widget.addToCart(dish, widget.cuisineData);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: widget.cartItems.isNotEmpty
          ? FloatingActionButton.extended(
        backgroundColor: Colors.deepOrange,
        icon: const Icon(Icons.shopping_cart),
        label: Text("View Cart (${widget.cartItems.length})"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  CartScreen(cartItems: widget.cartItems),
            ),
          );
        },
      )
          : null,
    );
  }
}
