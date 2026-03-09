import 'package:flutter/material.dart';
import 'package:uztelecom/ui/theme/home_palette.dart';

abstract class AppStyle {
  static TextStyle fontstyle = TextStyle(
    inherit: false,
    fontSize: 30,
    letterSpacing: 1,
    color: HomePalette.primary,
    fontFamily: 'Nexa',
  );
}
