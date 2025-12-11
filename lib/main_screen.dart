import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Autenticação
import 'package:firebase_database/firebase_database.dart'; // Banco de Dados
import 'home_screen_app.dart';
import 'mapa_screen.dart';
import 'calendario_screen.dart';
import 'perfil_screen.dart';
import 'models/achievement.dart';
import 'helpers/database_helper.dart'; // Mantemos para os lembretes locais

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
  String _userName = 'Carregando...';
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

  // --- 1. CARREGAR DADOS DO FIREBASE ---
  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      // Carrega lembretes locais (SQLite)
      final lembretesData = await DatabaseHelper.getLembretes();

      // Carrega perfil da Nuvem (Firebase)
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final ref = FirebaseDatabase.instance.ref("usuarios/${user.uid}");
        final snapshot = await ref.get();

        if (snapshot.exists) {
          // Converte os dados do Firebase
          final data = Map<String, dynamic>.from(snapshot.value as Map);

          setState(() {
            _perfilData = data;
            _userName = data['nome'] ?? 'Doador';
            _userBloodType = data['tipo_sanguineo'];
            _totalDoacoes = (data['total_doacoes'] ?? 0) as int;

            // Tenta ler a data da última doação se existir
            if (data['ultima_doacao'] != null) {
              _ultimaDoacao = DateTime.tryParse(data['ultima_doacao']);
            }
          });
        }
      }

      setState(() {
        _lembretes = lembretesData;
        _isLoadingData = false;
      });

    } catch (e) {
      debugPrint("Erro ao carregar dados: $e");
      setState(() => _isLoadingData = false);
    }
  }

  // --- 2. REGISTRAR DOAÇÃO NO FIREBASE ---
  Future<void> _registrarNovaDoacao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final oldTotal = _totalDoacoes;
    final newTotal = oldTotal + 1;
    final newUltimaDoacao = DateTime.now();

    // Atualiza estado local para feedback rápido
    setState(() {
      _totalDoacoes = newTotal;
      _ultimaDoacao = newUltimaDoacao;
    });

    try {
      final userRef = FirebaseDatabase.instance.ref("usuarios/${user.uid}");

      // Atualiza o contador no perfil do usuário
      await userRef.update({
        "total_doacoes": newTotal,
        "ultima_doacao": newUltimaDoacao.toString(),
      });

      // Salva no histórico geral (opcional)
      final logRef = FirebaseDatabase.instance.ref("registros_doacoes");
      await logRef.push().set({
        "uid": user.uid,
        "usuario": _userName,
        "data": newUltimaDoacao.toString(),
        "total_acumulado": newTotal
      });

    } catch (e) {
      debugPrint("Erro ao salvar doação: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Doação registrada localmente (sem internet).'))
        );
      }
    }

    // Verifica conquistas
    Achievement? unlockedAchievement;
    for (var achievement in _allAchievements) {
      if (newTotal >= achievement.requiredDonations && oldTotal < achievement.requiredDonations) {
        unlockedAchievement = achievement;
        break;
      }
    }
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
      case 0:
        return HomeScreenApp(
          userName: _userName,
          ultimaDoacao: _ultimaDoacao,
          onNavigate: _navigateToTab,
        );
      case 1:
        return const MapaScreen();
      case 2:
        return CalendarioScreen(
          lembretes: _lembretes,
          onSchedule: _adicionarLembrete,
          onRemoveLembrete: _removerLembrete,
        );
      case 3:
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