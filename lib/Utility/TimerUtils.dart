
class TimerUtils {

  ///  Returns the remaining time until 12:00 AM (Indian Time) formatted as "04h 13m 22s"
  static String getRemainingTimeToMidnight() {
    // Get Indian Local Time (IST)
    DateTime now = DateTime.now().toLocal();

    // Calculate next midnight (12:00 AM)
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

    // Calculate difference
    Duration difference = nextMidnight.difference(now);

    // Extract hours, minutes, seconds
    int hours = difference.inHours;
    int minutes = difference.inMinutes.remainder(60);
    int seconds = difference.inSeconds.remainder(60);

    // Format & Return
    return '${hours.toString().padLeft(2, '0')}h '
        '${minutes.toString().padLeft(2, '0')}m '
        '${seconds.toString().padLeft(2, '0')}s';
  }
}
