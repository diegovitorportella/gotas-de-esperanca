import 'package:flutter/material.dart';
import 'mitos_verdades_screen.dart';

class HomeScreenApp extends StatelessWidget {
  final DateTime? ultimaDoacao;
  final Function(int) onNavigate;
  final String userName; // --- ADICIONE O NOME DO USUÁRIO ---

  const HomeScreenApp({
    super.key,
    required this.ultimaDoacao,
    required this.onNavigate,
    required this.userName, // --- ADICIONE AO CONSTRUTOR ---
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/tela_inicioapp.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildStatusCard(context),
                const SizedBox(height: 40),
                Text(
                  // --- ATUALIZE A MENSAGEM DE BOAS-VINDAS ---
                  'Bem-vindo, $userName!',
                  // --- FIM DA ATUALIZAÇÃO ---
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Obrigado por fazer a diferença. Navegue pela app para encontrar locais de doação e agendar o seu lembrete.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                Card(
                  elevation: 2.0,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                              const MitosVerdadesScreen()));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Icon(Icons.quiz_outlined,
                              color: Color(0xFFC62828), size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mitos e Verdades',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade800)),
                                const SizedBox(height: 4),
                                const Text(
                                    'Tire as suas dúvidas sobre a doação de sangue.'),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (O restante do arquivo _buildStatusCard, _buildReadyToDonateCard, _buildWaitingCard não precisa de alteração) ...
  Widget _buildStatusCard(BuildContext context) {
    if (ultimaDoacao == null) {
      return _buildReadyToDonateCard(context);
    }

    final proximaData = ultimaDoacao!.add(const Duration(days: 60));
    final hoje = DateTime.now();
    final difference = proximaData.difference(hoje);

    if (difference.isNegative) {
      return _buildReadyToDonateCard(context);
    } else {
      return _buildWaitingCard(difference.inDays + 1);
    }
  }

  // Card "Você já pode doar!" ATUALIZADO
  Widget _buildReadyToDonateCard(BuildContext context) {
    return Card(
      color: Colors.black.withOpacity(0.5), // Fundo semi-transparente
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          onNavigate(1);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Você já pode doar!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Encontre um local de doação perto de você.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Card "Contagem Regressiva" ATUALIZADO
  Widget _buildWaitingCard(int daysLeft) {
    return Card(
      color: Colors.black.withOpacity(0.5), // Fundo semi-transparente
      elevation: 0, // Sem sombra
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Bordas arredondadas
      ),
      child: InkWell(
        onTap: () {
          onNavigate(3);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.white, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contagem Regressiva',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Texto branco
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Faltam $daysLeft dias para você poder doar novamente.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9), // Texto com leve transparência
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}