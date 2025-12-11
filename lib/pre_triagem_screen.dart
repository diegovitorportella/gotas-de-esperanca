import 'package:flutter/material.dart';
import 'models/pre_triagem_question.dart';
import 'resultado_apto_screen.dart';
import 'resultado_inapto_screen.dart';

class PreTriagemScreen extends StatefulWidget {
  const PreTriagemScreen({super.key});

  @override
  State<PreTriagemScreen> createState() => _PreTriagemScreenState();
}

class _PreTriagemScreenState extends State<PreTriagemScreen> {
  int _currentQuestionIndex = 0;
  TriagemStatus _finalStatus = TriagemStatus.apto;
  String _finalMessage = 'Parabéns! Pela nossa avaliação, você está apto(a). Lembre-se que a avaliação final será feita no hemocentro.';

  final List<PreTriagemQuestion> _questions = [
    PreTriagemQuestion(
      category: 'Requisitos Básicos',
      text: 'Você tem entre 18 e 69 anos e pesa mais de 50 kg?',
      type: QuestionType.simNao,
      rule: (answer) {
        if (answer == false) {
          return TriagemResult(status: TriagemStatus.inaptoTemporariamente, message: 'É necessário ter entre 18 e 69 anos e pesar no mínimo 50 kg para doar.');
        }
        return TriagemResult(status: TriagemStatus.apto, message: '');
      },
    ),
    PreTriagemQuestion(
      category: 'Saúde Atual',
      text: 'Teve febre, gripe ou resfriado nos últimos 15 dias?',
      type: QuestionType.simNao,
      rule: (answer) {
        if (answer == true) {
          return TriagemResult(status: TriagemStatus.inaptoTemporariamente, message: 'Aguarde 15 dias após o término completo dos sintomas para poder doar novamente.');
        }
        return TriagemResult(status: TriagemStatus.apto, message: '');
      },
    ),
    PreTriagemQuestion(
      category: 'Saúde Atual',
      text: 'Está a tomar algum medicamento contínuo ou tomou antibióticos nos últimos 15 dias?',
      type: QuestionType.simNao,
      rule: (answer) {
        if (answer == true) {
          return TriagemResult(status: TriagemStatus.aptoComRestricao, message: 'A sua aptidão será confirmada na triagem presencial. Por favor, leve o nome do(s) medicamento(s) que está a utilizar.');
        }
        return TriagemResult(status: TriagemStatus.apto, message: '');
      },
    ),
    PreTriagemQuestion(
      category: 'Procedimentos Recentes',
      text: 'Fez alguma tatuagem, piercing ou acupuntura nos últimos 6 meses?',
      type: QuestionType.simNao,
      rule: (answer) {
        if (answer == true) {
          return TriagemResult(status: TriagemStatus.inaptoTemporariamente, message: 'É necessário aguardar 6 meses após a realização de tatuagens, piercings ou acupuntura para poder doar.');
        }
        return TriagemResult(status: TriagemStatus.apto, message: '');
      },
    ),
    PreTriagemQuestion(
      category: 'Histórico Médico',
      text: 'Já teve hepatite após os 11 anos de idade?',
      type: QuestionType.simNao,
      rule: (answer) {
        if (answer == true) {
          return TriagemResult(status: TriagemStatus.inaptoDefinitivamente, message: 'Infelizmente, um histórico de hepatite após os 11 anos é um impedimento definitivo para a doação de sangue, visando a segurança do recetor.');
        }
        return TriagemResult(status: TriagemStatus.apto, message: '');
      },
    ),
  ];

  void _processAnswer(dynamic answer) {
    final currentQuestion = _questions[_currentQuestionIndex];
    final result = currentQuestion.rule(answer);

    if (result.status == TriagemStatus.inaptoTemporariamente || result.status == TriagemStatus.inaptoDefinitivamente) {
      _navigateToResult(result.status, result.message); // Inapto
      return;
    }

    if (result.status == TriagemStatus.aptoComRestricao) {
      _finalStatus = TriagemStatus.aptoComRestricao;
      _finalMessage = result.message;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _navigateToResult(_finalStatus, _finalMessage); // Apto ou Apto com Restrição
    }
  }

  // --- FUNÇÃO MODIFICADA PARA async E PARA RETORNAR VALOR ---
  Future<void> _navigateToResult(TriagemStatus status, String message) async {
    Widget resultScreen;
    switch (status) {
      case TriagemStatus.apto:
        resultScreen = ResultadoAptoScreen(message: message);
        break;
      case TriagemStatus.aptoComRestricao:
        resultScreen = ResultadoAptoScreen(message: message, comRestricao: true);
        break;
      case TriagemStatus.inaptoTemporariamente:
        resultScreen = ResultadoInaptoScreen(message: message, isDefinitivo: false);
        break;
      case TriagemStatus.inaptoDefinitivamente:
        resultScreen = ResultadoInaptoScreen(message: message, isDefinitivo: true);
        break;
    }

    // Navega para a tela de resultado E ESPERA ELA RETORNAR (true ou false)
    final bool? isApto = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => resultScreen),
    );

    // Agora, fecha a tela de Pré-Triagem e retorna o resultado (true/false)
    // para a tela de Agendamento.
    if (mounted) {
      Navigator.pop(context, isApto ?? false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pré-Triagem: ${question.category}'),
        backgroundColor: const Color(0xFFC62828), // Alterado
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade300, color: const Color(0xFFC62828)), // Alterado
                const SizedBox(height: 40),
                Text('Pergunta ${_currentQuestionIndex + 1} de ${_questions.length}', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                const SizedBox(height: 16),
                Text(question.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              ],
            ),
            if (question.type == QuestionType.simNao)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildAnswerButton(text: 'Não', onPressed: () => _processAnswer(false), color: Colors.grey.shade600), // Alterado
                  _buildAnswerButton(text: 'Sim', onPressed: () => _processAnswer(true), color: const Color(0xFFC62828)), // Alterado
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerButton({required String text, required VoidCallback onPressed, required Color color}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(120, 50),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: Text(text),
    );
  }
}