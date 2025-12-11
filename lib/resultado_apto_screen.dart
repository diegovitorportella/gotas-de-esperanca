import 'package:flutter/material.dart';

class ResultadoAptoScreen extends StatelessWidget {
  final String message;
  final bool comRestricao;

  const ResultadoAptoScreen({
    super.key,
    required this.message,
    this.comRestricao = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comRestricao ? Colors.amber.shade50 : Colors.grey.shade100, // Alterado
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                comRestricao ? Icons.info_outline : Icons.check_circle,
                color: comRestricao ? Colors.amber.shade800 : Colors.grey.shade700, // Alterado
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                comRestricao ? 'Apto com Restrição' : 'Pré-Triagem Concluída!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: comRestricao ? Colors.amber.shade900 : Colors.grey.shade800, // Alterado
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                // --- BOTÃO MODIFICADO ---
                // Fecha esta tela e retorna 'true' (Apto) para a PreTriagemScreen
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: comRestricao ? Colors.amber.shade700 : const Color(0xFFC62828), // Alterado
                  foregroundColor: Colors.white,
                ),
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}