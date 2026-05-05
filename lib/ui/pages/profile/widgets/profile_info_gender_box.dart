import 'package:flutter/material.dart';
import 'package:uztelecom/ui/pages/profile/widgets/profile_info_palette.dart';

class ProfileInfoGenderBox extends StatelessWidget {
  final bool enabled;
  final String value;
  final ValueChanged<String?> onChanged;
  final ProfileInfoPalette palette;

  const ProfileInfoGenderBox({
    super.key,
    required this.enabled,
    required this.value,
    required this.onChanged,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: palette.input,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: palette.border),
    );

    if (!enabled) {
      return Container(
        height: 72,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: decoration,
        child: Text(
          value,
          style: TextStyle(
            color: palette.value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: decoration,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: palette.value,
            size: 30,
          ),
          dropdownColor: palette.input,
          borderRadius: BorderRadius.circular(14),
          style: TextStyle(
            color: palette.value,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            DropdownMenuItem(value: 'Erkak', child: Text('Erkak')),
            DropdownMenuItem(value: 'Ayol', child: Text('Ayol')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
