import 'package:flutter/material.dart';

class Achievement {
  final String title;
  final String description;
  final IconData icon;
  final int requiredDonations;

  // Adicione a palavra-chave "const" aqui
  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredDonations,
  });
}