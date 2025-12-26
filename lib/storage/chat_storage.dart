import 'dart:convert';
import 'dart:io';
import 'package:logging/logging.dart';

class ChatStorage {
  final Logger _logger = Logger('ChatStorage');
  final File _chatsFile;

  ChatStorage(String filePath) : _chatsFile = File(filePath);

  Future<Set<int>> loadChats() async {
    try {
      if (await _chatsFile.exists()) {
        var jsonString = await _chatsFile.readAsString();
        var chatIds = jsonDecode(jsonString) as List<dynamic>;
          _logger.info('Chats loaded: [34m${chatIds.length}[0m IDs');
        return chatIds.map((id) => id as int).toSet();
      }
        _logger.info('No chat file found, returning empty chat list.');
      return {};
    } catch (e, st) {
        _logger.severe('Error loading chats: $e', e, st);
      rethrow;
    }
  }

  Future<void> saveChats(Set<int> chats) async {
    try {
      var jsonString = jsonEncode(chats.toList());
      await _chatsFile.writeAsString(jsonString);
        _logger.info('Chats saved: [34m${chats.length}[0m IDs');
    } catch (e, st) {
        _logger.severe('Error saving chats: $e', e, st);
      rethrow;
    }
  }
}