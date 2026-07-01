import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Pure calculation module for window sizing.
///
/// Deep: hides the arithmetic [+titleBarHeight, +pageExtraHeight] behind a
/// single [sizeForPage] call. The interface is 2 parameters → 1 Size, and
/// a helper to compute extra height from a current window state.
class WindowGeometry {
  WindowGeometry._();

  static const double baseWidth = AppConstants.windowWidth;
  static const double baseHeight = AppConstants.windowHeight;
  static const double barHeight = AppConstants.titleBarHeight;

  /// Calculate window size from visibility and extra-page height.
  ///
  /// [pageExtraHeight] is 0 on the main page; non-zero on sub-pages that
  /// need more room (settings, todo).
  static Size sizeForPage({
    required bool showAppBar,
    double pageExtraHeight = 0,
  }) {
    double height = baseHeight;
    if (showAppBar) height += barHeight;
    height += pageExtraHeight;
    return Size(baseWidth, height);
  }

  /// Infer the extra height from a running window state.
  ///
  /// Used when a toggle (e.g. app bar visibility) fires while a sub-page
  /// is already open and its extra height is already baked into the window.
  static double computeExtraHeight(double currentWindowHeight, bool showAppBar) {
    final double base = showAppBar ? baseHeight + barHeight : baseHeight;
    final double extra = currentWindowHeight - base;
    return extra < 0 ? 0 : extra;
  }
}
