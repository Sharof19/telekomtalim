import 'package:flutter/material.dart';
import 'package:uztelecom/core/config/app_assets.dart';

class LoginIntroSection extends StatelessWidget {
  final bool isKeyboardOpen;
  final String title;
  final Color titleColor;

  const LoginIntroSection({
    super.key,
    required this.isKeyboardOpen,
    required this.title,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isKeyboardOpen)
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                AppAssets.uztelecomLoginLogo,
                width: 220,
                height: 34,
                cacheWidth: 660,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        SizedBox(height: isKeyboardOpen ? 4 : 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        SizedBox(height: isKeyboardOpen ? 2 : 6),
        SizedBox(height: isKeyboardOpen ? 10 : 24),
      ],
    );
  }
}
