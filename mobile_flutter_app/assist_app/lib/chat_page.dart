import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'objects/message.dart';
import 'package:http/http.dart' as http;

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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    String response = "Welcome"; // Welcome message
    setState(() {
      _messages.add(ChatMessage(text: response, isSentByMe: false));
    });
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _scrollController.dispose();
    super.dispose();
  }

  // Modified fetchData function to directly return the response as String
  Future<String> fetchData(String payload) async {
    final String baseUrl = 'https://247f-34-125-31-114.ngrok-free.app/';
    final Map<String, String> queryParams = {
      'param1': payload,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        } else {
          return 'Invalid response';
        }
      } else {
        return 'Request error 1';
      }
    } catch (e) {
      return 'Request error 2';
    }
  }

  // Function to send the message
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
      _controller.clear();
    });

    _scrollToBottom();

    // Wait for the response from fetchData
    String response = await fetchData(message.text);

    setState(() {
      _messages.add(ChatMessage(text: response, isSentByMe: false));
    });

    _scrollToBottom();
  }

  // Function for auto-scrolling to the last message
  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 500), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _saveChat() async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900], // Dialog with dark background
          title: Text('Chat Name', style: TextStyle(color: Colors.white)),
          content: TextField(
            style: TextStyle(color: Colors.white),
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter the chat name",
              hintStyle: TextStyle(color: Colors.white),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SAVE', style: TextStyle(color: Color(0xFF00FFB2))),
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
        backgroundColor: Color(0xFF00FFB2), // Bright green
        title: Text(
          'Chat',
          style: TextStyle(
              color: Color.fromARGB(255, 12, 41, 88),
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Color.fromARGB(255, 12, 41, 88)),
            onPressed: _saveChat,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
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
                      color: message.isSentByMe
                          ? Color.fromARGB(
                              255, 53, 9, 129) // Bright green for sent messages
                          : Color.fromARGB(255, 97, 97,
                              97), // Dark grey for received messages
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
                    style: TextStyle(
                        color: Colors.white), // Set the text color to white
                    decoration: InputDecoration(
                      hintText: 'Send a message...',
                      hintStyle: TextStyle(
                          color: Colors.white), // Set the hint color to white
                      filled: true,
                      fillColor: Colors
                          .blueGrey[800], // Background color of the text field
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send,
                      color: Color(
                          0xFF00FFB2)), // Bright green for the send button
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
