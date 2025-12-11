import 'package:flutter/material.dart';
import 'calendario_screen.dart';

class SobreDoacaoScreen extends StatelessWidget {
  const SobreDoacaoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Doação'),
        backgroundColor: const Color(0xFFC62828), // Alterado
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Requisitos básicos para doar:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800, // Alterado
              ),
            ),
            const SizedBox(height: 16.0),
            _buildRequirementItem('Ter entre 16 e 69 anos', Icons.check_circle_outline),
            _buildRequirementItem('Pesar mais de 50kg', Icons.check_circle_outline),
            _buildRequirementItem('Estar saudável', Icons.check_circle_outline),
            const SizedBox(height: 32.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CalendarioScreen(lembretes: [], onSchedule: null,)), // Ajuste para o construtor
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Alterado
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.grey.shade700), // Alterado
          const SizedBox(width: 10.0),
          Text(text, style: const TextStyle(fontSize: 16.0)),
        ],
      ),
    );
  }
}