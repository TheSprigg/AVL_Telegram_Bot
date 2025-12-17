import 'package:teledart/teledart.dart';

class NotificationService {
  final TeleDart _teledart;
  final Set<int> _registeredChats;

  NotificationService(this._teledart, this._registeredChats);

  void sendToAll(String message) {
    for (var chatId in _registeredChats) {
      _teledart.sendMessage(chatId, message);
    }
  }
}