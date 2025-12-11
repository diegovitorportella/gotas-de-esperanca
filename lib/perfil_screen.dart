import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <--- Usamos SharedPreferences agora
import 'package:gotas_de_esperanca/login_screen.dart';
import 'models/achievement.dart';
import 'sobre_app_screen.dart';
import 'widgets/achievement_widget.dart';
import 'editar_perfil_screen.dart';

class PerfilScreen extends StatelessWidget {
  final int totalDoacoes;
  final DateTime? ultimaDoacao;
  final VoidCallback onRegistrarNovaDoacao;
  final List<Achievement> allAchievements;
  final String userName;
  final String? userBloodType;

  final Map<String, dynamic>? perfilData;
  final VoidCallback onProfileUpdated;

  const PerfilScreen({
    super.key,
    required this.totalDoacoes,
    required this.ultimaDoacao,
    required this.onRegistrarNovaDoacao,
    required this.allAchievements,
    required this.userName,
    required this.userBloodType,
    required this.perfilData,
    required this.onProfileUpdated,
  });

  String get proximaDoacao {
    if (ultimaDoacao == null) {
      return 'Você já pode doar!';
    }
    final proximaData = ultimaDoacao!.add(const Duration(days: 60));
    final hoje = DateTime.now();

    if (proximaData.isBefore(hoje)) {
      return 'Você já pode doar!';
    } else {
      return 'A partir de ${DateFormat('dd \'de\' MMMM \'de\' yyyy', 'pt_BR').format(proximaData)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.person, size: 60, color: Colors.grey.shade800),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(userName, style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _buildInfoRow(
                icon: Icons.bloodtype,
                label: 'Tipo Sanguíneo',
                value: userBloodType ?? 'Não informado'
            ),
            const SizedBox(height: 16),
            _buildInfoRow(icon: Icons.calendar_today, label: 'Próxima Doação', value: proximaDoacao),
            const SizedBox(height: 16),
            _buildInfoRow(icon: Icons.favorite, label: 'Total de Doações', value: '$totalDoacoes doações'),
            const SizedBox(height: 32),

            // Botão Editar Perfil
            OutlinedButton.icon(
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar Meu Perfil'),
              onPressed: () async {
                if (perfilData == null) return;

                final bool? foiAtualizado = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarPerfilScreen(
                      perfilData: perfilData!,
                    ),
                  ),
                );

                if (foiAtualizado == true && context.mounted) {
                  onProfileUpdated();
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade800,
                side: BorderSide(color: Colors.grey.shade400),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 16),

            // Botão Registrar Doação
            ElevatedButton(
              onPressed: onRegistrarNovaDoacao,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Registrei uma nova doação!'),
            ),
            const Divider(height: 40),
            Text('Minhas Conquistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16, mainAxisSpacing: 16),
              itemCount: allAchievements.length,
              itemBuilder: (context, index) {
                final achievement = allAchievements[index];
                final isUnlocked = totalDoacoes >= achievement.requiredDonations;
                return AchievementWidget(achievement: achievement, isUnlocked: isUnlocked);
              },
            ),
            const SizedBox(height: 24),

            // Botão Sobre o App
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline, color: Color(0xFFC62828)),
              title: const Text('Sobre o Gotas de Esperança'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SobreAppScreen()),
                );
              },
            ),
            const SizedBox(height: 24),

            // Botão SAIR (Logout Local)
            Center(
              child: TextButton(
                onPressed: () async {
                  // 1. Remove a flag de login
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);

                  if (context.mounted) {
                    // 2. Volta para a tela de Login
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                    );
                  }
                },
                child: const Text('Sair', style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFC62828)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        )
      ],
    );
  }
}