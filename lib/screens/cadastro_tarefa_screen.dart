import 'package:flutter/material.dart';

import '../models/tarefa.dart';
import '../services/firebase_service.dart';

/// Serve para cadastrar (tarefa == null) e para editar uma tarefa existente.
class CadastroTarefaScreen extends StatefulWidget {
  final FirebaseService service;
  final Tarefa? tarefa;

  const CadastroTarefaScreen({super.key, required this.service, this.tarefa});

  @override
  State<CadastroTarefaScreen> createState() => _CadastroTarefaScreenState();
}

class _CadastroTarefaScreenState extends State<CadastroTarefaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descricaoCtrl;
  late DateTime _data;
  late Prioridade _prioridade;
  late bool _concluida;
  bool _salvando = false;

  bool get _editando => widget.tarefa != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tarefa;
    _tituloCtrl = TextEditingController(text: t?.titulo ?? '');
    _descricaoCtrl = TextEditingController(text: t?.descricao ?? '');
    _data = t?.dataVencimento ?? DateTime.now();
    _prioridade = t?.prioridade ?? Prioridade.media;
    _concluida = t?.concluida ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (escolhida != null) setState(() => _data = escolhida);
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _salvando = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final tarefa = Tarefa(
      id: widget.tarefa?.id ?? '',
      titulo: _tituloCtrl.text.trim(),
      descricao: _descricaoCtrl.text.trim(),
      dataVencimento: _data,
      prioridade: _prioridade,
      concluida: _concluida,
    );
    try {
      if (_editando) {
        await widget.service.atualizar(tarefa);
      } else {
        await widget.service.criar(tarefa);
      }
      navigator.pop();
      messenger.showSnackBar(SnackBar(
        content: Text(_editando ? 'Tarefa atualizada.' : 'Tarefa cadastrada.'),
      ));
    } catch (e) {
      if (mounted) setState(() => _salvando = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao salvar a tarefa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataTexto = Tarefa(titulo: '', dataVencimento: _data).dataFormatada;
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar tarefa' : 'Nova tarefa')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _tituloCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    prefixIcon: Icon(Icons.title),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Informe o título.'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descricaoCtrl,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Descrição',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.notes),
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: _escolherData,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de vencimento',
                      prefixIcon: Icon(Icons.event),
                    ),
                    child: Text(dataTexto),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Prioridade',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<Prioridade>(
                  segments: [
                    for (final p in Prioridade.values)
                      ButtonSegment(
                        value: p,
                        label: Text(p.rotulo),
                        icon: Icon(p.icone, color: p.cor),
                      ),
                  ],
                  selected: {_prioridade},
                  onSelectionChanged: (s) =>
                      setState(() => _prioridade = s.first),
                ),
                const SizedBox(height: 24),
                Text('Situação', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Pendente'),
                      icon: Icon(Icons.hourglass_bottom),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Concluída'),
                      icon: Icon(Icons.check_circle),
                    ),
                  ],
                  selected: {_concluida},
                  onSelectionChanged: (s) =>
                      setState(() => _concluida = s.first),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  icon: _salvando
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
