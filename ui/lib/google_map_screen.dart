import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'map_helpers.dart'; // Import the helper file

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  GoogleMapScreenState createState() => GoogleMapScreenState();
}

class GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  // final LatLng _sCHU = LatLng(
  //     36.770875, 126.932816);
  // final LatLng _mSinchang = LatLng(
  //     36.772200, 126.950210);
  final LatLng _kGooglePlex = LatLng(37.42218188149784, -122.08533493106144);
  final LatLng _kApplePark = LatLng(37.33476320001167, -122.00901491763315);

  @override
  void initState() {
    super.initState();
    _initializeMapData();
  }

  Future<void> _initializeMapData() async {
    // Get and set polylines
    _polylines = await getPolyline(
      origin: _kGooglePlex,
      destination: _kApplePark,
      // origin: _sCHU,
      // destination: _mSinchang,
    );

    _markers = getMarkers(_kGooglePlex, _kApplePark);
    // _markers = getMarkers(_sCHU, _mSinchang);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _kGooglePlex,
          zoom: 12.0,
        ),
        polylines: _polylines,
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
