import 'package:flutter/material.dart';

/// Тот же HSL-хеш, что у букв-аватаров в чате (`_LetterAvatar`).
Color accentColorFromStableId(String id) {
  var hash = 0;
  for (final u in id.codeUnits) {
    hash = u + ((hash << 5) - hash);
  }
  final hue = hash.abs() % 360;
  return HSLColor.fromAHSL(1, hue.toDouble(), 0.55, 0.5).toColor();
}
