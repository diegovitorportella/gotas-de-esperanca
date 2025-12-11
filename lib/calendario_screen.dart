import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'lembretes_screen.dart';
import 'agendamento_screen.dart';
import 'models/donation_event.dart';

class CalendarioScreen extends StatefulWidget {
  final List<Map<String, dynamic>> lembretes;
  final Function(String, String, String) onSchedule;
  final Function(int) onRemoveLembrete;

  const CalendarioScreen({
    super.key,
    required this.lembretes,
    required this.onSchedule,
    required this.onRemoveLembrete,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final DatabaseReference _campanhasRef = FirebaseDatabase.instance.ref('campanhas');

  void _navigateToAgendamento(BuildContext context, DonationEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendamentoScreen(
          event: event,
          onSchedule: widget.onSchedule,
        ),
      ),
    );
  }

  bool _isEventoFuturo(String dataString) {
    try {
      final dataEvento = DateTime.parse(dataString);
      final hoje = DateTime.now();
      final hojeZerado = DateTime(hoje.year, hoje.month, hoje.day);
      return dataEvento.isAtSameMomentAs(hojeZerado) || dataEvento.isAfter(hojeZerado);
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campanhas de Doação'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/tela_calendario.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<DatabaseEvent>(
          stream: _campanhasRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)));
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Erro ao carregar campanhas.'));
            }

            if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
              return _buildEmptyState(message: 'Nenhuma campanha encontrada.');
            }

            try {
              final rawData = snapshot.data!.snapshot.value;
              final List<DonationEvent> eventosCarregados = [];

              if (rawData is Map) {
                rawData.forEach((key, value) {
                  final event = DonationEvent.fromMap(key.toString(), value as Map);
                  if (_isEventoFuturo(event.date)) {
                    eventosCarregados.add(event);
                  }
                });
              } else if (rawData is List) {
                for (var i = 0; i < rawData.length; i++) {
                  if (rawData[i] != null) {
                    final event = DonationEvent.fromMap(i.toString(), rawData[i] as Map);
                    if (_isEventoFuturo(event.date)) {
                      eventosCarregados.add(event);
                    }
                  }
                }
              }

              eventosCarregados.sort((a, b) => a.date.compareTo(b.date));

              if (eventosCarregados.isEmpty) {
                return _buildEmptyState(message: 'Sem campanhas futuras.');
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: eventosCarregados.length,
                itemBuilder: (context, index) {
                  return DonationEventCard(
                    event: eventosCarregados[index],
                    onAgendar: () => _navigateToAgendamento(context, eventosCarregados[index]),
                  );
                },
              );
            } catch (e) {
              return _buildEmptyState(message: 'Erro ao processar dados.');
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LembretesScreen(
                  lembretes: widget.lembretes,
                  onRemoveLembrete: widget.onRemoveLembrete,
                )),
          );
        },
        label: const Text('Meus Agendamentos'),
        icon: const Icon(Icons.list),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildEmptyState({required String message}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }
}

class DonationEventCard extends StatelessWidget {
  final DonationEvent event;
  final VoidCallback onAgendar;

  const DonationEventCard({
    super.key,
    required this.event,
    required this.onAgendar,
  });

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat("dd 'de' MMMM", 'pt_BR').format(date);
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              event.title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Color(0xFFC62828)),
                const SizedBox(width: 8),
                Text(
                  _formatDate(event.date),
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  event.location,
                  style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onAgendar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Agendar Doação'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}