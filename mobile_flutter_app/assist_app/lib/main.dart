import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat_page.dart';
import 'archive_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  String _scanResult = 'Nessun risultato';
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

  // Funzione di validazione del Codice Fiscale
  bool validateCodiceFiscale(String codice) {
    final RegExp regex =
        RegExp(r'^[A-Z]{6}[0-9]{2}[A-Z][0-9]{2}[A-Z][0-9]{3}[A-Z]$');
    return regex.hasMatch(codice);
  }

  // Funzione di scansione del codice a barre
  Future<void> scanBarcode() async {
    String barcodeScanRes = 'In attesa di scansione...';

    setState(() {
      _scanResult = barcodeScanRes; // Mostra il messaggio di attesa
    });

    while (true) {
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Annulla', true, ScanMode.BARCODE);
      } on Exception {
        barcodeScanRes = 'Errore nella scansione del codice a barre';
      }

      if (!mounted) return;

      if (validateCodiceFiscale(barcodeScanRes)) {
        setState(() {
          _scanResult = barcodeScanRes; // Mostra il codice fiscale valido
        });
        break; // Esci dal ciclo quando trovi un codice fiscale valido
      } else {
        setState(() {
          _scanResult = 'Codice fiscale non valido, riprova...';
          print('Codice fiscale non valido, riprova...');
        });
      }
    }
  }

  void navigateToChat() {
    if (_scanResult != 'Nessun risultato' &&
        _scanResult != 'Codice fiscale non valido, riprova...') {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(Icons.archive),
            onPressed: navigateToArchive,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Risultato della scansione:',
            ),
            Text(
              '$_scanResult',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: scanBarcode,
              child: Text('Scansiona Codice a Barre'),
            ),
            ElevatedButton(
              onPressed: navigateToChat,
              child: Text('Vai alla Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
