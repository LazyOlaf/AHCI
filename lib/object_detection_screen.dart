import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/mic_input_widget.dart';
import 'widgets/header_widget.dart';

class ObjectDetectionScreen extends StatefulWidget {
  const ObjectDetectionScreen({super.key});

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  bool _isCameraInitialized = false;
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
    _requestPermissionsAndInitialize();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      await _initializeCamera();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and microphone permissions are required.')),
      );
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
    if (!mounted) return;

    setState(() {
      _isCameraInitialized = true;
    });

    _startImageStream();
  }

  void _startImageStream() {
    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      await _flutterTts.speak("Detected object ahead");
      if (await Vibrate.canVibrate) Vibrate.vibrate();

      await Future.delayed(const Duration(seconds: 2));
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: HeaderWidget(
        title: "Object Detection",
        onBackPressed: () {
          Navigator.pop(context); // Navigate back
        },
        onHomePressed: () {
          Navigator.pushNamed(context, '/main_screen'); // Navigate to home
        },
        onProfilePressed: () {
          Navigator.pushNamed(context, '/profile'); // Navigate to profile
        },
      ),
      body: _isCameraInitialized
          ? Column(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    width: screenWidth,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0),
                      child: CameraPreview(_cameraController),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: MicInputWidget(flutterTts: _flutterTts),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
