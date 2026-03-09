String? normalizeIndianPhone(String input) {
  final digits = input.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return null;
  }

  if (digits.length == 10) {
    return '+91$digits';
  }

  if (digits.length == 11 && digits.startsWith('0')) {
    return '+91${digits.substring(1)}';
  }

  if (digits.length == 12 && digits.startsWith('91')) {
    return '+$digits';
  }

  return null;
}
