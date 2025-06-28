import 'package:flutter/material.dart';
import '../models/dish.dart';

class DishTile extends StatelessWidget {
  final Dish dish;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const DishTile({
    required this.dish,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(dish.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
      title: Text(dish.name),
      subtitle: Text("Rs. ${dish.price}"),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(onPressed: onRemove, icon: Icon(Icons.remove)),
          Text('$quantity'),
          IconButton(onPressed: onAdd, icon: Icon(Icons.add)),
        ],
      ),
    );
  }
}
