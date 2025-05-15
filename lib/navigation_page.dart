import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'widgets/mic_input_widget.dart';
import 'widgets/header_widget.dart'; // Import the HeaderWidget

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  NavigationPageState createState() => NavigationPageState();
}

class NavigationPageState extends State<NavigationPage> {
  final TextEditingController _toController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  final MapController _mapController = MapController();

  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _checkConnectivity();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission is required to use the map.')),
      );
    }
  }

  Future<void> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No internet connection. Please connect to the internet.')),
      );
    }
  }

  @override
  void dispose() {
    _toController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) return;

    final uri = Uri.parse("https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1");
    final response = await http.get(uri, headers: {'User-Agent': 'Flutter App'});

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _suggestions = data.map<Map<String, dynamic>>((item) => {
              "display": item["display_name"],
              "lat": double.parse(item["lat"]),
              "lon": double.parse(item["lon"]),
            }).toList();
      });
    }
  }

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final location = GeoPoint(
      latitude: suggestion["lat"],
      longitude: suggestion["lon"],
    );

    setState(() {
      _toController.text = suggestion["display"];
      _suggestions = [];
    });

    await _mapController.goToLocation(location);
    await _drawRouteTo(location);
    _speakLocation(suggestion["display"]);
  }

  Future<void> _drawRouteTo(GeoPoint destination) async {
    try {
      GeoPoint currentLocation = await _mapController.myLocation();
      await _mapController.drawRoad(
        currentLocation,
        destination,
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadWidth: 10,
          roadColor: Colors.blue,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to draw route: $e")),
      );
    }
  }

  void _speakLocation(String address) async {
    if (address.isNotEmpty) {
      await flutterTts.speak('Your destination is $address');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Use HeaderWidget instead of AppBar
          HeaderWidget(
            title: 'Navigation',
            onBackPressed: () {
              Navigator.of(context).pop();
            },
            onHomePressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            onProfilePressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _toController,
                        decoration: const InputDecoration(
                          labelText: 'Enter Destination',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        onChanged: _searchAddress,
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          height: 150,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              final suggestion = _suggestions[index];
                              return ListTile(
                                title: Text(suggestion["display"]),
                                onTap: () => _selectSuggestion(suggestion),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: OSMFlutter(
                    controller: _mapController,
                    trackMyPosition: true,
                    initZoom: 8,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    userLocationMarker: UserLocationMaker(
                      personMarker: MarkerIcon(
                        icon: Icon(
                          Icons.location_history_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      directionArrowMarker: MarkerIcon(
                        icon: Icon(
                          Icons.double_arrow,
                          size: 48,
                        ),
                      ),
                    ),
                    markerOption: MarkerOption(
                      defaultMarker: MarkerIcon(
                        icon: Icon(
                          Icons.person_pin_circle,
                          color: Colors.blue,
                          size: 56,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: MicInputWidget(
              flutterTts: flutterTts,
            ),
          ),
        ],
      ),
    );
  }
}
