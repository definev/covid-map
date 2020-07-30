import 'package:flutter/material.dart';

class AppColors {
  static Color blue = Color(0xFF2B9EB3);
  static Color black = Color(0xFF0A0903);
  static Color red = Color(0xFFFF0000);
  static Color green = Color(0xFF44AF69);
  static Color yellow = Color(0xFFFFC100);
}

extension NumFormat on int {
  String get format {
    String process = this.toString();
    String raw = "";
    for (int i = process.length - 1; i >= 0; i--) {
      if ((process.length - i) % 3 == 0 && i != 0) {
        raw += "${process[i]}.";
      } else {
        raw += process[i];
      }
    }

    String res = "";
    for (int i = raw.length - 1; i >= 0; i--) res += raw[i];

    return res;
  }
}
