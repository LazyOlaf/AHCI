import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  final FlutterTts _flutterTts = FlutterTts();
  final ObjectDetector _objectDetector = ObjectDetector(
    options: ObjectDetectorOptions(
      classifyObjects: true,
      multipleObjects: true,
      mode: DetectionMode.stream,
    ),
  );

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
    if (!mounted) return;
    setState(() {});
    _startImageStream();
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      // Simulated detection result
      await _flutterTts.speak("Detected object ahead");
      if (await Vibrate.canVibrate) Vibrate.vibrate();

      await Future.delayed(Duration(seconds: 2));
      _isDetecting = false;
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _objectDetector.close();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Object Recognition",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: Column(
        children: [
          // Camera Preview (50% of vertical space)
          Expanded(
            flex: 1,
            child: SizedBox(
              width: screenWidth, // Full screen width
              child: _cameraController.value.isInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CameraPreview(_cameraController),
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),

          // Lower Portion for Voice Input
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _flutterTts.speak('Voice input activated');
              },
              child: Container(
                width: screenWidth,
                color: Colors.transparent, // Transparent background
                child: Center(
                  child: Container(
                    width: screenWidth * 0.2, // 20% of the screen width
                    height: screenWidth * 0.2, // 20% of the screen width (to keep it circular)
                    decoration: BoxDecoration(
                      color: Colors.white, // White background
                      shape: BoxShape.circle, // Circular shape
                      border: Border.all(
                        color: Color.fromARGB(255, 8, 33, 224), // Blue border color
                        width: 4, // Thickness of the border
                      ),
                    ),
                    child: Icon(
                      Icons.mic,
                      color: Color.fromARGB(255, 8, 33, 224), // Blue icon color
                      size: screenWidth * 0.1, // 10% of the screen width
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
