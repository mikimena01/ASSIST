import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
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
      title: 'ASSIST',
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.greenAccent, // Button color
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        scaffoldBackgroundColor:
            Color.fromARGB(255, 12, 41, 88), // Dark background (Dark Blue)
      ),
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

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(
      Uri.parse('wss://your.websocket.url'),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  bool validateTaxCode(String codice) {
    final RegExp regex =
        RegExp(r'^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$');
    return regex.hasMatch(codice);
  }

  Future<void> scanBarcode() async {
    String barcodeScanRes = 'Waiting for scan...';

    setState(() {
      _scanResult = barcodeScanRes;
    });

    while (true) {
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#FF00FF', 'Cancel', true, ScanMode.BARCODE);
      } on Exception {
        barcodeScanRes = 'Barcode scan error';
      }

      if (!mounted) return;

      if (validateTaxCode(barcodeScanRes)) {
        setState(() {
          _scanResult = barcodeScanRes;
        });
        break;
      } else {
        setState(() {
          _scanResult = 'Invalid tax code, please try again...';
          print('Invalid tax code, please try again...');
        });
      }
    }
  }

  void navigateToChat() {
    if (_scanResult != 'No result' &&
        _scanResult != 'Invalid tax code, please try again...') {
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
    final String baseUrl = 'https://725b-34-126-175-194.ngrok-free.app';
    final Map<String, String> queryParams = {
      'param1': payload,
    };

    final Uri uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

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
      appBar: AppBar(
        backgroundColor: Color(0xFF00FFB2), // Dark blue for the bar
        title: Text('ASSIST',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: Color.fromARGB(255, 12, 41, 88))),
        actions: [
          IconButton(
            iconSize: 30,
            icon: Icon(Icons.archive, color: Color.fromARGB(255, 12, 41, 88)),
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
              // Title
              Text(
                'Scan result:',
                style: TextStyle(
                  color: Color(0xFF00FFB2), // Light purple for the title
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Scan result
              Text(
                '$_scanResult',
                style: TextStyle(
                  color: Color(0xFF00FFB2), // Bright green for result
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),
              // Button to scan health card
              ElevatedButton(
                onPressed: scanBarcode,
                child: Text('Scan Health Card',
                    style: TextStyle(color: Color.fromARGB(255, 12, 41, 88))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00FFB2), // Bright green
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  elevation: 5, // Button shadow
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              SizedBox(height: 40),
              // Button to go to chat
              ElevatedButton(
                onPressed: navigateToChat,
                child: Text('Start Chat',
                    style: TextStyle(color: Color.fromARGB(255, 12, 41, 88))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00FFB2), // Dark blue
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
