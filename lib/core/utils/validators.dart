class Validators {
  /// Validasi field wajib diisi
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  /// Validasi angka
  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }

    final number = double.tryParse(value);
    if (number == null || number < 0) {
      return '$fieldName harus berupa angka yang valid';
    }

    return null;
  }
}
