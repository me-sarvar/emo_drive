import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<Set<Polyline>> getPolyline({
  required LatLng origin,
  required LatLng destination,
}) async {
  Set<Polyline> polylines = {};
  final originStr = '${origin.latitude},${origin.longitude}';
  final destinationStr = '${destination.latitude},${destination.longitude}';

  // Call the Flask backend instead of Google Maps API directly
  final response = await http.get(Uri.parse(
      'http://localhost:5000/getPolyline?origin=$originStr&destination=$destinationStr&mode=driving'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    List<PointLatLng> points = PolylinePoints()
        .decodePolyline(data['routes'][0]['overview_polyline']['points']);

    polylines.add(Polyline(
      polylineId: PolylineId('overview_polyline'),
      color: Colors.red,
      width: 5,
      points: points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
    ));
  } else {
    print("Failed to load polyline: ${response.statusCode}");
  }

  return polylines;
}

Set<Marker> getMarkers(LatLng origin, LatLng destination) {
  return {
    Marker(
      markerId: MarkerId('origin'),
      position: origin,
      infoWindow: InfoWindow(
        title: 'Starting Point',
        snippet: 'GooglePlex',
      ),
    ),
    Marker(
      markerId: MarkerId('destination'),
      position: destination,
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: 'Lake',
      ),
    ),
  };
}
