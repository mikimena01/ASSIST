import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'objects/message.dart';

class GlobalSettings {
  static String globalUrl = "";

  static Future<void> setGlobalUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('global_url', url);
    globalUrl = url;
  }

  static Future<void> loadGlobalUrl() async {
    final prefs = await SharedPreferences.getInstance();
    globalUrl = prefs.getString('global_url') ?? "";
  }
}

class ArchiveScreen extends StatefulWidget {
  @override
  _ArchiveScreenState createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  TextEditingController _urlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    await GlobalSettings.loadGlobalUrl();
    setState(() {
      _urlController.text = GlobalSettings.globalUrl;
    });
  }

  Future<void> _saveUrl() async {
    await GlobalSettings.setGlobalUrl(_urlController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("URL salvato con successo!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00FFB2), // Bright green
        title: Text(
          'Settings',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              color: Color.fromARGB(255, 12, 41, 88)),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                title: Text("Url"),
              ),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Inserisci l'URL",
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _saveUrl,
                child: Text("Salva"),
              ),
            ],
          ),
        ),
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
        backgroundColor: Color(0xFF00FFB2), // Bright green
        title: Text('Chats Archive',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                  color:
                      message.isSentByMe ? Color(0xFF00FFB2) : Colors.grey[700],
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
