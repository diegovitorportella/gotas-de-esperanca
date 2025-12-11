import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/donation_location.dart';
import 'map_view_screen.dart';

// Classe auxiliar
class LocationWithDistance {
  final DonationLocation location;
  final double distanceInKm;

  LocationWithDistance({required this.location, required this.distanceInKm});
}

// Enum para os filtros
enum LocationFilter { todos, abertosAgora, abertosSabado }

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  bool _isLoading = true;
  LatLng? _userLocation;
  List<LocationWithDistance> _sortedLocations = [];
  LocationFilter _activeFilter = LocationFilter.todos;

  // Lista de locais
  final List<DonationLocation> _donationLocations = [
    DonationLocation(name: 'Hemocentro de BH (Sede)', address: 'Alameda Ezequiel Dias, 321 - Santa Efigênia', coordinates: LatLng(-19.9252, -43.9318), status: 'Aberto', operatingHours: '07h - 18h (Seg a Sáb)', estimatedWaitTime: '~30 min', urgentBloodTypes: ['O-', 'A+']),
    DonationLocation(name: 'Posto de Coleta Estação BH', address: 'Av. Cristiano Machado, 11833 - Venda Nova (Shopping Estação)', coordinates: LatLng(-19.8159, -43.9598), status: 'Aberto', operatingHours: '08h - 18h (Seg a Sex)', estimatedWaitTime: '~45 min', urgentBloodTypes: ['B-', 'AB+']),
    DonationLocation(name: 'Hospital Júlia Kubitschek', address: 'Av. Dr. Cristiano Rezende, 2745 - Milionários', coordinates: LatLng(-19.9675, -44.0178), status: 'Aberto', operatingHours: '07h - 12h (Seg a Sáb)', estimatedWaitTime: '~20 min', urgentBloodTypes: ['O+', 'A-']),
    DonationLocation(name: 'Vita Hemoterapia', address: 'R. Juiz de Fora, 941 - Barro Preto', coordinates: LatLng(-19.9245, -43.9495), status: 'Aberto', operatingHours: '07h - 16h (Seg a Sex)', estimatedWaitTime: '~25 min', urgentBloodTypes: ['A+', 'O-']),
    DonationLocation(name: 'Hospital da Baleia', address: 'R. Juramento, 1464 - Saudade', coordinates: LatLng(-19.9255, -43.8969), status: 'Aberto', operatingHours: '07h - 17h (Seg a Sex)', estimatedWaitTime: '~35 min', urgentBloodTypes: ['O-', 'B-']),
    DonationLocation(name: 'Santa Casa de BH', address: 'Av. Francisco Sales, 1111 - Santa Efigênia', coordinates: LatLng(-19.9224, -43.9296), status: 'Fechado', operatingHours: 'Abre às 07h', estimatedWaitTime: 'N/A', urgentBloodTypes: []),
    DonationLocation(name: 'Hospital Felício Rocho', address: 'Av. do Contorno, 9530 - Barro Preto', coordinates: LatLng(-19.9323, -43.9511), status: 'Aberto', operatingHours: '08h - 16h (Seg a Sex)', estimatedWaitTime: '~30 min', urgentBloodTypes: ['AB-', 'A+']),
    DonationLocation(name: 'Hospital Mater Dei', address: 'R. Mato Grosso, 1100 - Santo Agostinho', coordinates: LatLng(-19.9278, -43.9497), status: 'Fechado', operatingHours: 'Abre às 08h', estimatedWaitTime: 'N/A', urgentBloodTypes: []),
  ];

  @override
  void initState() {
    super.initState();
    _calculateDistances();
  }

  Future<void> _calculateDistances() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Serviço de localização desabilitado para ordenar a lista.')));
      setState(() => _isLoading = false); return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permissão de localização negada.')));
      setState(() => _isLoading = false); return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      final userLocation = LatLng(position.latitude, position.longitude);
      List<LocationWithDistance> locationsWithDistance = [];
      for (var location in _donationLocations) {
        final distanceInMeters = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, location.coordinates.latitude, location.coordinates.longitude);
        locationsWithDistance.add(LocationWithDistance(location: location, distanceInKm: distanceInMeters / 1000));
      }
      locationsWithDistance.sort((a, b) => a.distanceInKm.compareTo(b.distanceInKm));
      setState(() {
        _userLocation = userLocation;
        _sortedLocations = locationsWithDistance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _openMapRoute(double latitude, double longitude) async {
    // --- CORREÇÃO REAL: Inserindo as variáveis $latitude e $longitude na URL ---
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude'
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Erro ao abrir mapa: $e");
    }
  }

  bool _isLocationOpenNow(DonationLocation location) {
    if (location.status != 'Aberto') return false;

    final List<String> weekDays = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final now = DateTime.now();

    String currentDayString = DateFormat('E', 'pt_BR').format(now);
    currentDayString = currentDayString.replaceAll('.', '');
    currentDayString = currentDayString[0].toUpperCase() + currentDayString.substring(1);

    final currentHour = now.hour;
    final operatingHours = location.operatingHours;

    try {
      final parts = operatingHours.split('(');
      if (parts.length < 2) return false;

      final timePart = parts[0].replaceAll('h', '').trim();
      final dayPart = parts[1].replaceAll(')', '').trim();

      final timeSplit = timePart.split('-');
      final startHour = int.parse(timeSplit[0].trim());
      final endHour = int.parse(timeSplit[1].trim());

      bool isOpenToday = false;

      if (dayPart.contains(' a ')) {
        final daySplit = dayPart.split(' a ');
        final startDay = weekDays.indexOf(daySplit[0]);
        final endDay = weekDays.indexOf(daySplit[1]);
        final currentDayIndex = weekDays.indexOf(currentDayString);

        if (currentDayIndex == -1) {
          return false;
        }

        if (currentDayIndex >= startDay && currentDayIndex <= endDay) {
          isOpenToday = true;
        }
      } else if (dayPart.contains(currentDayString)) {
        isOpenToday = true;
      }

      if (isOpenToday && currentHour >= startHour && currentHour < endHour) {
        return true;
      }

    } catch (e) {
      return false;
    }

    return false;
  }

  List<LocationWithDistance> get _filteredLocations {
    if (_activeFilter == LocationFilter.abertosAgora) {
      return _sortedLocations.where((item) => _isLocationOpenNow(item.location)).toList();
    }
    if (_activeFilter == LocationFilter.abertosSabado) {
      return _sortedLocations.where((item) => item.location.operatingHours.contains('Sáb')).toList();
    }
    return _sortedLocations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locais de Doação'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver todos no mapa'),
              onPressed: _userLocation == null ? null : () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MapViewScreen(locations: _donationLocations, userLocation: _userLocation!)));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Todos'),
                  selected: _activeFilter == LocationFilter.todos,
                  onSelected: (selected) {
                    if (selected) setState(() => _activeFilter = LocationFilter.todos);
                  },
                ),
                ChoiceChip(
                  label: const Text('Abertos agora'),
                  selected: _activeFilter == LocationFilter.abertosAgora,
                  onSelected: (selected) {
                    if (selected) setState(() => _activeFilter = LocationFilter.abertosAgora);
                  },
                ),
                ChoiceChip(
                  label: const Text('Abertos Sábado'),
                  selected: _activeFilter == LocationFilter.abertosSabado,
                  onSelected: (selected) {
                    if (selected) setState(() => _activeFilter = LocationFilter.abertosSabado);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredLocations.isEmpty
                ? const Center(
              child: Text(
                'Nenhum local corresponde ao filtro selecionado.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final item = _filteredLocations[index];
                final location = item.location;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ExpansionTile(
                    title: Text(
                      location.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text('Aprox. ${item.distanceInKm.toStringAsFixed(1)} km de distância'),
                    leading: Icon(
                      Icons.circle,
                      color: location.status == 'Aberto' ? Colors.red.shade700 : Colors.grey,
                      size: 16,
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(location.address),
                            const SizedBox(height: 8),
                            Text('Status: ${location.status} (${location.operatingHours})'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.directions, size: 18),
                              label: const Text('Traçar Rota'),
                              onPressed: () {
                                _openMapRoute(
                                  location.coordinates.latitude,
                                  location.coordinates.longitude,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC62828),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}