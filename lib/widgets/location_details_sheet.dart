import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/donation_location.dart';

class LocationDetailsSheet extends StatelessWidget {
  final DonationLocation location;

  const LocationDetailsSheet({super.key, required this.location});

  Future<void> _openMap(BuildContext context, double latitude, double longitude) async {
    // --- CORREÇÃO REAL: Inserindo as variáveis $latitude e $longitude na URL ---
    final Uri googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude'
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        // Tenta abrir mesmo se o canLaunchUrl falhar (comum em alguns Androids)
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao tentar abrir o mapa: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              location.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              location.address,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const Divider(height: 32),
            _buildInfoRow(
              icon: Icons.circle,
              iconColor: location.status == 'Aberto' ? Colors.red.shade700 : Colors.grey,
              label: 'Status',
              value: location.status,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.access_time_filled,
              label: 'Horário',
              value: location.operatingHours,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.hourglass_bottom,
              label: 'Espera Estimada',
              value: location.estimatedWaitTime,
            ),
            const SizedBox(height: 16),
            _buildUrgencyRow('Urgência', location.urgentBloodTypes),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions),
              label: const Text('Traçar Rota'),
              onPressed: () {
                _openMap(context, location.coordinates.latitude, location.coordinates.longitude);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Fechar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, String label = '', String value = '', Color iconColor = const Color(0xFFC62828)}) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 16),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildUrgencyRow(String label, List<String> bloodTypes) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.bloodtype, color: Color(0xFFC62828), size: 20),
        const SizedBox(width: 16),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: bloodTypes.map((type) => Chip(
              label: Text(type, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.red.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
          ),
        ),
      ],
    );
  }
}