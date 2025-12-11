import 'package:flutter/material.dart';
import 'package:gotas_de_esperanca/helpers/database_helper.dart';

class EditarPerfilScreen extends StatefulWidget {
  // 1. Recebe os dados atuais do perfil
  final Map<String, dynamic> perfilData;

  const EditarPerfilScreen({super.key, required this.perfilData});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController(); // Para *nova* senha
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
    // 2. Pré-preenche os campos com os dados existentes
    _nomeController.text = widget.perfilData['nome'] ?? '';
    _emailController.text = widget.perfilData['email'] ?? '';
    // Deixamos a senha em branco por segurança. O usuário digita se quiser mudar.
    _dataNascimentoController.text = widget.perfilData['dataNascimento'] ?? '';
    _tipoSanguineoSelecionado = widget.perfilData['tipoSanguineo'];
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  // 3. Função para Salvar (em vez de cadastrar)
  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    // Se o campo senha estiver vazio, mantém a senha antiga (do widget.perfilData)
    // Se estiver preenchido, usa a nova senha.
    final String senhaParaSalvar = _senhaController.text.isNotEmpty
        ? _senhaController.text // <<< Idealmente, aplicar HASH aqui
        : widget.perfilData['senha']; // Mantém a senha antiga

    try {
      final result = await DatabaseHelper.updateUserProfile(
        nome: _nomeController.text,
        email: _emailController.text,
        senha: senhaParaSalvar, // Salva a senha (antiga ou nova)
        dataNascimento: _dataNascimentoController.text.isNotEmpty ? _dataNascimentoController.text : null,
        tipoSanguineo: _tipoSanguineoSelecionado,
      );

      setState(() { _isLoading = false; });

      if (result > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil atualizado com sucesso!'), backgroundColor: Colors.green),
          );
          // 4. Volta para a tela anterior (Perfil) e retorna 'true'
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao atualizar. O e-mail pode já estar em uso por outra conta.'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() { _isLoading = false; });
      debugPrint("Erro ao salvar perfil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocorreu um erro inesperado.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (Código do _selectDate é idêntico ao do cadastro_screen.dart) ...
    DateTime? initialDate;
    try {
      // Tenta usar a data que já estava salva
      initialDate = DateTime.tryParse(_dataNascimentoController.text);
    } catch (e) {
      // se falhar, usa a data de hoje
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
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
      // 5. Título atualizado
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
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'O nome é obrigatório.';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail*',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) return 'O e-mail é obrigatório.';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _senhaController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    // 6. Texto de ajuda atualizado
                    labelText: 'Nova Senha (Opcional)',
                    hintText: 'Deixe em branco para manter a senha atual',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  // Validação de senha agora é opcional
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: InputDecoration(
                      labelText: 'Data de Nascimento (Opcional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.edit_calendar),
                        onPressed: () => _selectDate(context),
                      )),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  value: _tipoSanguineoSelecionado,
                  hint: const Text('Tipo Sanguíneo (Opcional)'),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.bloodtype_outlined),
                  ),
                  items: _tiposSanguineos.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _tipoSanguineoSelecionado = newValue;
                    });
                  },
                ),
                const SizedBox(height: 32.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFC62828)))
                    : ElevatedButton(
                  // 7. Chama _salvar
                  onPressed: _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  // 8. Texto do botão atualizado
                  child: const Text('Salvar Alterações'),
                ),
                // 9. Removido o botão "Já tenho conta"
              ],
            ),
          ),
        ),
      ),
    );
  }
}