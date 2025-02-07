import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: $error'),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _text = result.recognizedWords);
        if (_text.toLowerCase().contains("help me")) {
          _sendEmergencyAlert();
        }
      });
    }
  }

  void _sendEmergencyAlert() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    String message =
        "Emergency! I am in danger. My location: https://maps.google.com/?q=${position.latitude},${position.longitude}";
    print(message);
    String smsUrl = "sms:9645667147?body=$message";
    if (await canLaunch(smsUrl)) {
      await launch(smsUrl);
    }

    String whatsappUrl = "https://wa.me/9645667147?text=$message";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    }

    String telUrl = "tel:9645667147";
    if (await canLaunch(telUrl)) {
      await launch(telUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Emergency Alert System')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isListening ? "Listening..." : "Press to Start Listening"),
              ElevatedButton(
                onPressed: _startListening,
                child: Text("Activate Voice Command"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
