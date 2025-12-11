import 'package:flutter/material.dart';
import 'home_screen_app.dart';
import 'mapa_screen.dart';
import 'calendario_screen.dart';
import 'perfil_screen.dart';
import 'models/achievement.dart';
import 'helpers/database_helper.dart';
// --- 1. IMPORTAÇÃO DO FIREBASE ADICIONADA ---
import 'package:firebase_database/firebase_database.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isLoadingData = true;

  int _totalDoacoes = 0;
  DateTime? _ultimaDoacao;
  List<Map<String, dynamic>> _lembretes = [];
  String _userName = 'Doador';
  String? _userBloodType;
  Map<String, dynamic>? _perfilData;

  final List<Achievement> _allAchievements = const [
    Achievement(title: 'Iniciante Solidário', description: 'Você realizou sua primeira doação!', icon: Icons.looks_one, requiredDonations: 1),
    Achievement(title: 'Doador Regular', description: 'Parabéns por doar 3 vezes!', icon: Icons.bookmark, requiredDonations: 3),
    Achievement(title: 'Herói', description: 'Incrível! Você já doou 5 vezes!', icon: Icons.shield, requiredDonations: 5),
    Achievement(title: 'Lenda', description: 'Você é uma lenda da doação com 10 contribuições!', icon: Icons.star, requiredDonations: 10),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
    });
    try {
      final perfilData = await DatabaseHelper.getPerfil();
      final lembretesData = await DatabaseHelper.getLembretes();

      setState(() {
        if (perfilData != null) {
          _perfilData = perfilData;
          _totalDoacoes = perfilData['totalDoacoes'] ?? 0;
          final ultimaDoacaoStr = perfilData['ultimaDoacao'];
          _ultimaDoacao = ultimaDoacaoStr != null ? DateTime.tryParse(ultimaDoacaoStr) : null;
          _userName = perfilData['nome'] ?? 'Doador';
          _userBloodType = perfilData['tipoSanguineo'];
        }
        _lembretes = lembretesData;
        _isLoadingData = false;
      });
    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      setState(() {
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar os dados salvos.')),
        );
      }
    }
  }

  // --- 2. FUNÇÃO ATUALIZADA PARA SALVAR NO FIREBASE ---
  Future<void> _registrarNovaDoacao() async {
    final oldTotal = _totalDoacoes;
    final newTotal = oldTotal + 1;
    final newUltimaDoacao = DateTime.now();
    Achievement? unlockedAchievement;

    // Lógica das conquistas
    for (var achievement in _allAchievements) {
      if (newTotal >= achievement.requiredDonations && oldTotal < achievement.requiredDonations) {
        unlockedAchievement = achievement;
        break;
      }
    }

    // 1. Salva no SQLite (Banco Local)
    await DatabaseHelper.updatePerfilDoacao(newTotal, newUltimaDoacao);

    // 2. Salva no Firebase (Nuvem)
    try {
      DatabaseReference ref = FirebaseDatabase.instance.ref("registros_doacoes");

      await ref.push().set({
        "usuario": _userName,
        "tipo_sanguineo": _userBloodType ?? "Não informado",
        "data": newUltimaDoacao.toString(),
        "total_doacoes": newTotal,
        "mensagem": "Funcionou professor! Dados salvos no Firebase."
      });
      debugPrint("Salvo no Firebase com sucesso!");
    } catch (e) {
      debugPrint("Erro ao salvar no Firebase: $e");
      // O app continua funcionando mesmo se der erro no Firebase (ex: sem internet)
    }

    setState(() {
      _totalDoacoes = newTotal;
      _ultimaDoacao = newUltimaDoacao;
    });

    _showCelebrationDialog(newTotal, unlockedAchievement);
  }

  Future<void> _showCelebrationDialog(int newTotal, Achievement? unlockedAchievement) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.favorite, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(
                'Parabéns pela sua ${newTotal}ª doação!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('O seu gesto de solidariedade salva vidas. Muito obrigado!', textAlign: TextAlign.center),
              if (unlockedAchievement != null) ...[
                const Divider(height: 32),
                const Text('Você desbloqueou uma nova conquista:', textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  unlockedAchievement.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFC62828)),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Fantástico!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _adicionarLembrete(String data, String local, String hora) async {
    await DatabaseHelper.createLembrete(data, local, hora);
    _loadData();
  }

  Future<void> _removerLembrete(int id) async {
    await DatabaseHelper.deleteLembrete(id);
    _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento removido.')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToTab(int index) {
    _onItemTapped(index);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0: // Início
        return HomeScreenApp(
          userName: _userName,
          ultimaDoacao: _ultimaDoacao,
          onNavigate: _navigateToTab,
        );
      case 1: // Locais
        return const MapaScreen();
      case 2: // Calendário
        return CalendarioScreen(
          lembretes: _lembretes,
          onSchedule: _adicionarLembrete,
          onRemoveLembrete: _removerLembrete,
        );
      case 3: // Perfil
        return PerfilScreen(
          userName: _userName,
          userBloodType: _userBloodType,
          totalDoacoes: _totalDoacoes,
          ultimaDoacao: _ultimaDoacao,
          onRegistrarNovaDoacao: _registrarNovaDoacao,
          allAchievements: _allAchievements,
          perfilData: _perfilData,
          onProfileUpdated: _loadData,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoadingData
            ? const CircularProgressIndicator(color: Color(0xFFC62828))
            : _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: 'Locais'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Calendário'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFFC62828),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}