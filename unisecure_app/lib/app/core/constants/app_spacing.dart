import 'package:flutter/material.dart';

/// Centralized spacing scale and layout metrics for UniSecure.
class AppSpacing {
  AppSpacing._();

  // Numeric scale
  static const double none = 0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 40.0;

  // Vertical Gaps
  static const SizedBox vGap2 = SizedBox(height: 2.0);
  static const SizedBox vGap4 = SizedBox(height: xxs);
  static const SizedBox vGap6 = SizedBox(height: 6.0);
  static const SizedBox vGap8 = SizedBox(height: xs);
  static const SizedBox vGap10 = SizedBox(height: 10.0);
  static const SizedBox vGap12 = SizedBox(height: sm);
  static const SizedBox vGap16 = SizedBox(height: md);
  static const SizedBox vGap20 = SizedBox(height: lg);
  static const SizedBox vGap24 = SizedBox(height: xl);
  static const SizedBox vGap32 = SizedBox(height: xxl);
  static const SizedBox vGap40 = SizedBox(height: xxxl);

  // Horizontal Gaps
  static const SizedBox hGap2 = SizedBox(width: 2.0);
  static const SizedBox hGap4 = SizedBox(width: xxs);
  static const SizedBox hGap6 = SizedBox(width: 6.0);
  static const SizedBox hGap8 = SizedBox(width: xs);
  static const SizedBox hGap10 = SizedBox(width: 10.0);
  static const SizedBox hGap12 = SizedBox(width: sm);
  static const SizedBox hGap14 = SizedBox(width: 14.0);
  static const SizedBox hGap16 = SizedBox(width: md);
  static const SizedBox hGap20 = SizedBox(width: lg);
  static const SizedBox hGap24 = SizedBox(width: xl);
  static const SizedBox hGap32 = SizedBox(width: xxl);

  // Insets Presets
  static const EdgeInsets screen = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 18,
  );
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: 20,
  );
  static const EdgeInsets card = EdgeInsets.all(18);
  static const EdgeInsets cardCompact = EdgeInsets.all(14);
  static const EdgeInsets sheet = EdgeInsets.all(24);
  static const EdgeInsets dialog = EdgeInsets.all(24);
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const EdgeInsets input = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 16,
  );

  // Legacy backwards-compatible aliases
  static const SizedBox small = vGap8;
  static const SizedBox item = vGap12;
  static const SizedBox section = vGap24;
}
