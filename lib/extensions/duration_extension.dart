extension DurationFortmatting on Duration {
  String toMinuteAndSecondsString() {
    final twoDigitSeconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$inMinutes:$twoDigitSeconds';
  }

  String toTimeString() {
    if (inHours > 0) {
      final twoDigitMinutes =
          inMinutes.remainder(60).toString().padLeft(2, '0');
      final twoDigitSeconds =
          inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$inHours:$twoDigitMinutes:$twoDigitSeconds';
    }
    return toMinuteAndSecondsString();
  }
}
