import 'package:flutter/material.dart';
import 'models/donation_event.dart';
import 'pre_triagem_screen.dart';
// Importe as telas de resultado para verificar o status
import 'models/pre_triagem_question.dart';
import 'resultado_apto_screen.dart';
import 'resultado_inapto_screen.dart';


class AgendamentoScreen extends StatefulWidget {
  final DonationEvent event;
  final Function(String, String, String) onSchedule;

  const AgendamentoScreen({
    super.key,
    required this.event,
    required this.onSchedule,
  });

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  String? _selectedTime;

  // --- FUNÇÃO _showConfirmationDialog FOI REMOVIDA ---
  // (Substituída por _confirmarEAgendar e _showSuccessDialog)

  // --- NOVA FUNÇÃO DE SUCESSO ---
  // Mostra um diálogo simples *após* o agendamento real.
  Future<void> _showSuccessDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Agendamento Confirmado!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Sua doação para ${widget.event.date} às $_selectedTime foi agendada com sucesso. Vemos você lá!'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ótimo!'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Fecha o dialog
                Navigator.of(context).pop(); // Fecha a tela de Agendamento
              },
            ),
          ],
        );
      },
    );
  }

  // --- NOVA FUNÇÃO PRINCIPAL PARA O BOTÃO ---
  Future<void> _confirmarEAgendar() async {
    if (_selectedTime == null) return;

    // 1. NAVEGA PARA A PRÉ-TRIAGEM PRIMEIRO E ESPERA UM RESULTADO
    final bool? isApto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PreTriagemScreen()),
    );

    // 2. VERIFICA O RESULTADO RETORNADO
    if (isApto == true) {
      // 3. SE APTO (true), SALVA NO BANCO DE DADOS
      widget.onSchedule(
        widget.event.date,
        widget.event.location,
        _selectedTime!,
      );

      // 4. MOSTRA O DIÁLOGO DE SUCESSO FINAL
      if (mounted) {
        _showSuccessDialog();
      }
    } else {
      // 5. SE INAPTO (false ou null/voltou), NÃO FAZ NADA.
      // O usuário já viu a tela de Inapto e ela foi fechada.
      // A tela de Agendamento permanece aberta para ele.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha um Horário'),
        backgroundColor: const Color(0xFFC62828), // Alterado
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800, // Alterado
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(icon: Icons.calendar_today, text: widget.event.date),
            const SizedBox(height: 8),
            _buildInfoRow(icon: Icons.location_on, text: widget.event.location),
            const Divider(height: 40),
            const Text(
              'Horários Disponíveis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: widget.event.availableTimes.map((time) {
                final isSelected = _selectedTime == time;
                return ChoiceChip(
                  label: Text(time),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTime = time;
                    });
                  },
                  backgroundColor: Colors.grey.shade200,
                  selectedColor: Colors.red.shade100, // Alterado
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFB71C1C) : Colors.black, // Alterado
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            ElevatedButton(
              // --- LÓGICA DO BOTÃO ATUALIZADA ---
              onPressed: _selectedTime == null ? null : _confirmarEAgendar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC62828), // Alterado
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: const Text('Confirmar Agendamento'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}