class DailyLimitException implements Exception {
  final String message;
  final int dailyRemaining;

  DailyLimitException({
    required this.message,
    required this.dailyRemaining,
  });

  @override
  String toString() => message;
}