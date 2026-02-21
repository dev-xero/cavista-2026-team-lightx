part of '../constants.dart';

/// xxs -> 4
/// xs -> 8
/// sm -> 12
/// md -> 16
/// lg -> 24
/// xl -> 32
/// xxl -> 48
/// xxxl -> 64
class Spacing {
  /// 4
  static const double xxs = 4;

  /// 8
  static const double xs = 8;

  /// 12
  static const double sm = 12;

  /// 16
  static const double md = 16;

  /// 24
  static const double lg = 24;

  /// 32
  static const double xl = 32;

  /// 48
  static const double xxl = 48;

  /// 64
  static const double xxxl = 64;
}

extension SpacingValueExtension on num {
  SizedBox get inRow => SizedBox(width: toDouble());
  SizedBox get inColumn => SizedBox(height: toDouble());
  SliverToBoxAdapter get inSliverColumn => SliverToBoxAdapter(child: inColumn);
  SliverToBoxAdapter get inSliverRow => SliverToBoxAdapter(child: inRow);
}
