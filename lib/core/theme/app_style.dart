import 'package:flutter/material.dart';
import 'package:uztelecom/core/theme/app_colors.dart';

abstract class AppStyle {
  static TextStyle fontstyle = TextStyle(
    inherit: false,
    fontSize: 30,
    letterSpacing: 1,
    color: AppColors.brandBlue,
    fontFamily: 'Nexa',
  );
}
