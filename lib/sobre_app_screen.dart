import 'package:flutter/material.dart';

class SobreAppScreen extends StatelessWidget {
  const SobreAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre o Gotas de Esperança'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Nossa Missão',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'O "Gotas de Esperança" é um projeto acadêmico criado para a disciplina de Desenvolvimento de Aplicações Móveis. '
                  'Nosso objetivo é facilitar e incentivar a doação de sangue, conectando doadores a hemocentros de forma inteligente e eficiente.',
              style: TextStyle(fontSize: 16.0, height: 1.5),
            ),
            const SizedBox(height: 32.0),
            Text(
              'Desenvolvedores',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16.0),
            // --- LISTA DE DESENVOLVEDORES ATUALIZADA ---
            _buildDeveloperInfo('Eduardo Alves Salgado Lisboa Oliveira', 'QA/P.O'),
            const SizedBox(height: 12.0),
            _buildDeveloperInfo('Filipe Quaresma Pereira', 'Developer/QA'),
            const SizedBox(height: 12.0),
            _buildDeveloperInfo('Robson Duarte Vicente', 'Developer/QA'),
            const SizedBox(height: 12.0),
            _buildDeveloperInfo('Vinicius Cezar Pereira Menezes', 'Product Manager'),
            // --- FIM DA ATUALIZAÇÃO ---
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para formatar as informações
  Widget _buildDeveloperInfo(String name, String role) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
        ),
        Text(
          role,
          style: TextStyle(fontSize: 14.0, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}