import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:gotas_de_esperanca/models/donation_location.dart';
import 'package:gotas_de_esperanca/widgets/location_details_sheet.dart';

class MapViewScreen extends StatelessWidget {
  final List<DonationLocation> locations;
  final LatLng userLocation;

  const MapViewScreen({
    super.key,
    required this.locations,
    required this.userLocation,
  });

  void _showLocationDetails(BuildContext context, DonationLocation location) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return LocationDetailsSheet(location: location);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = locations.map((location) {
      return Marker(
        point: location.coordinates,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showLocationDetails(context, location),
          child: Tooltip(
            message: location.name,
            child: Icon(
              Icons.location_pin,
              size: 50,
              color: location.status == 'Aberto' ? const Color(0xFFC62828) : Colors.grey, // Alterado
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais no Mapa'),
        backgroundColor: const Color(0xFFC62828), // Alterado
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: userLocation,
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.diw.gotas_de_esperanca',
          ),
          MarkerLayer(markers: markers),
        ],
      ),
    );
  }
}