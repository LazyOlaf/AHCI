import 'package:flutter/material.dart'; 
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:permission_handler/permission_handler.dart';
import 'widgets/obj_footer.dart';
import 'widgets/header_widget.dart';
import 'dart:ui' as ui;
import 'dart:html' as html;

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

    // Register the iframe only once
    const viewId = 'object-detection-iframe';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => html.IFrameElement()
        ..src = 'object_detection.html'
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%',
    );
  }

  Future<void> _requestPermissionsAndInitialize() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      await _initializeCamera();
    } else if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera and microphone permissions are required.')),
      );
    } else if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable permissions from app settings.')),
      );
      await openAppSettings();
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
    return Scaffold(
      appBar: HeaderWidget(
        title: "Object Detection",
        onBackPressed: () => Navigator.pop(context),
        onHomePressed: () => Navigator.pushNamed(context, '/main_screen'),
        onProfilePressed: () => Navigator.pushNamed(context, '/profile'),
      ),
      body: Column(
        children: [
          // Top half: HTML object detection iframe
          const Expanded(
            flex: 1,
            child: HtmlElementView(viewType: 'object-detection-iframe'),
          ),

          // Bottom half: Custom mic input widget
          Expanded(
            flex: 1,
            child: MicInputWidget(
              flutterTts: _flutterTts,
              onCommandDetected: (command) {
                // Send voice command to HTML iframe via postMessage
                html.window.postMessage({'command': command}, '*');
              },
            ),
          ),
        ],
      ),
    );
  }
}
