import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_palette.dart';

class ProfileInfoFieldBox extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final int? maxLength;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ProfileInfoPalette palette;
  final ValueChanged<String>? onChanged;

  const ProfileInfoFieldBox({
    super.key,
    required this.controller,
    required this.enabled,
    required this.palette,
    this.maxLength,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(
        color: palette.value,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: palette.input,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        border: _border(palette.border),
        enabledBorder: _border(palette.border),
        disabledBorder: _border(palette.border),
        focusedBorder: _border(palette.borderFocused, width: 1.5),
      ),
      onChanged: onChanged,
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
