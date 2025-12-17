import 'dart:io';

import 'package:logging/logging.dart';

import 'package:avl_telegram_bot/config/bot_config.dart';

class LoggingService {
  static void initialize() {
    final logFile = File(BotConfig.logFile);

    Logger.root.level = Level.INFO;
    Logger.root.onRecord.listen((record) {
      final consoleMessage =
          '[\u001b[32m\u001b[1m${record.level.name}\u001b[0m] '
          '${record.time}: ${record.loggerName}: ${record.message}';
      print(consoleMessage);

      final fileMessage =
          '${record.time}: ${record.level.name}: ${record.loggerName}: ${record.message}';
      logFile.writeAsStringSync('$fileMessage\n', mode: FileMode.append);
    });
  }
}
