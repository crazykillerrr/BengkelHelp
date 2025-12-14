import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String format(double? amount) {
    if (amount == null) return 'Rp 0';
    return _currencyFormat.format(amount);
  }

  static String formatCompact(double? amount) {
    if (amount == null) return 'Rp 0';

    if (amount >= 1000000000) {
      return "Rp ${(amount / 1000000000).toStringAsFixed(1)}B";
    } else if (amount >= 1000000) {
      return "Rp ${(amount / 1000000).toStringAsFixed(1)}M";
    } else if (amount >= 1000) {
      return "Rp ${(amount / 1000).toStringAsFixed(1)}K";
    }

    return _currencyFormat.format(amount);
  }

  static double parseToDouble(String? text) {
    if (text == null || text.isEmpty) return 0.0;

    final cleaned = text
        .replaceAll("Rp", "")
        .replaceAll(".", "")
        .replaceAll(",", "")
        .trim();

    return double.tryParse(cleaned) ?? 0.0;
  }
}
