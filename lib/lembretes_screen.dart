import 'package:flutter/material.dart';

class LembretesScreen extends StatefulWidget {
  // --- TIPO ALTERADO ---
  final List<Map<String, dynamic>> lembretes;
  // --- FUNÇÃO ADICIONADA ---
  final Function(int) onRemoveLembrete; // Função para remover no banco

  const LembretesScreen({
    super.key,
    required this.lembretes,
    required this.onRemoveLembrete, // Adicionado ao construtor
  });

  @override
  State<LembretesScreen> createState() => _LembretesScreenState();
}

class _LembretesScreenState extends State<LembretesScreen> {

  // --- FUNÇÃO _removerLembrete MODIFICADA ---
  void _removerLembrete(int id) {
    // Chama a função da MainScreen para remover do banco
    widget.onRemoveLembrete(id);
    // Não é mais necessário setState aqui
  }

  @override
  Widget build(BuildContext context) {
    // Usa diretamente a lista recebida via widget
    final lembretesParaExibir = widget.lembretes;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Agendamentos'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: lembretesParaExibir.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'Nenhum agendamento realizado.\n\nVolte para a tela de Campanhas para agendar sua doação.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      )
          : ListView.builder(
        itemCount: lembretesParaExibir.length,
        itemBuilder: (context, index) {
          final lembrete = lembretesParaExibir[index];
          // Pega o ID que veio do banco de dados
          final int lembreteId = lembrete['id'] as int; // Garantir que é int

          return LembreteCard(
            // Converte valores para String para exibição
            data: lembrete['data']?.toString() ?? 'Data inválida',
            local: lembrete['local']?.toString() ?? 'Local inválido',
            hora: lembrete['hora']?.toString() ?? 'Hora inválida',
            onRemove: () => _removerLembrete(lembreteId), // Passa o ID correto
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context); // Apenas volta para a tela anterior
        },
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.calendar_today),
        label: const Text('Voltar para Campanhas'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// Classe LembreteCard (sem alteração)
class LembreteCard extends StatelessWidget {
  final String data;
  final String local;
  final String hora;
  final VoidCallback onRemove;

  const LembreteCard({
    super.key,
    required this.data,
    required this.local,
    required this.hora,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded( // Adicionado Expanded para evitar overflow de texto
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doação Agendada',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '$data - às $hora',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    local,
                    style: const TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade700),
              tooltip: 'Remover agendamento',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}