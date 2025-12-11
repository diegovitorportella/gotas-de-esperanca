import 'package:flutter/material.dart';
import 'lembretes_screen.dart';
import 'agendamento_screen.dart';
import 'models/donation_event.dart';

class CalendarioScreen extends StatelessWidget {
  // --- TIPO ALTERADO ---
  final List<Map<String, dynamic>> lembretes;
  final Function(String, String, String) onSchedule;
  // --- FUNÇÃO ADICIONADA ---
  final Function(int) onRemoveLembrete; // Função para remover lembrete

  const CalendarioScreen({
    super.key,
    required this.lembretes,
    required this.onSchedule,
    required this.onRemoveLembrete, // Adicionado ao construtor
  });

  // Lista de eventos (sem alteração)
  final List<DonationEvent> _donationEvents = const [
    DonationEvent(
      title: 'Campanha Salve Vidas no Parque',
      date: '15 de Novembro',
      location: 'Parque Central',
      availableTimes: ['09:00', '09:30', '10:00', '11:15', '14:00'],
    ),
    DonationEvent(
      title: 'Doação de Sangue no Hospital',
      date: '18 de Novembro',
      location: 'Hospital Municipal',
      availableTimes: ['10:00', '10:45', '11:30', '13:00', '13:45', '15:00'],
    ),
    DonationEvent(
      title: 'Hemocentro de Portas Abertas',
      date: '25 de Novembro',
      location: 'Hemocentro Principal',
      availableTimes: ['08:15', '09:00', '10:30'],
    ),
    // Adicione mais eventos se necessário
  ];

  void _navigateToAgendamento(BuildContext context, DonationEvent event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AgendamentoScreen(
          event: event,
          onSchedule: onSchedule,
        ),
      ),
    );
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
        decoration: const BoxDecoration( // Mantém a imagem de fundo
          image: DecorationImage(
            image: AssetImage("assets/images/tela_calendario.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: _donationEvents.length,
          itemBuilder: (context, index) {
            final event = _donationEvents[index];
            return DonationEventCard(
              event: event,
              onAgendar: () => _navigateToAgendamento(context, event),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => LembretesScreen(
                  lembretes: lembretes, // Passa a lista recebida
                  onRemoveLembrete: onRemoveLembrete, // --- PASSA A FUNÇÃO ---
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
}

// Classe DonationEventCard (sem alteração)
class DonationEventCard extends StatelessWidget {
  final DonationEvent event;
  final VoidCallback onAgendar;

  const DonationEventCard({
    super.key,
    required this.event,
    required this.onAgendar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
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
            Text(
              event.date,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              event.location,
              style: const TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: onAgendar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Agendar Doação'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}