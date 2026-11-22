import 'package:flutter/material.dart';

enum Prioridade {
  baixa('Baixa', Colors.green, Icons.arrow_downward),
  media('Média', Colors.orange, Icons.remove),
  alta('Alta', Colors.red, Icons.priority_high);

  const Prioridade(this.rotulo, this.cor, this.icone);

  final String rotulo;
  final Color cor;
  final IconData icone;
}

class Tarefa {
  final String id;
  final String titulo;
  final String descricao;
  final DateTime dataVencimento;
  final Prioridade prioridade;
  final bool concluida;

  const Tarefa({
    this.id = '',
    required this.titulo,
    this.descricao = '',
    required this.dataVencimento,
    this.prioridade = Prioridade.media,
    this.concluida = false,
  });

  String get situacao => concluida ? 'Concluída' : 'Pendente';

  String get dataFormatada {
    final d = dataVencimento.day.toString().padLeft(2, '0');
    final m = dataVencimento.month.toString().padLeft(2, '0');
    return '$d/$m/${dataVencimento.year}';
  }

  Tarefa copyWith({
    String? id,
    String? titulo,
    String? descricao,
    DateTime? dataVencimento,
    Prioridade? prioridade,
    bool? concluida,
  }) {
    return Tarefa(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      dataVencimento: dataVencimento ?? this.dataVencimento,
      prioridade: prioridade ?? this.prioridade,
      concluida: concluida ?? this.concluida,
    );
  }

  /// O id NÃO é gravado no corpo: ele é a chave do nó no Realtime Database.
  Map<String, dynamic> toMap() => {
        'titulo': titulo,
        'descricao': descricao,
        'dataVencimento': dataVencimento.millisecondsSinceEpoch,
        'prioridade': prioridade.name,
        'concluida': concluida,
      };

  factory Tarefa.fromMap(String id, Map map) => Tarefa(
        id: id,
        titulo: map['titulo']?.toString() ?? '',
        descricao: map['descricao']?.toString() ?? '',
        dataVencimento: DateTime.fromMillisecondsSinceEpoch(
          (map['dataVencimento'] as num?)?.toInt() ?? 0,
        ),
        prioridade: Prioridade.values.firstWhere(
          (p) => p.name == map['prioridade'],
          orElse: () => Prioridade.media,
        ),
        concluida: map['concluida'] == true,
      );
}
