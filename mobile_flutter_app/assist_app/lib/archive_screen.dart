import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'objects/message.dart';

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  List<List<ChatMessage>> _chats = [];
  List<String> _chatNames = [];
  List<bool> _selectedChats = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> chats = prefs.getStringList('chats') ?? [];
    List<String> chatNames = prefs.getStringList('chatNames') ?? [];
    setState(() {
      _chats = chats
          .map((chat) => (json.decode(chat) as List)
              .map((message) => ChatMessage.fromJson(message))
              .toList())
          .toList();
      _chatNames = chatNames;
      _selectedChats = List<bool>.filled(_chats.length, false);
    });
  }

  void _openChat(List<ChatMessage> messages) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchivedChatScreen(messages: messages),
      ),
    );
  }

  void _toggleSelection(int index) {
    setState(() {
      _selectedChats[index] = !_selectedChats[index];
    });
  }

  Future<void> _deleteSelectedChats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> chats = prefs.getStringList('chats') ?? [];
    List<String> chatNames = prefs.getStringList('chatNames') ?? [];

    List<int> indicesToRemove = [];
    for (int i = 0; i < _selectedChats.length; i++) {
      if (_selectedChats[i]) {
        indicesToRemove.add(i);
      }
    }

    for (int i = indicesToRemove.length - 1; i >= 0; i--) {
      int index = indicesToRemove[i];
      _chats.removeAt(index);
      chatNames.removeAt(index);
      chats.removeAt(index);
    }

    await prefs.setStringList('chats', chats);
    await prefs.setStringList('chatNames', chatNames);
    setState(() {
      _selectedChats = List<bool>.filled(_chats.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archivio Chat'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed:
                _selectedChats.contains(true) ? _deleteSelectedChats : null,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_chatNames[index]),
            onTap: () => _openChat(_chats[index]),
            trailing: Checkbox(
              value: _selectedChats[index],
              onChanged: (bool? value) {
                _toggleSelection(index);
              },
            ),
          );
        },
      ),
    );
  }
}

class ArchivedChatScreen extends StatelessWidget {
  final List<ChatMessage> messages;

  ArchivedChatScreen({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archivio'),
      ),
      body: ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          final message = messages[index];
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
    );
  }
}
