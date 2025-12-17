import 'dart:convert';
import 'dart:io' as io;
import 'package:avl_telegram_bot/env/env.dart';
import 'package:cron/cron.dart';
import 'package:avl_telegram_bot/garbage_data/garbage_data.dart';
import 'package:avl_telegram_bot/garbage_data/garbage_type.dart';
import 'package:avl_telegram_bot/utils/helper.dart';
import 'package:teledart/model.dart';
import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

import 'garbage_data/ics_parser.dart';

class TelegramBot {
  final _registeredChats = <int>{};
  final _penetrationDuration = Duration(minutes: 45);
  final _penetrationStartCron = '00 19 * * *';
  DateTime? _currentRunningDay;

  final _commands = [
    _Command('gelb', 'Nächste gelbe Sack Leerung', GarbageType.yellow),
    _Command('papier', 'Nächste Papierleerung', GarbageType.paper),
    _Command('rest', 'Nächste Restmüllleerung', GarbageType.other),
    _Command('glas', 'Nächste Glas Leerung', GarbageType.glass),
    _Command('bio', 'Nächste Biomüllleerung', GarbageType.bio),
  ];

  late GarbageData data = GarbageData();
  final _chatsFile = io.File('registered_chats.json');

  Future<void> initialize() async {
    IcsParser.parseDates(data);
    await _loadChats();
    var telegram = Telegram(Env.apiKey);

    var botCommands = List<BotCommand>.empty(growable: true);
    for (var element in _commands) {
      botCommands.add(element.command);
    }
    botCommands.add(BotCommand(
        command: 'erledigt', description: 'Müll wurde rausgestellt'));
    botCommands.add(BotCommand(
        command: 'start', description: 'Starte die Reminder von Oscar'));
    botCommands.add(BotCommand(
        command: 'stop', description: 'Genug von Oscar genervt worden'));
    telegram.setMyCommands(botCommands);

    var event = Event((await telegram.getMe()).username!);

    var teledart = TeleDart(Env.apiKey, event);

    teledart
        .onCommand('start')
        .listen((message) => message.reply(start(message)));

    teledart
        .onCommand('stop')
        .listen((message) => message.reply(stop(message)));

    teledart.onCommand('erledigt').listen((message) => done(teledart));

    for (var command in _commands) {
      teledart
          .onCommand(command.command.command)
          .listen((message) => message.reply(data.getNextDate(command.type)));
    }
    teledart.start();

    var now = DateTime.now();
    now.add(Duration(minutes: 1));

    Cron().schedule(
        Schedule.parse(_penetrationStartCron), () => executeCheck(teledart));
  }

  Future<void> _loadChats() async {
    if (await _chatsFile.exists()) {
      var jsonString = await _chatsFile.readAsString();
      var chatIds = jsonDecode(jsonString) as List<dynamic>;
      _registeredChats.addAll(chatIds.map((id) => id as int));
    }
  }

  Future<void> _saveChats() async {
    var jsonString = jsonEncode(_registeredChats.toList());
    await _chatsFile.writeAsString(jsonString);
  }

  void executeCheck(TeleDart teledart) {
    var tomorrowTypes = data.checkTomorrow();
    if (tomorrowTypes.isEmpty) {
      _currentRunningDay = null;
      return;
    }
    _currentRunningDay = Helper.today();
    alert(teledart, tomorrowTypes);
  }

  void alert(TeleDart teledart, List<GarbageType> tomorrowTypes) {
    if (_currentRunningDay == null) {
      return;
    }

    if (_currentRunningDay != null &&
        _currentRunningDay!.isBefore(Helper.today())) {
      for (var chatId in _registeredChats) {
        teledart.sendMessage(
            chatId, 'Es wurde wohl vergessen den Müll rauszubringen!');
      }
      _currentRunningDay = null;
      return;
    }

    for (var chatId in _registeredChats) {
      var garbageNames = List.empty(growable: true);
      for (var element in tomorrowTypes) {
        garbageNames.add(GarbageTypeName.getName(element));
      }

      teledart.sendMessage(
          chatId, 'Morgen muss der Müll raus: ${garbageNames.join(', ')}');
    }

    Future.delayed(_penetrationDuration, () => alert(teledart, tomorrowTypes));
  }

  String start(TeleDartMessage message) {
    var chatId = message.chat.id;
    _registeredChats.add(chatId);
    _saveChats();
    return 'Ab jetzt gibts Nachrichten wenn der Müll raus muss';
  }

  String stop(TeleDartMessage message) {
    var chatId = message.chat.id;
    _registeredChats.remove(chatId);
    _saveChats();
    return 'Ab jetzt gibts keine Nachrichten mehr wenn der Müll raus muss';
  }

  void done(TeleDart teledart) {
    _currentRunningDay = null;
    for (var chatId in _registeredChats) {
      teledart.sendMessage(chatId, 'Müll wurde rausgebracht');
    }
  }
}

class _Command {
  late BotCommand command;
  GarbageType type;

  _Command(String command, String description, this.type) {
    this.command = BotCommand(command: command, description: description);
  }
}
