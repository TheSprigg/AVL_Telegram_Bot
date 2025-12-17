class BotConfig {
  static const Duration reminderDuration = Duration(minutes: 45);
  static const String reminderCron = '00 19 * * *';
  static const String icsFilePath = 'res/dates.ics';
  static const String chatStorageFile = 'registered_chats.json';
}