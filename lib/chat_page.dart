import 'package:flutter/material.dart';
import 'package:flutter_sockets/chat_stream.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late ChatStream controller;
  late TextEditingController _textEditingController;
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    controller = ChatStream();
    _textEditingController = TextEditingController();
    initChat();
  }

  @override
  void dispose() {
    controller.closeStream();
    socket.dispose();
    super.dispose();
  }

  void initChat() {
    try {
      socket = IO.io('http://10.0.2.2:3000',
          IO.OptionBuilder().setTransports(['websocket']).build());
      socket.onConnect((_) {
        print('connected!');
        socket.emit('chat message', 'Mobile connected!');
      });
      socket.on('chat message', (data) => controller.addMessage(data));
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<String>>(
                stream: controller.chatStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    print(snapshot.data);
                    return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) =>
                            Text(snapshot.data![index]));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("Has error"),
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      onEditingComplete: _sendMessage,
                      decoration: InputDecoration(border: OutlineInputBorder()),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Text('Send'),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    print(_textEditingController.text);
    print(socket.id);
    if (socket.connected) {
      socket.emit('chat message', _textEditingController.text);
    } else if (socket.disconnected) {
      socket.connect();
      socket.emit('chat message', _textEditingController.text);
    }

    _textEditingController.clear();
  }
}
