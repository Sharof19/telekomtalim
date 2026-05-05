import 'package:flutter/material.dart';

class OtpIntroSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;
  final Color subtitleColor;

  const OtpIntroSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.titleColor,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: TextStyle(fontSize: 13, color: subtitleColor)),
      ],
    );
  }
}
