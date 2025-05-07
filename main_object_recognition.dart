import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:tflite/tflite.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(VisionAssistApp());
}

class VisionAssistApp extends StatelessWidget {
  const VisionAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vision Assist',
      theme: ThemeData.dark(),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  Widget build(BuildContext context) {
    _requestPermissions();

    return Scaffold(
      appBar: AppBar(title: Text("Vision Assist")),
      body: Center(
        child: ElevatedButton(
          child: Text("Start Object Recognition"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ObjectDetectionPage()),
            );
          },
        ),
      ),
    );
  }
}

class ObjectDetectionPage extends StatefulWidget {
  const ObjectDetectionPage({super.key});

  @override
  _ObjectDetectionPageState createState() => _ObjectDetectionPageState();
}

class _ObjectDetectionPageState extends State<ObjectDetectionPage> {
  late CameraController _cameraController;
  bool isDetecting = false;
  late FlutterTts tts;
  late SpeechToText _speech;
  String detectedObject = "";

  @override
  void initState() {
    super.initState();
    initEverything();
  }

  Future<void> initEverything() async {
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController.initialize();
    tts = FlutterTts();
    _speech = SpeechToText();
    await Tflite.loadModel(
      model: "assets/ssd_mobilenet.tflite",
      labels: "assets/labels.txt",
    );
    startVoiceCommand();
    startDetection();
  }

  void startDetection() {
    _cameraController.startImageStream((image) async {
      if (!isDetecting) {
        isDetecting = true;

        var recognitions = await Tflite.detectObjectOnFrame(
          bytesList: image.planes.map((plane) => plane.bytes).toList(),
          model: "SSDMobileNet",
          imageHeight: image.height,
          imageWidth: image.width,
          imageMean: 127.5,
          imageStd: 127.5,
        );

        if (recognitions != null && recognitions.isNotEmpty) {
          String obj = recognitions[0]['detectedClass'];
          if (obj != detectedObject) {
            setState(() {
              detectedObject = obj;
            });
            await tts.speak("Detected $obj");
          }
        }

        isDetecting = false;
      }
    });
  }

  void stopDetection() {
    _cameraController.stopImageStream();
    setState(() {
      detectedObject = "Detection stopped.";
    });
  }

  void startVoiceCommand() async {
    bool available = await _speech.initialize();
    if (available) {
      _speech.listen(
        onResult: (result) async {
          String command = result.recognizedWords.toLowerCase();
          if (command.contains("start")) {
            startDetection();
            await tts.speak("Detection started");
          } else if (command.contains("stop")) {
            stopDetection();
            await tts.speak("Detection stopped");
          } else if (command.contains("details")) {
            await tts.speak("Details for $detectedObject are not available offline.");
          }
        },
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Object Detection")),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: _cameraController.value.aspectRatio,
            child: CameraPreview(_cameraController),
          ),
          SizedBox(height: 20),
          Text("Detected: $detectedObject", style: TextStyle(fontSize: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: startDetection, child: Text("Start")),
              ElevatedButton(onPressed: stopDetection, child: Text("Stop")),
            ],
          )
        ],
      ),
    );
  }
}
