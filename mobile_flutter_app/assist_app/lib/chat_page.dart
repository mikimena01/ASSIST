import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'objects/message.dart';

class ChatScreen extends StatefulWidget {
  final String scanResult;
  final WebSocketChannel channel;

  ChatScreen({required this.scanResult, required this.channel});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(text: widget.scanResult, isSentByMe: true));
    widget.channel.stream.listen((data) {
      setState(() {
        _messages.add(ChatMessage(text: data, isSentByMe: false));
      });
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) {
      return;
    }

    final message = ChatMessage(
      text: _controller.text,
      isSentByMe: true,
    );

    setState(() {
      _messages.add(message);
    });

    widget.channel.sink.add(
      json.encode({
        'type': 'chat_message',
        'message': _controller.text,
      }),
    );

    _controller.clear();
  }

  Future<void> _saveChat() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nome della chat'),
          content: TextField(
            controller: nameController,
            decoration:
                InputDecoration(hintText: "Inserisci il nome della chat"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ANNULLA'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SALVA'),
              onPressed: () {
                Navigator.of(context).pop(nameController.text);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> chats = prefs.getStringList('chats') ?? [];
      List<String> chatNames = prefs.getStringList('chatNames') ?? [];
      chats.add(json.encode(_messages.map((msg) => msg.toJson()).toList()));
      chatNames.add(result);
      await prefs.setStringList('chats', chats);
      await prefs.setStringList('chatNames', chatNames);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveChat,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment: message.isSentByMe
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                      color: message.isSentByMe ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: 'Invia un messaggio...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
