class Helper {
  static DateTime today() {
    var now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  }
}
