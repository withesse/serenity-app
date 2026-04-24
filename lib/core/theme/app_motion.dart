import 'package:flutter/animation.dart';

/// Motion tokens. Mirrors MASTER.md §8.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration interactive = Duration(milliseconds: 200);
  static const Duration pageTransition = Duration(milliseconds: 400);
  static const Duration modal = Duration(milliseconds: 320);
  static const Duration breathing = Duration(milliseconds: 4000);
  static const Duration auroraDrift = Duration(milliseconds: 12000);

  // Curves
  static const Curve interactiveCurve = Curves.easeOutCubic;
  static const Curve pageCurve = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve modalCurve = Curves.easeOutExpo;
  static const Curve breathingCurve = Curves.easeInOutSine;
}
