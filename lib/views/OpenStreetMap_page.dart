import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
class OpenstreetmapPage extends StatefulWidget {
  const OpenstreetmapPage({super.key});

  @override
  State<OpenstreetmapPage> createState() => _OpenstreetmapPageState();
}

class _OpenstreetmapPageState extends State<OpenstreetmapPage> {
  final MapController _mapController = MapController();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text("Map"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(0,0),
              initialZoom: 2,
              minZoom: 0,
              maxZoom: 100,
            ),
            children: [
              TileLayer(
                  urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              )
            ],
          )
        ],
      ),
    );
  }
}
