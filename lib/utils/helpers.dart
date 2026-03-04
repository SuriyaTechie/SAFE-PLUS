class Helpers {
  // Safely parse a double from text input.
  static double toDouble(String value, {double fallback = 0}) {
    return double.tryParse(value) ?? fallback;
  }
}
