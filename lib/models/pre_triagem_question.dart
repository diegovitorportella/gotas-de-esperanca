// Define os possíveis status do resultado da triagem
enum TriagemStatus { apto, aptoComRestricao, inaptoTemporariamente, inaptoDefinitivamente }

// Define o tipo de resposta esperado para cada pergunta
enum QuestionType { simNao, data, numero }

class PreTriagemQuestion {
  final String text;
  final String category;
  final QuestionType type;

  // A regra é uma função que avalia a resposta e retorna um resultado
  final TriagemResult Function(dynamic) rule;

  const PreTriagemQuestion({
    required this.text,
    required this.category,
    required this.type,
    required this.rule,
  });
}

// Classe para encapsular o resultado da avaliação de uma pergunta
class TriagemResult {
  final TriagemStatus status;
  final String message;

  TriagemResult({required this.status, required this.message});
}