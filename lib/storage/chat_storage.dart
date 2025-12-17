import 'dart:convert';
import 'dart:io' as io;

class ChatStorage {
  final io.File _chatsFile;

  ChatStorage(String filePath) : _chatsFile = io.File(filePath);

  Future<Set<int>> loadChats() async {
    if (await _chatsFile.exists()) {
      var jsonString = await _chatsFile.readAsString();
      var chatIds = jsonDecode(jsonString) as List<dynamic>;
      return chatIds.map((id) => id as int).toSet();
    }
    return {};
  }

  Future<void> saveChats(Set<int> chats) async {
    var jsonString = jsonEncode(chats.toList());
    await _chatsFile.writeAsString(jsonString);
  }
}