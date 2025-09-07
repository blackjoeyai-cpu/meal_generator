// Application spacing system based on 8px grid
// Provides consistent spacing values throughout the app

class AppSpacing {
  // Private constructor to prevent instantiation
  AppSpacing._();

  // Base unit - 8px grid system
  static const double _baseUnit = 8.0;

  // Spacing values based on base unit
  static const double xs = _baseUnit * 0.5; // 4px
  static const double sm = _baseUnit * 1; // 8px
  static const double md = _baseUnit * 2; // 16px
  static const double lg = _baseUnit * 3; // 24px
  static const double xl = _baseUnit * 4; // 32px
  static const double xxl = _baseUnit * 6; // 48px
  static const double xxxl = _baseUnit * 8; // 64px

  // Component-specific spacing
  static const double cardPadding = md; // 16px
  static const double listItemPadding = md; // 16px
  static const double buttonPadding = md; // 16px
  static const double sectionSpacing = xl; // 32px
  static const double pageMargin = md; // 16px

  // Layout spacing
  static const double screenHorizontal = md; // 16px
  static const double screenVertical = lg; // 24px
  static const double betweenSections = xl; // 32px
  static const double betweenElements = md; // 16px
  static const double betweenItems = sm; // 8px

  // Interactive elements
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double iconSize = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeSmall = 16.0;

  // Border radius values
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircular = 50.0;

  // Elevation values
  static const double elevationNone = 0.0;
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;
  static const double elevationHighest = 16.0;

  // Animation durations (in milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;

  // Custom spacing methods
  static double custom(double multiplier) => _baseUnit * multiplier;

  // Get responsive spacing based on screen width
  static double responsive(double screenWidth) {
    if (screenWidth < 600) {
      return md; // Mobile
    } else if (screenWidth < 1200) {
      return lg; // Tablet
    } else {
      return xl; // Desktop
    }
  }
}
