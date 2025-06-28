import 'dish.dart';

class Cuisine {
  final String cuisineId;
  final String cuisineName;
  final String cuisineImageUrl;
  final List<Dish> items;

  Cuisine({
    required this.cuisineId,
    required this.cuisineName,
    required this.cuisineImageUrl,
    required this.items,
  });

  factory Cuisine.fromJson(Map<String, dynamic> json) {
    var dishes = (json['items'] as List)
        .map((item) => Dish.fromJson(item))
        .toList();

    return Cuisine(
      cuisineId: json['cuisine_id'],
      cuisineName: json['cuisine_name'],
      cuisineImageUrl: json['cuisine_image_url'],
      items: dishes,
    );
  }
}

