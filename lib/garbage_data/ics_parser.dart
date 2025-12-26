
import 'dart:io';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:avl_telegram_bot/garbage_data/garbage_type.dart';
import 'package:logging/logging.dart';

import '../config/bot_config.dart';
import 'garbage_data.dart';

class IcsParser {
  static final Logger _logger = Logger('IcsParser');
  static final _inputPath = BotConfig.icsFilePath;

  static final Map<String, GarbageType> _mapping = {
    'Gelbe Tonne': GarbageType.yellow,
    'Papiertonne': GarbageType.paper,
    'Glas': GarbageType.glass,
    'Restmuelltonne': GarbageType.other,
    'Biotonne': GarbageType.bio
  };
  static void parseDates(GarbageData data) {
    try {
      final icsLines = File(_inputPath).readAsLinesSync();
      final iCalendar = ICalendar.fromLines(icsLines);
      for (var element in iCalendar.data) {
        _parseEntry(element, data);
      }
      _logger.info('ICS data parsed successfully.');
    } catch (e, st) {
      _logger.severe('Error parsing ICS data: $e', e, st);
      rethrow;
    }
  }

  static void _parseEntry(Map entry, GarbageData data) {
    if (!entry.containsKey('type') || entry['type'] != 'VEVENT') {
      _logger.fine('Not a VEVENT: ${entry['summary']}');
      return;
    }
    if (!_mapping.containsKey(entry['summary'])) {
      _logger.warning('Unknown entry: ${entry['summary']}');
      return;
    }
    var garbageType = _mapping[entry['summary']];
    var date = (entry['dtstart'] as IcsDateTime).toDateTime()?.toLocal();
    if (date != null) {
      data.addDate(garbageType!, date);
      _logger.fine('Entry parsed: $garbageType -> $date');
    }
  }
}
