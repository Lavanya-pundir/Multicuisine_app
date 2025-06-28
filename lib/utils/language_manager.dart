class LanguageManager {
  static bool isHindi = false;

  static String translate(String key) {
    final Map<String, String> en = {
      'cart': 'Cart',
      'order_now': 'Order Now',
      'total': 'Total',
    };

    final Map<String, String> hi = {
      'cart': 'कार्ट',
      'order_now': 'ऑर्डर करें',
      'total': 'कुल',
    };

    return isHindi ? hi[key] ?? key : en[key] ?? key;
  }

  static void toggleLanguage() {
    isHindi = !isHindi;
  }
}
