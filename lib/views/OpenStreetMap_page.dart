import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
class OpenstreetmapPage extends StatefulWidget {
  final String trackedUserId;
  const OpenstreetmapPage({super.key, required this.trackedUserId});
  @override
  State<OpenstreetmapPage> createState() => _OpenstreetmapPageState();
}

class _OpenstreetmapPageState extends State<OpenstreetmapPage> {
  final MapController _mapController = MapController();
  LatLng? otherUserLocation;
  Timer? _timer;
  List<LatLng> pathPoints = [];



  @override
  void initState() {
    super.initState();
    fetchLocation();
    _timer = Timer.periodic(Duration(seconds: 5), (_) => fetchLocation());
  }



  Future<void> fetchLocation() async {
    try {
      final response = await Supabase.instance.client
          .from('locations')
          .select('latitude, longitude')
          .eq('user_id', widget.trackedUserId)
          .order('updated_at', ascending: false)
          .limit(1)
          .single();

      if (response != null) {
        final newPoint = LatLng(response['latitude'], response['longitude']);

        setState(() {
          otherUserLocation = newPoint;
          pathPoints.add(newPoint);
        });

        _mapController.move(newPoint, _mapController.camera.zoom);
      }
    } catch (e) {
      debugPrint('Erreur lors de la récupération de la position : $e');
    }
  }






  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking de l\'utilisateur aveugle'),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: otherUserLocation ?? LatLng(0, 0),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (pathPoints.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: pathPoints,
                  strokeWidth: 4.0,
                  color: Colors.red,
                ),
              ],
            ),
          if (otherUserLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: otherUserLocation!,
                  width: 60,
                  height: 60,
                  child: Icon(
                    Icons.person_pin_circle,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              ],
            ),
          CurrentLocationLayer(),
          // kt3tina la position actuelle dyal l'aveugle f la map
        ],


      ),
    );
  }
}