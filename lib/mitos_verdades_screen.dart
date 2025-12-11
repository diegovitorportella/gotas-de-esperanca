import 'package:flutter/material.dart';
import 'models/myth.dart';

class MitosVerdadesScreen extends StatelessWidget {
  const MitosVerdadesScreen({super.key});

  final List<Myth> mythsList = const [
    Myth(
      question: 'Quem tem tatuagem não pode doar sangue?',
      isMyth: true,
      answer: 'Após 12 meses da realização da tatuagem, a doação é totalmente permitida. O prazo é necessário para garantir que não houve contaminação por doenças como hepatite.',
    ),
    Myth(
      question: 'Doar sangue vicia ou engrossa o sangue?',
      isMyth: true,
      answer: 'Seu corpo repõe o volume de sangue doado em até 24 horas e os glóbulos vermelhos em cerca de 4 semanas. A doação não causa nenhuma alteração na composição do seu sangue.',
    ),
    Myth(
      question: 'É preciso estar em jejum para doar?',
      isMyth: true,
      answer: 'Pelo contrário! É importante estar bem alimentado. Apenas evite alimentos muito gordurosos nas 3 horas que antecedem a doação.',
    ),
    Myth(
      question: 'Mulheres podem doar sangue durante o período menstrual?',
      isMyth: false,
      answer: 'Sim, a doação de sangue não interfere no ciclo menstrual e nem causa prejuízos à saúde da mulher. O volume de sangue coletado é pequeno e não afeta o organismo.',
    ),
    Myth(
      question: 'Doar sangue é um processo demorado?',
      isMyth: true,
      answer: 'O processo todo, desde o cadastro até o lanche, leva cerca de 1 hora. A coleta de sangue em si dura no máximo 15 minutos. É um pequeno tempo que pode salvar até 4 vidas!',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mitos e Verdades'),
        backgroundColor: const Color(0xFFC62828), // Alterado
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mythsList.length,
        itemBuilder: (context, index) {
          final myth = mythsList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2.0,
            child: ExpansionTile(
              leading: Icon(
                myth.isMyth ? Icons.cancel_outlined : Icons.check_circle_outline,
                color: myth.isMyth ? Colors.red.shade700 : Colors.grey.shade700, // Alterado
              ),
              title: Text(
                myth.question,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Text(
                    '${myth.isMyth ? "MITO" : "VERDADE"}: ${myth.answer}',
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}