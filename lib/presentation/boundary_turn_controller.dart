final class BoundaryTurnController {
  BoundaryTurnController({
    this.minimumGap = const Duration(milliseconds: 320),
    this.maximumGap = const Duration(milliseconds: 2200),
  });

  final Duration minimumGap;
  final Duration maximumGap;
  int? _direction;
  DateTime? _at;

  bool register(int direction, DateTime now) {
    if (direction != -1 && direction != 1) return false;
    final Duration? elapsed = _direction == direction && _at != null
        ? now.difference(_at!)
        : null;
    if (elapsed != null && elapsed < minimumGap) return false;
    final bool turn = elapsed != null && elapsed <= maximumGap;
    _direction = direction;
    _at = now;
    if (turn) clear();
    return turn;
  }

  void clear() {
    _direction = null;
    _at = null;
  }
}
