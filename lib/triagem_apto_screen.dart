import 'package:flutter/material.dart';

class TriagemAptoScreen extends StatelessWidget {
  const TriagemAptoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Alterado
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.grey.shade700, // Alterado
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                'Pré-Triagem Concluída!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800, // Alterado
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Parabéns! Pela nossa avaliação inicial, você está apto(a) para doar.\n\nLembre-se que esta é uma triagem preliminar. Uma avaliação final será feita no hemocentro.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  int count = 0;
                  Navigator.of(context).popUntil((_) => count++ >= 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC62828), // Alterado
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