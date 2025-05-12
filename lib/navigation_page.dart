import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geocoding/geocoding.dart'; // Import Geocoding package

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final FlutterTts flutterTts = FlutterTts();
  GoogleMapController? _mapController;

  LatLng? _fromLocation;
  LatLng? _toLocation;

  Set<Marker> _markers = {};
  Polyline? _routePolyline;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  Future<LatLng?> _getCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error finding location: $e')),
      );
    }
    return null;
  }

  void _showRoute() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both From and To locations')),
      );
      return;
    }

    LatLng? fromCoordinates = await _getCoordinates(_fromController.text);
    LatLng? toCoordinates = await _getCoordinates(_toController.text);

    if (fromCoordinates != null && toCoordinates != null) {
      setState(() {
        _fromLocation = fromCoordinates;
        _toLocation = toCoordinates;

        _markers = {
          Marker(markerId: const MarkerId('from'), position: _fromLocation!, infoWindow: const InfoWindow(title: 'From')),
          Marker(markerId: const MarkerId('to'), position: _toLocation!, infoWindow: const InfoWindow(title: 'To')),
        };

        _routePolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: [_fromLocation!, _toLocation!],
          color: Colors.blue,
          width: 5,
        );
      });

      // Move the camera to show the route
      _mapController?.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              _fromLocation!.latitude < _toLocation!.latitude ? _fromLocation!.latitude : _toLocation!.latitude,
              _fromLocation!.longitude < _toLocation!.longitude ? _fromLocation!.longitude : _toLocation!.longitude,
            ),
            northeast: LatLng(
              _fromLocation!.latitude > _toLocation!.latitude ? _fromLocation!.latitude : _toLocation!.latitude,
              _fromLocation!.longitude > _toLocation!.longitude ? _fromLocation!.longitude : _toLocation!.longitude,
            ),
          ),
          50.0,
        ),
      );

      // Simulate verbal route description
      _speakRoute('Starting from ${_fromController.text}, head towards ${_toController.text}.');
    }
  }

  void _speakRoute(String routeDescription) async {
    await flutterTts.speak(routeDescription);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: Column(
        children: [
          // Input Fields for "From" and "To" Locations
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _fromController,
                  decoration: const InputDecoration(
                    labelText: 'From',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _toController,
                  decoration: const InputDecoration(
                    labelText: 'To',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _showRoute,
                  child: const Text('Show Route'),
                ),
              ],
            ),
          ),

          // Google Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default: San Francisco
                zoom: 6.0,
              ),
              markers: _markers,
              polylines: _routePolyline != null ? {_routePolyline!} : {},
              onMapCreated: (controller) {
                _mapController = controller;
              },
            ),
          ),
        ],
      ),
    );
  }
}