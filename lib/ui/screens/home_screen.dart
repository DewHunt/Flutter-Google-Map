import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _googleMapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylinePoints = [];

  @override
  void initState() {
    super.initState();
    _locationPermissionHandler(() {
      _getCurrentLocation();
    });

    _locationPermissionHandler(() {
      _getStremedPosition();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
    _locationPermissionHandler(() {
      _getCurrentLocation();
    });

    _locationPermissionHandler(() {
      _getStremedPosition();
    });
  }

  Future<void> _locationPermissionHandler(VoidCallback startService) async {
    LocationPermission isPermitted = await Geolocator.checkPermission();

    if (isPermitted == LocationPermission.always ||
        isPermitted == LocationPermission.whileInUse) {
      // if permission granted
      final bool isEnabled = await Geolocator.isLocationServiceEnabled();

      if (isEnabled) {
        startService();
      } else {
        Geolocator.openLocationSettings();
      }
    } else {
      // if permission denied
      if (isPermitted == LocationPermission.deniedForever) {
        Geolocator.openAppSettings();
        return;
      }
      LocationPermission isRequestPermitted =
          await Geolocator.requestPermission();

      if (isRequestPermitted == LocationPermission.always ||
          isRequestPermitted == LocationPermission.whileInUse) {
        _locationPermissionHandler(startService);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
      ),
    );
    _currentPosition = LatLng(position.latitude, position.longitude);
    _updatePosition(_currentPosition);
    _updateMarker(_currentPosition);
  }

  void _getStremedPosition() {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 10,
        timeLimit: Duration(seconds: 10),
      ),
    ).listen((Position newPosition) {
      _currentPosition = LatLng(newPosition.latitude, newPosition.longitude);
      debugPrint(_currentPosition.toString());
    });
    _updatePosition(_currentPosition);
    _updatePolyline(_currentPosition);
    _updateMarker(_currentPosition);
  }

  void _updatePosition(LatLng newPosition) {
    _googleMapController?.animateCamera(
      CameraUpdate.newLatLng(newPosition),
    );
    if (mounted) {
      setState(() {});
    }
  }

  void _updateMarker(LatLng newPosition) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('current_position'),
        position: newPosition,
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet: '${newPosition.latitude},${newPosition.longitude}',
        ),
      ),
    );
  }

  void _updatePolyline(LatLng newPosition) {
    _polylinePoints.add(newPosition);
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('current_position'),
        visible: true,
        width: 5,
        color: Colors.green,
        jointType: JointType.round,
        points: _polylinePoints,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Google Map Apps',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: GoogleMap(
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: _onMapCreated,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 18,
        ),
        markers: _markers,
        polylines: _polylines,
        onTap: (LatLng latLng) {
          // print(latLng);
          debugPrint(latLng.toString());
        },
        // polylines: <Polyline>{
        //   Polyline(
        //     polylineId: const PolylineId('sample'),
        //     color: Colors.green,
        //     width: 10,
        //     visible: true,
        //     jointType: JointType.round,
        //     points: const [
        //       LatLng(23.819275382662664, 90.37404611706734),
        //       LatLng(23.81790127606468, 90.37502411752939),
        //     ],
        //     onTap: () {
        //       print('Tap on Polyline');
        //     },
        //   ),
        // },
      ),
    );
  }
}
