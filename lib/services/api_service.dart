import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://uat.onebanc.ai";
  static const String apiKey = "uonebancservceemultrS3cg8RaL30";

  /// GET LIST OF ALL CUISINES & ITEMS
  static Future<Map<String, dynamic>> getItemList(
      {int page = 1, int count = 10}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/emulator/interview/get_item_list"),
      headers: {
        'X-Partner-API-Key': apiKey,
        'X-Forward-Proxy-Action': 'get_item_list',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "page": page,
        "count": count,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to load items list");
    }
  }

  /// GET ITEM DETAILS BY ID
  static Future<Map<String, dynamic>> getItemById(String itemId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/emulator/interview/get_item_by_id"),
      headers: {
        'X-Partner-API-Key': apiKey,
        'X-Forward-Proxy-Action': 'get_item_by_id',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "item_id": itemId,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch item by ID");
    }
  }

  /// FILTER ITEMS BY CUISINE, PRICE RANGE, RATING
  static Future<Map<String, dynamic>> getItemsByFilter({
    List<String>? cuisineType,
    Map<String, int>? priceRange,
    double? minRating,
  }) async {
    final Map<String, dynamic> body = {};

    if (cuisineType != null) {
      body['cuisine_type'] = cuisineType;
    }
    if (priceRange != null) {
      body['price_range'] = priceRange;
    }
    if (minRating != null) {
      body['min_rating'] = minRating;
    }

    final response = await http.post(
      Uri.parse("$baseUrl/emulator/interview/get_item_by_filter"),
      headers: {
        'X-Partner-API-Key': 'uonebancservceemultrS3cg8RaL30',
        'X-Forward-Proxy-Action': 'get_item_by_filter',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch filtered items");
    }
  }

  /// MAKE PAYMENT FOR ORDER
  static Future<Map<String, dynamic>> makePayment(double totalAmount,
      int totalItems,
      List<Map<String, dynamic>> data,) async {
    final url = Uri.parse("$baseUrl/emulator/interview/make_payment");

    final requestBody = {
      'total_amount': totalAmount.round().toInt(),
      'total_items': totalItems,
      'data': data,
    };

    print("📤 Sending Payment Request:");
    print("➡ URL: $url");
    print("➡ Body: ${jsonEncode(requestBody)}");
    print("➡ Data Payload Check: $data");
    final response = await http.post(
      url,
      headers: {
        'X-Partner-API-Key': apiKey,
        'X-Forward-Proxy-Action': 'make_payment',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("📥 Response Code: ${response.statusCode}");
    print("📥 Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['outcome_code'] == 200) {
        return decoded;
      } else {
        throw Exception("❌ Payment failed: ${decoded['response_message']}");
      }
    } else {
      throw Exception(
          "❌ Server error: ${response.statusCode}\n${response.body}");
    }
  }
}