import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:html' as html;

class MicInputWidget extends StatefulWidget {
  final FlutterTts flutterTts;
  final void Function(String command) onCommandDetected;

  const MicInputWidget({
    super.key,
    required this.flutterTts,
    required this.onCommandDetected,
  });

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

    // Configure FlutterTTS
    widget.flutterTts.setLanguage("en-US");
    widget.flutterTts.setSpeechRate(0.5); // Adjust speech rate
    widget.flutterTts.setVolume(1.0); // Set volume
    widget.flutterTts.setPitch(1.0); // Set pitch
  }

  void _sendCommandToIframe(String command) {
    // Only works on Flutter Web
    // Import dart:html at the top if not already
    // import 'dart:html' as html;
    final iframe = html.window.document.getElementById('object-iframe') as html.IFrameElement?;
    iframe?.contentWindow?.postMessage({'command': command}, '*');
  }


  Future<void> _listen() async {
    print("Initializing speech recognition...");
    bool available = await _speech.initialize(
      onStatus: (status) => print("Speech status: $status"),
      onError: (error) => print("Speech error: $error"),
    );

    if (available) {
      print("Speech recognition available.");
      setState(() => _isListening = true);
      widget.flutterTts.speak('Listening');

      _speech.listen(
        onResult: (result) async {
          String recognized = result.recognizedWords.toLowerCase();
          print("Recognized: $recognized");

          if (recognized.contains("walk")) {
            print("Command detected: walk");
            widget.flutterTts.speak("Walking mode activated");
            widget.onCommandDetected("walk");
            _sendCommandToIframe("walk");

          } else if (recognized.contains("what")) {
            print("Command detected: what");
            widget.flutterTts.speak("Detecting what's in front");
            widget.onCommandDetected("what");
          } else {
            print("Command not recognized.");
            widget.flutterTts.speak("Sorry, I didn't catch that.");
          }

          _speech.stop();
          setState(() => _isListening = false);
        },
        listenFor: const Duration(seconds: 3),
        pauseFor: const Duration(seconds: 1),
        localeId: 'en_US',
      );
    } else {
      print("Speech recognition not available.");
      widget.flutterTts.speak("Speech recognition not available.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: _isListening ? null : _listen,
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
                  color: const Color.fromARGB(128, 100, 123, 255),
                  width: 5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromARGB(255, 100, 123, 255),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.hearing : Icons.mic,
                      color: const Color.fromARGB(255, 100, 123, 255),
                      size: screenWidth * 0.20,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _isListening ? "Listening..." : "Tap & Speak",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 67, 78, 234),
              ),
            ),
            /* const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.flutterTts.speak("This is a test message.");
              },
              child: const Text("Test TTS"),
            ), */
          ],
        ),
      ),
    );
  }
}
