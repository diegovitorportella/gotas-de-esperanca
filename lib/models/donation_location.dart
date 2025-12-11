import 'package:latlong2/latlong.dart';

class DonationLocation {
  final String name;
  final String address;
  final LatLng coordinates;
  final String status;
  final String operatingHours;
  final String estimatedWaitTime;
  final List<String> urgentBloodTypes;

  DonationLocation({
    required this.name,
    required this.address,
    required this.coordinates,
    required this.status,
    required this.operatingHours,
    required this.estimatedWaitTime,
    required this.urgentBloodTypes,
  });
}