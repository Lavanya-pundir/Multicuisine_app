class Dish {
  final String id;
  final String name;
  final String imageUrl;
  final String price;
  final String rating;

  Dish({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
  });

  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      price: json['price'],
      rating: json['rating'],
    );
  }
}

