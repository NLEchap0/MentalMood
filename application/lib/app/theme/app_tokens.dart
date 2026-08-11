/// Design tokens: spacing, radii, sizing. Single source for layout metrics.
abstract final class AppTokens {
  // Spacing (4pt grid)
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // Radii — scale with component size
  static const double radiusSm = 16;
  static const double radiusMd = 24;
  static const double radiusLg = 32;
  static const double radiusPill = 48;

  // Layout
  static const double pagePadding = 24;
  static const double contentMaxWidth = 640;
  static const double cardPadding = 20;
  static const double sectionGap = 32;
  static const double touchTarget = 44;
}
