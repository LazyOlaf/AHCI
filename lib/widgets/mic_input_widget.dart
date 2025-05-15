import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:html' as html;

class MicInputWidget extends StatefulWidget {
  final FlutterTts flutterTts;

  const MicInputWidget({super.key, required this.flutterTts});

  @override
  State<MicInputWidget> createState() => _MicInputWidgetState();
}

class _MicInputWidgetState extends State<MicInputWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize();

    if (available) {
      setState(() => _isListening = true);
      widget.flutterTts.speak('Listening');

      _speech.listen(
        onResult: (result) async {
          String command = result.recognizedWords.toLowerCase();
          print("Heard: $command");

          if (command.contains('what')) {
            _sendCommandToWeb('what');
            await widget.flutterTts.speak('Describing what I see');
          } else if (command.contains('walk')) {
            _sendCommandToWeb('walk');
            await widget.flutterTts.speak('Entering walk mode');
          } else {
            await widget.flutterTts.speak('Sorry, I did not understand');
          }

          _speech.stop();
          setState(() => _isListening = false);
        },
        listenFor: Duration(seconds: 5),
        pauseFor: Duration(seconds: 3),
        localeId: 'en_US',
        cancelOnError: true,
        partialResults: false,
      );
    } else {
      await widget.flutterTts.speak('Speech recognition not available');
    }
  }

  void _sendCommandToWeb(String command) {
    html.window.postMessage({'command': command}, '*');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _isListening ? null : _startListening,
      child: Container(
        width: screenWidth,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: screenWidth * 0.45,
              height: screenWidth * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color.fromARGB(128, 100, 123, 255),
                  width: 5,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.fromARGB(255, 100, 123, 255),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.hearing : Icons.mic,
                      color: Color.fromARGB(255, 100, 123, 255),
                      size: screenWidth * 0.20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              _isListening ? "Listening..." : "Tap & Speak",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 67, 78, 234),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
