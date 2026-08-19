class Validators {
  Validators._();

  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? positiveNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    final n = num.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n <= 0) return '$field must be greater than zero';
    return null;
  }

  static String? nonNegativeNumber(String? value, {String field = 'Value'}) {
    if (value == null || value.trim().isEmpty) return null;
    final n = num.tryParse(value);
    if (n == null) return 'Enter a valid number';
    if (n < 0) return '$field must be ≥ 0';
    return null;
  }
}