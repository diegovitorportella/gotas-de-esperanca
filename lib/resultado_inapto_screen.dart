import 'package:flutter/material.dart';

class ResultadoInaptoScreen extends StatelessWidget {
  final String message;
  final bool isDefinitivo;

  const ResultadoInaptoScreen({
    super.key,
    required this.message,
    required this.isDefinitivo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDefinitivo ? Colors.grey.shade300 : Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDefinitivo ? Icons.block : Icons.cancel,
                color: isDefinitivo ? Colors.black45 : Colors.red.shade700,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                isDefinitivo ? 'Inapto Definitivamente' : 'Inapto Temporariamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDefinitivo ? Colors.black54 : Colors.red.shade800,
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
                // Fecha esta tela e retorna 'false' (Inapto) para a PreTriagemScreen
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDefinitivo ? Colors.grey.shade600 : Colors.red.shade700,
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