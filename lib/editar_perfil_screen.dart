import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Map<String, dynamic> perfilData;

  const EditarPerfilScreen({super.key, required this.perfilData});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController(); // Apenas leitura visual por segurança
  final _senhaController = TextEditingController();
  final _dataNascimentoController = TextEditingController();
  String? _tipoSanguineoSelecionado;

  final _formKey = GlobalKey<FormState>();
  final List<String> _tiposSanguineos = [
    'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preenche com os dados vindos do Firebase (chaves em snake_case ou camelCase dependendo de como salvou)
    _nomeController.text = widget.perfilData['nome'] ?? '';
    _emailController.text = widget.perfilData['email'] ?? '';
    _dataNascimentoController.text = widget.perfilData['data_nascimento'] ?? '';
    _tipoSanguineoSelecionado = widget.perfilData['tipo_sanguineo'];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Atualizar dados no Realtime Database
      final userRef = FirebaseDatabase.instance.ref("usuarios/${user.uid}");
      await userRef.update({
        "nome": _nomeController.text.trim(),
        "data_nascimento": _dataNascimentoController.text,
        "tipo_sanguineo": _tipoSanguineoSelecionado,
      });

      // 2. Atualizar Senha (se o usuário digitou algo)
      if (_senhaController.text.isNotEmpty) {
        await user.updatePassword(_senhaController.text.trim());
      }

      // 3. Atualizar Email (se o usuário mudou) - Cuidado: isso pode deslogar o usuário
      // Por simplicidade, vamos manter o email apenas visual ou bloquear edição se preferir.
      if (_emailController.text.trim() != user.email) {
        // await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        // Scenarios de mudança de email exigem reautenticação sensível.
        // Vamos pular por enquanto para evitar crashes.
      }

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Retorna true para recarregar a tela anterior
      }

    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String msg = 'Erro ao atualizar.';
      if (e.code == 'requires-recent-login') {
        msg = 'Para mudar a senha, faça logout e login novamente.';
      } else if (e.code == 'weak-password') {
        msg = 'A senha é muito fraca.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    try {
      if (_dataNascimentoController.text.isNotEmpty) {
        initialDate = DateTime.parse(_dataNascimentoController.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null) {
      _dataNascimentoController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFFC62828),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome Completo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline)),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  enabled: false, // Desabilitado para evitar complexidade de reautenticação
                  decoration: const InputDecoration(labelText: 'E-mail (Não editável)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined), filled: true, fillColor: Colors.black12),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nova Senha (Opcional)', hintText: 'Deixe vazio para manter a atual', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: InputDecoration(labelText: 'Data de Nascimento', border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.calendar_today_outlined), suffixIcon: IconButton(icon: const Icon(Icons.edit_calendar), onPressed: () => _selectDate(context))),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _tipoSanguineoSelecionado,
                  hint: const Text('Tipo Sanguíneo'),
                  decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.bloodtype_outlined)),
                  items: _tiposSanguineos.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (v) => setState(() => _tipoSanguineoSelecionado = v),
                ),
                const SizedBox(height: 32.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)))
                    : ElevatedButton(
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                  child: const Text('Salvar Alterações'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}