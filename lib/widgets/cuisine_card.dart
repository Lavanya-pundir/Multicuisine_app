import 'package:flutter/material.dart';
import '../models/cuisine.dart';

class CuisineCard extends StatelessWidget {
  final Cuisine cuisine;
  final VoidCallback onTap;

  const CuisineCard({required this.cuisine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(cuisine.cuisineImageUrl, width: 60, height: 60, fit: BoxFit.cover),
      title: Text(cuisine.cuisineName),
      trailing: Icon(Icons.arrow_forward),
      onTap: onTap,
    );
  }
}
