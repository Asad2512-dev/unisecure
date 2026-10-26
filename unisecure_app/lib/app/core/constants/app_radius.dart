import 'package:flutter/material.dart';

/// Centralized border radii for cards, buttons, inputs, chips, and sheets.
class AppRadius {
  AppRadius._();

  static const double none = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double field = 14.0;
  static const double button = 14.0;
  static const double card = 18.0;
  static const double sheet = 24.0;
  static const double dialog = 20.0;
  static const double full = 999.0;

  // BorderRadius instances
  static final BorderRadius cardRadius = BorderRadius.circular(card);
  static final BorderRadius buttonRadius = BorderRadius.circular(button);
  static final BorderRadius fieldRadius = BorderRadius.circular(field);
  static final BorderRadius chipRadius = BorderRadius.circular(full);
  static final BorderRadius mdRadius = BorderRadius.circular(md);
  static final BorderRadius sheetRadius = const BorderRadius.vertical(
    top: Radius.circular(sheet),
  );
}

/// Backward compatibility for existing references
class AppRadii {
  AppRadii._();
  static const double card = AppRadius.card;
  static const double field = AppRadius.field;
  static const double button = AppRadius.button;
}
