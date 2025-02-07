import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

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

static const platform = MethodChannel('com.example.sheild/call');

 Future<void> _makeCall(String number) async {
  print("Attempting to call: $number"); // Debugging line

  try {
    await platform.invokeMethod('makeCall', {"number": number});
  } on PlatformException catch (e) {
    print("Error making call: ${e.message}");
  }
}
void _startListening() async {
    _makeCall("9645667147");
  var micPermission = await Permission.microphone.request();
  var locationPermission = await Permission.location.request();
  if (micPermission.isGranted && locationPermission.isGranted) {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech Status: $status'),
      onError: (error) => print('Speech Error: ${error.errorMsg}'),
      finalTimeout: Duration(days: 1),
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
  } else {
    print("Permissions not granted!");
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

    String tel = "9645667147";
    _makeCall(tel);
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
