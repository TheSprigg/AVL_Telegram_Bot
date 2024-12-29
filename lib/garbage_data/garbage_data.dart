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
    if (!_dates.containsKey(type)) {
      throw NoDateFoundException();
    }
    var nextDate = _dates[type]?.reduce((a, b) => _checkDate(a, b));
    var now = Helper.today();
    if (nextDate!.isBefore(now) || nextDate.isAtSameMomentAs(now)) {
      throw NoDateFoundException();
    }
    return nextDate;
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

  DateTime _checkDate(DateTime a, DateTime b) {
    var now = Helper.today();
    if (a.isBefore(now) || a.isAtSameMomentAs(now)) {
      return b;
    }
    if (b.isBefore(now) || b.isAtSameMomentAs(now)) {
      return a;
    }
    return a.difference(now).abs() < b.difference(now).abs() ? a : b;
  }

  List<GarbageType> checkTomorrow() {
    var retVal = List<GarbageType>.empty(growable: true);
    for (var type in GarbageType.values) {
      var next = _getNextDate(type);
      if (Helper.today().add(Duration(days: 1)).isAtSameMomentAs(next)) {
        retVal.add(type);
      }
    }

    return retVal;
  }
}
