/// App constants
class AppConst {
  /// Legacy min (board collapsed); prefer [boardMinChildSize] / [boardPeekChildSize].
  static const double minChildSize = 0.1;

  /// Chat tab: sheet fills almost full screen.
  static const double maxChildSize = 0.9999;

  /// Board tab: «открытая» высота панели.
  static const double boardPeekChildSize = 0.2;

  /// Board tab: почти полностью скрыть (остаётся тонкая полоска / ручка).
  static const double boardMinChildSize = 0.035;

  /// Ниже этой доли высоты скрываем поле ввода и градиент.
  static const double sheetShowInputThreshold = 0.14;
}
