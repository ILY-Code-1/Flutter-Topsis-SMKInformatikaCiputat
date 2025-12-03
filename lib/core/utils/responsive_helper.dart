import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint && 
           width < AppConstants.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.tabletBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getContentMaxWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (screenWidth > AppConstants.maxWidth) {
      return AppConstants.maxWidth;
    }
    return screenWidth;
  }

  static EdgeInsets getHorizontalPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: AppConstants.paddingMD);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: AppConstants.paddingLG);
    }
    return const EdgeInsets.symmetric(horizontal: AppConstants.paddingXL);
  }

  static int getGridCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 3;
  }

  static double getFontSizeMultiplier(BuildContext context) {
    if (isMobile(context)) return 0.85;
    if (isTablet(context)) return 0.95;
    return 1.0;
  }
}

class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppConstants.tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= AppConstants.mobileBreakpoint) {
          return tablet ?? desktop;
        }
        return mobile;
      },
    );
  }
}
