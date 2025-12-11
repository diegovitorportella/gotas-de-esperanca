// lib/helpers/database_helper.dart
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart'; // Para debugPrint

class DatabaseHelper {

  // Função para criar as tabelas na versão 1
  static Future<void> _createTablesV1(sql.Database database) async {
    // Tabela perfil - Versão 1
    await database.execute("""CREATE TABLE perfil (
        id INTEGER PRIMARY KEY CHECK (id = 1), -- Garante que só haverá ID 1
        totalDoacoes INTEGER DEFAULT 0,
        ultimaDoacao TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    // Tabela lembretes - Versão 1
    await database.execute("""CREATE TABLE lembretes (
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        data TEXT,
        local TEXT,
        hora TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
    // Inicializa perfil V1
    await database.rawInsert('INSERT OR IGNORE INTO perfil(id, totalDoacoes, ultimaDoacao) VALUES(1, 0, NULL)');
  }

  // Função para atualizar da V1 para V2
  static Future<void> _upgradeDbV1ToV2(sql.Database db) async {
    debugPrint("Atualizando banco da V1 para V2...");
    // Adiciona as novas colunas à tabela perfil, email SEM UNIQUE por enquanto
    await db.execute("ALTER TABLE perfil ADD COLUMN nome TEXT");
    await db.execute("ALTER TABLE perfil ADD COLUMN email TEXT"); // <<< REMOVIDO UNIQUE DAQUI
    await db.execute("ALTER TABLE perfil ADD COLUMN senha TEXT");
    await db.execute("ALTER TABLE perfil ADD COLUMN dataNascimento TEXT");
    await db.execute("ALTER TABLE perfil ADD COLUMN tipoSanguineo TEXT");

    // <<< ADICIONADO AQUI: Cria o índice UNIQUE para o email separadamente >>>
    await db.execute("CREATE UNIQUE INDEX idx_email ON perfil (email)");
    debugPrint("Colunas V2 adicionadas e índice UNIQUE para email criado.");
  }


  // Função para abrir/criar o banco (agora com versionamento e upgrade)
  static Future<sql.Database> db() async {
    try {
      final dbPath = await sql.getDatabasesPath();
      final localDb = path.join(dbPath, 'gotas_esperanca.db');

      return sql.openDatabase(
        localDb,
        version: 2, // <<< VERSÃO INCREMENTADA PARA 2 >>>
        onCreate: (sql.Database database, int version) async {
          debugPrint("Criando banco de dados versão $version...");
          // Cria as tabelas da V1 primeiro
          await _createTablesV1(database);
          // Aplica as alterações da V2 (adiciona colunas)
          await _upgradeDbV1ToV2(database);
          debugPrint("Banco V2 criado.");
        },
        onUpgrade: (sql.Database db, int oldVersion, int newVersion) async {
          debugPrint("Atualizando banco da versão $oldVersion para $newVersion...");
          if (oldVersion < 2) {
            // Aplica as alterações da V1 para V2
            await _upgradeDbV1ToV2(db);
          }
          // Adicionar mais 'if (oldVersion < X)' aqui para futuras versões
          debugPrint("Banco atualizado para V$newVersion.");
        },
      );
    } catch (e) {
      debugPrint("Erro ao abrir/criar banco de dados: $e");
      rethrow;
    }
  }

  // --- Funções para PERFIL (Atualizadas e Novas) ---

  // Pega os dados do perfil (agora busca todos os campos)
  static Future<Map<String, dynamic>?> getPerfil() async {
    final db = await DatabaseHelper.db();
    try {
      final results = await db.query(
          'perfil',
          // Busca todas as colunas agora
          columns: ['id', 'totalDoacoes', 'ultimaDoacao', 'nome', 'email', 'senha', 'dataNascimento', 'tipoSanguineo', 'createdAt'],
          where: "id = ?",
          whereArgs: [1],
          limit: 1
      );
      if (results.isNotEmpty) {
        return results.first;
      }
      // Retorna um default se não encontrar (improvável)
      return {
        'id': 1, 'totalDoacoes': 0, 'ultimaDoacao': null,
        'nome': null, 'email': null, 'senha': null, 'dataNascimento': null, 'tipoSanguineo': null
      };
    } catch (e) {
      debugPrint("Erro ao buscar perfil: $e");
      return null;
    }
  }

  // Atualiza apenas o total de doações e última data (usado ao registrar doação)
  static Future<int> updatePerfilDoacao(int totalDoacoes, DateTime? ultimaDoacao) async {
    final db = await DatabaseHelper.db();
    final data = {
      'totalDoacoes': totalDoacoes,
      'ultimaDoacao': ultimaDoacao?.toIso8601String(),
    };
    try {
      final result = await db.update('perfil', data, where: "id = ?", whereArgs: [1]);
      debugPrint("Dados de doação do perfil atualizados. Linhas afetadas: $result");
      return result;
    } catch (e) {
      debugPrint("Erro ao atualizar dados de doação do perfil: $e");
      return 0;
    }
  }

  // <<< NOVA FUNÇÃO para atualizar todos os dados do perfil (cadastro/edição) >>>
  static Future<int> updateUserProfile({
    required String nome,
    required String email,
    required String senha, // LEMBRETE: Hashear a senha em app real!
    String? dataNascimento,
    String? tipoSanguineo,
  }) async {
    final db = await DatabaseHelper.db();
    final data = {
      'nome': nome,
      'email': email,
      'senha': senha, // Salva a senha diretamente (NÃO SEGURO!)
      'dataNascimento': dataNascimento,
      'tipoSanguineo': tipoSanguineo,
    };
    try {
      // Usamos insert com conflictAlgorithm.replace OU update.
      // O update é mais simples já que garantimos que o id=1 existe.
      final result = await db.update(
        'perfil',
        data,
        where: "id = ?",
        whereArgs: [1],
        //conflictAlgorithm: sql.ConflictAlgorithm.replace // Alternativa se usássemos insert
      );
      debugPrint("Perfil completo do usuário atualizado. Linhas afetadas: $result");
      return result;
    } catch (e) {
      debugPrint("Erro ao atualizar perfil completo do usuário: $e");
      // Tratar erro específico de email duplicado (UNIQUE constraint) se necessário
      if (e.toString().contains('UNIQUE constraint failed')) {
        debugPrint("Erro: Email já cadastrado.");
        // Poderia retornar um código de erro específico, ex: -2
      }
      return 0;
    }
  }


  // --- Funções para LEMBRETES (sem alterações) ---
  // ... (createLembrete, getLembretes, deleteLembrete, getLembrete, updateLembrete) ...
  // Adiciona um novo lembrete (similar ao LDDM10 - adicionarProduto e LDDM09 - insert())
  static Future<int> createLembrete(String data, String local, String hora) async {
    final db = await DatabaseHelper.db();
    final lembreteData = {'data': data, 'local': local, 'hora': hora};
    try {
      final id = await db.insert('lembretes', lembreteData,
          conflictAlgorithm: sql.ConflictAlgorithm.replace); // Evita duplicatas se necessário
      debugPrint("Lembrete criado com ID: $id");
      return id;
    } catch (e) {
      debugPrint("Erro ao criar lembrete: $e");
      return -1; // Indica erro
    }
  }

  // Pega todos os lembretes (similar ao LDDM10 - pegaProdutos e LDDM09 - query()/rawQuery())
  static Future<List<Map<String, dynamic>>> getLembretes() async {
    final db = await DatabaseHelper.db();
    try {
      // Ordena pelos mais recentes primeiro
      return await db.query('lembretes', orderBy: "createdAt DESC");
    } catch (e) {
      debugPrint("Erro ao buscar lembretes: $e");
      return []; // Retorna lista vazia em caso de erro
    }
  }

  // Apaga um lembrete pelo ID (similar ao LDDM10 - apagaProduto e LDDM09 - delete())
  static Future<void> deleteLembrete(int id) async {
    final db = await DatabaseHelper.db();
    try {
      final count = await db.delete("lembretes", where: "id = ?", whereArgs: [id]);
      debugPrint("Lembrete $id apagado. Linhas afetadas: $count");
    } catch (err) {
      debugPrint("Erro ao apagar o lembrete $id: $err");
    }
  }

  // Pega um lembrete específico (pode não ser necessário, mas incluído por completude - LDDM09 - query com where)
  static Future<Map<String, dynamic>?> getLembrete(int id) async {
    final db = await DatabaseHelper.db();
    try {
      final results = await db.query('lembretes', where: "id = ?", whereArgs: [id], limit: 1);
      if (results.isNotEmpty) {
        return results.first;
      }
      return null;
    } catch (e) {
      debugPrint("Erro ao buscar lembrete $id: $e");
      return null;
    }
  }

  // Atualiza um lembrete (pode não ser necessário, mas incluído por completude - LDDM09 - update())
  static Future<int> updateLembrete(int id, String data, String local, String hora) async {
    final db = await DatabaseHelper.db();
    final lembreteData = {
      'data': data,
      'local': local,
      'hora': hora,
      // 'createdAt': DateTime.now().toIso8601String() // Opcional: atualizar timestamp
    };
    try {
      final result = await db.update('lembretes', lembreteData, where: "id = ?", whereArgs: [id]);
      debugPrint("Lembrete $id atualizado. Linhas afetadas: $result");
      return result;
    } catch (e) {
      debugPrint("Erro ao atualizar lembrete $id: $e");
      return 0;
    }
  }

} // Fim da classe