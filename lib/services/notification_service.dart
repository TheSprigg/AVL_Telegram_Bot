
import 'package:teledart/teledart.dart';

import 'package:logging/logging.dart';

class NotificationService {
  final TeleDart _teledart;
  final Set<int> _registeredChats;
  final Logger _logger = Logger('NotificationService');

  NotificationService(this._teledart, this._registeredChats);

  void sendToAll(String message) {
    for (var chatId in _registeredChats) {
      try {
        _teledart.sendMessage(chatId, message);
        _logger.fine('Message sent to chat $chatId.');
      } catch (e, st) {
        _logger.severe('Error sending to chat $chatId: $e', e, st);
      }
    }
    _logger.info('Message sent to all chats: "$message"');
  }
}