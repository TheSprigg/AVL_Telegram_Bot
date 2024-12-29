import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:avl_telegram_bot/garbage_data/garbage_type.dart';

import 'garbage_data.dart';

class IcsParser {
  static final _inputPath = 'res/dates.ics';

  static final Map<String,GarbageType> _mapping = {
    'Gelbe Tonne' : GarbageType.yellow,
    'Papiertonne' : GarbageType.paper,
    'Glas' : GarbageType.glass,
    'Restmuelltonne' : GarbageType.other,
    'Biotonne' : GarbageType.bio
  };
  static void parseDates(GarbageData data) {
    final icsLines = File(_inputPath).readAsLinesSync();
    final iCalendar = ICalendar.fromLines(icsLines);
    for (var element in iCalendar.data) {
      _parseEntry(element, data);
    }
  }

  static void _parseEntry(Map entry, GarbageData data) {
    if(!entry.containsKey('type') || entry['type'] != 'VEVENT') {
      return;
    }
    if(!_mapping.containsKey(entry['summary'])) {
      return;
    }
    var garbageType = _mapping[entry['summary']];
    var date = (entry['dtstart'] as IcsDateTime).toDateTime();
    data.addDate(garbageType!, date!);
  }
}
