import 'package:flutter/widgets.dart';

/// 8pt grid spacing tokens. Mirrors MASTER.md §4.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Screen horizontal padding.
  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: lg);

  // Standard card inset.
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

/// Corner-radius tokens. Mirrors MASTER.md §5.
class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;

  static const BorderRadius smR = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdR = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgR = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlR = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillR = BorderRadius.all(Radius.circular(pill));
}
