import 'dart:math';

class KeyGenerator {
  static const String _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  static final Random _random = Random();

  /// Generate key dengan format TOPSIS-XXXXXX (6 karakter alphanumeric)
  static String generate({int length = 6}) {
    final code = List.generate(
      length,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
    return 'TOPSIS-$code';
  }

  /// Validasi format key (TOPSIS-XXXXXX)
  static bool isValidKey(String key) {
    final regex = RegExp(r'^TOPSIS-[A-Z0-9]{6}$');
    return regex.hasMatch(key);
  }
}
