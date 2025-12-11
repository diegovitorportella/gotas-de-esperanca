import 'package:flutter/material.dart';
import '../models/achievement.dart';

class AchievementWidget extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementWidget({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  // Em achievement_widget.dart
  @override
  Widget build(BuildContext context) {
    final Color color = isUnlocked ? const Color(0xFFC62828) : Colors.grey.shade400;
    final Color iconColor = isUnlocked ? Colors.white : Colors.grey.shade600;

    return Tooltip(
      message: isUnlocked
          ? achievement.description
          : 'Doe ${achievement.requiredDonations} vez(es) para desbloquear',
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
        children: [
          CircleAvatar(
            radius: 30, // <--- Diminuir um pouco o raio? (antes era 35)
            backgroundColor: color,
            child: Icon(achievement.icon, size: 35, color: iconColor), // <--- Diminuir ícone? (antes era 40)
          ),
          const SizedBox(height: 6), // <--- Diminuir espaçamento? (antes era 8)
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            maxLines: 2, // Permite que o texto quebre em 2 linhas
            overflow: TextOverflow.ellipsis, // Adiciona '...' se ainda não couber
            style: TextStyle(
              fontSize: 12, // <--- Diminuir tamanho da fonte?
              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
              color: isUnlocked ? Colors.black : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}