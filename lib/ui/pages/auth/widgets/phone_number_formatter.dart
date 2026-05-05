import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  const PhoneNumberFormatter({required this.maxDigits});

  final int maxDigits;

  static const List<int> _groups = [2, 3, 2, 2];

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digitsOnly.length > maxDigits
        ? digitsOnly.substring(0, maxDigits)
        : digitsOnly;
    final formatted = _formatGroups(limited);
    final digitsBeforeCursor = _countDigits(
      newValue.text.substring(0, newValue.selection.end),
    );
    final selectionIndex = _selectionIndex(formatted, digitsBeforeCursor);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionIndex),
      composing: TextRange.empty,
    );
  }

  String _formatGroups(String digits) {
    final buffer = StringBuffer();
    var index = 0;
    for (final size in _groups) {
      if (index >= digits.length) break;
      final end = (index + size).clamp(0, digits.length);
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(digits.substring(index, end));
      index = end;
    }
    if (index < digits.length) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(digits.substring(index));
    }
    return buffer.toString();
  }

  int _countDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '').length;
  }

  int _selectionIndex(String formatted, int digitsBeforeCursor) {
    if (digitsBeforeCursor <= 0) return 0;
    var digitsSeen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (RegExp(r'\d').hasMatch(formatted[i])) {
        digitsSeen++;
        if (digitsSeen == digitsBeforeCursor) {
          return i + 1;
        }
      }
    }
    return formatted.length;
  }
}
