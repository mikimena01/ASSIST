import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_page.dart';
import 'archive_screen.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String payload = "white blood cells of Maria Bianchi";
  String _scanResult = 'No result';
  late WebSocketChannel _channel;
  String _retrievedUrl = "";

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your.websocket.url'),
    );
    _loadUrl();
  }

  Future<void> _loadUrl() async {
    await GlobalSettings.loadGlobalUrl();
    setState(() {
      _retrievedUrl = GlobalSettings.globalUrl;
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void navigateToChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          scanResult: _scanResult,
          channel: _channel,
        ),
      ),
    );
  }

  void navigateToArchive() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArchiveScreen(),
      ),
    );
  }

  Future<void> fetchData(String payload) async {
    final Map<String, String> queryParams = {
      'param1': payload,
    };
    print(_retrievedUrl);
    final Uri uri =
        Uri.parse(_retrievedUrl).replace(queryParameters: queryParams);

    try {
      final http.Response response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response: $data');
      } else {
        print('Request error: ${response.statusCode}');
      }
    } catch (e) {
      print('Request error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 12, 17, 24),
      appBar: AppBar(
        backgroundColor:
            Color.fromRGBO(255, 153, 255, 1), // Dark blue for the bar
        title: Text('MENTHOR',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Color.fromARGB(255, 12, 17, 24))),
        actions: [
          IconButton(
            iconSize: 30,
            icon: Icon(Icons.settings, color: Color.fromRGBO(255, 153, 255, 1)),
            onPressed: navigateToArchive,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 30),

              // Button to go to chat
              ElevatedButton(
                onPressed: navigateToChat,
                child: Text('Start Chat',
                    style: TextStyle(color: Color.fromARGB(255, 12, 17, 24))),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color.fromRGBO(255, 153, 255, 1), // Dark blue
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
