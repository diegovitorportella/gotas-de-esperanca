import 'package:flutter/material.dart';

class TriagemInaptoScreen extends StatelessWidget {
  final String reason;

  const TriagemInaptoScreen({super.key, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                color: Colors.orange.shade800,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Agradecemos o seu interesse!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
                ),
              ),
              const SizedBox(height: 16),
              // const removido daqui
              Text(
                'No momento, você não pode doar pelo seguinte motivo:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.brown.shade800),
              ),
              const SizedBox(height: 8),
              // const removido daqui
              Text(
                reason,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown.shade900),
              ),
              const SizedBox(height: 16),
              // const removido daqui
              Text(
                'Por favor, verifique os critérios novamente no futuro. A sua vontade de ajudar já faz a diferença!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.brown.shade800),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  int count = 0;
                  // Volta 2 telas para a tela de campanhas
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
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