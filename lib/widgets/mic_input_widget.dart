import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class MicInputWidget extends StatelessWidget {
  final FlutterTts flutterTts;

  const MicInputWidget({Key? key, required this.flutterTts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        flutterTts.speak('Voice input activated');
      },
      child: Container(
        width: screenWidth,
        color: Colors.transparent, // Transparent background
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mic Button with Double Border
            Container(
              width: screenWidth * 0.45, // 25% of the screen width
              height: screenWidth * 0.45, // 25% of the screen width (to keep it circular)
              decoration: BoxDecoration(
                color: Colors.white, // White background
                shape: BoxShape.circle, // Circular shape
                border: Border.all(
                  color: Color.fromARGB(128, 100, 123, 255), // Blue inner border color
                  width: 5, // Thickness of the inner border
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(6), // Gap between the two borders
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, // Circular shape
                    border: Border.all(
                      color: Color.fromARGB(255, 100, 123, 255), // Blue outer border color
                      width: 4, // Thickness of the outer border
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic,
                      color: Color.fromARGB(255, 100, 123, 255), // Blue icon color
                      size: screenWidth * 0.20, // 12% of the screen width
                    ),
                  ),
                ),
              ),
            ),
            // Label Below the Mic Button
            SizedBox(height: 10), // Spacing between the mic button and the label
            Text(
              "Tap & Speak",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 67, 78, 234), // Blue text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}