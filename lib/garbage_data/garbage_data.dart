import 'package:avl_telegram_bot/exception/no_date_found_exception.dart';
import 'package:avl_telegram_bot/garbage_data/garbage_type.dart';
import 'package:avl_telegram_bot/utils/helper.dart';
import 'package:intl/intl.dart';

class GarbageData {
  final _dates = <GarbageType, List<DateTime>>{};

  void addDate(GarbageType type, DateTime time) {
    _dates.putIfAbsent(type, () => List<DateTime>.empty(growable: true));
    _dates[type]?.add(time);
  }

  DateTime _getNextDate(GarbageType type) {
    if (!_dates.containsKey(type) || _dates[type]!.isEmpty) {
      throw NoDateFoundException();
    }
    var today = Helper.today();
    var futureDates = _dates[type]!.where((date) => date.isAfter(today) || date.isAtSameMomentAs(today)).toList();
    if (futureDates.isEmpty) {
      throw NoDateFoundException();
    }
    futureDates.sort((a, b) => a.compareTo(b));
    return futureDates.first;
  }

  String getNextDate(GarbageType type) {
    try {
      var nextDate = _getNextDate(type);
      var formatter = DateFormat('dd.MM.yyyy');
      var formatted = formatter.format(nextDate);
      return 'Die nächste Leerung ist am $formatted';
    } on NoDateFoundException {
      return 'Leider wird der Behälter nie wieder geleert ';
    }
  }

  List<GarbageType> checkTomorrow() {
    var retVal = List<GarbageType>.empty(growable: true);
    var tomorrow = Helper.today().add(Duration(days: 1));
    for (var type in GarbageType.values) {
      try {
        var next = _getNextDate(type);
        if (next.isAtSameMomentAs(tomorrow)) {
          retVal.add(type);
        }
      } on NoDateFoundException {
        // Skip if no date found
      }
    }
    return retVal;
  }
}
