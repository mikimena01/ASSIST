import 'dart:convert'; // Importa la libreria per la gestione di JSON
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'objects/message.dart';

class ChatScreen extends StatefulWidget {
  final WebSocketChannel channel;
  final String initialMessage;

  ChatScreen({required this.channel, required this.initialMessage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  String messageText = '';

  @override
  void initState() {
    super.initState();

    // Invia il primo messaggio al caricamento della schermata
    widget.channel.sink.add(json.encode({
      'type': 'chat_message',
      'message': widget.initialMessage,
    }));

    _messages.add(ChatMessage(text: widget.initialMessage, isSentByMe: true));

    // Ascolta i messaggi dal WebSocket
    widget.channel.stream.listen(
      (message) {
        final decodedMessage = json.decode(message);
        print(decodedMessage['message']);
        if (decodedMessage['message'] != widget.initialMessage &&
            decodedMessage['message'] != messageText) {
          setState(() {
            _messages.add(ChatMessage(
              text: decodedMessage['message'],
              isSentByMe: false, // Messaggio ricevuto
            ));
          });
        }
      },
    );
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        messageText = _controller.text;
      });

      final message = json.encode({
        'type': 'chat_message',
        'message': messageText,
      });

      // Invia il messaggio JSON tramite WebSocket
      widget.channel.sink.add(message);

      setState(() {
        // Aggiungi il messaggio alla lista dei messaggi inviati
        _messages.add(ChatMessage(text: _controller.text, isSentByMe: true));
      });

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Align(
                    alignment: message.isSentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: message.isSentByMe ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message.text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: 'Scrivi un messaggio...'),
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
