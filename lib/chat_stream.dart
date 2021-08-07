import 'dart:async';

class ChatStream {
  List<String> messages = [];
  final _chatController = StreamController<List<String>>();

  void addMessage(String msg) {
    messages.add(msg);
    _chatController.add(messages);
  }

  Stream<List<String>> get chatStream => _chatController.stream;

  void closeStream() {
    _chatController.close();
  }
}
