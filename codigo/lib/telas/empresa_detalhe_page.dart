import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../domain/estabelecimento_repository.dart';
import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/cadastra_empresa.dart';
import '../funcionalidades/recompensa.dart';
import 'package:uuid/uuid.dart';

class EmpresaDetalhePage extends StatefulWidget {
  final Estabelecimento estabelecimento;
  final EstabelecimentoRepository estabelecimentoRepo;

  const EmpresaDetalhePage({
    super.key,
    required this.estabelecimento,
    required this.estabelecimentoRepo,
  });

  @override
  State<EmpresaDetalhePage> createState() => _EmpresaDetalhePageState();
}

class _EmpresaDetalhePageState extends State<EmpresaDetalhePage> {
  late Estabelecimento _est;
  late TextEditingController _pontosController;
  final ImagePicker _picker = ImagePicker();
  bool _saving = false;

  List<Recompensa> _recompensas = [];

  @override
  void initState() {
    super.initState();
    _est = widget.estabelecimento;
    _pontosController = TextEditingController(text: _est.pontosPorVisita.toString());
    _gerarQrCodeData();
    _carregarRecompensas();
  }

  @override
  void dispose() {
    _pontosController.dispose();
    super.dispose();
  }

  Future<void> _carregarRecompensas() async {
    if (_est.id == null) return;
    final recs = await widget.estabelecimentoRepo.getRecompensasByEstabelecimento(_est.id!);
    if (!mounted) return;
    setState(() => _recompensas = recs);
  }

  Future<void> _gerarQrCodeData() async {
    if (_est.id == null) return;
    if (_est.qrCodeData != null) return;

    const uuid = Uuid();
    final token = uuid.v4();

    await widget.estabelecimentoRepo.criarQrCode(_est.id!, token);
    final data = 'qr:$token';
    final updated = _est.copyWith(qrCodeData: data);
    _est = updated;
    await widget.estabelecimentoRepo.updateEstabelecimento(_est);
    if(mounted) setState(() {});
  }

  void _editarEstabelecimento() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastraEmpresaPage(
          estabelecimento: _est,
          estabelecimentoRepo: widget.estabelecimentoRepo,
          empresaId: _est.id!,
        ),
      ),
    );

    if (_est.id == null) return;
    final atualizado = await widget.estabelecimentoRepo.getEstabelecimento(_est.id!);
    if (!mounted) return;
    if (atualizado != null) {
      setState(() {
        _est = atualizado;
        _pontosController.text = _est.pontosPorVisita.toString();
      });
    }
  }

  Future<void> _escolherFoto(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(source: source, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (foto == null) return;

      final updated = _est.copyWith(fotoPath: foto.path);
      setState(() => _est = updated);
      await widget.estabelecimentoRepo.updateEstabelecimento(_est);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao selecionar foto: $e')));
    }
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Adicionar Foto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Tirar foto'), onTap: () { Navigator.pop(context); _escolherFoto(ImageSource.camera); }),
              ListTile(leading: const Icon(Icons.photo_library), title: const Text('Escolher da galeria'), onTap: () { Navigator.pop(context); _escolherFoto(ImageSource.gallery); }),
              if (_est.fotoPath != null)
                ListTile(leading: const Icon(Icons.delete, color: Colors.redAccent), title: const Text('Remover foto', style: TextStyle(color: Colors.redAccent)), onTap: () async { Navigator.pop(context); final updated = _est.copyWith(fotoPath: null); setState(() => _est = updated); await widget.estabelecimentoRepo.updateEstabelecimento(_est); }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _salvarPontos() async {
    final valor = int.tryParse(_pontosController.text.trim());
    if (valor == null || valor < 1) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um valor válido de pontos (mínimo 1)')));
      return;
    }

    setState(() => _saving = true);
    final updated = _est.copyWith(pontosPorVisita: valor);
    _est = updated;
    await widget.estabelecimentoRepo.updateEstabelecimento(_est);
    setState(() => _saving = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configurações salvas com sucesso!')));
  }

  void _adicionarRecompensa() async {
    final result = await _mostrarDialogRecompensa(null);
    if (result == null || _est.id == null) return;

    await widget.estabelecimentoRepo.insertRecompensa(
      Recompensa(estabelecimentoId: _est.id!, nome: result['nome'] as String, descricao: result['descricao'] as String, pontosNecessarios: result['pontos'] as int),
    );
    _carregarRecompensas();
  }

  void _editarRecompensa(Recompensa rec) async {
    final result = await _mostrarDialogRecompensa(rec);
    if (result == null) return;

    await widget.estabelecimentoRepo.updateRecompensa(
      rec.copyWith(nome: result['nome'] as String, descricao: result['descricao'] as String, pontosNecessarios: result['pontos'] as int),
    );
    _carregarRecompensas();
  }

  void _removerRecompensa(Recompensa rec) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover recompensa'),
        content: Text('Remover "${rec.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), style: TextButton.styleFrom(foregroundColor: Colors.redAccent), child: const Text('Remover')),
        ],
      ),
    );
    if (confirm != true) return;

    await widget.estabelecimentoRepo.deleteRecompensa(rec.id!);
    _carregarRecompensas();
  }

  Future<Map<String, dynamic>?> _mostrarDialogRecompensa(Recompensa? rec) async {
    final nomeController = TextEditingController(text: rec?.nome ?? '');
    final descricaoController = TextEditingController(text: rec?.descricao ?? '');
    final pontosController = TextEditingController(text: rec?.pontosNecessarios.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: Text(rec == null ? 'Adicionar recompensa' : 'Editar recompensa'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome da recompensa', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: descricaoController, maxLines: 3, decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()), validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe a descrição' : null),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: pontosController, keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Pontos necessários', border: OutlineInputBorder()),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Informe os pontos';
                      final p = int.tryParse(v.trim());
                      if (p == null || p < 1) return 'Valor inválido (mín. 1)';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context, {'nome': nomeController.text.trim(), 'descricao': descricaoController.text.trim(), 'pontos': int.parse(pontosController.text.trim())});
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Meu Estabelecimento', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: Icon(Icons.edit, color: theme.colorScheme.primary), tooltip: 'Editar estabelecimento', onPressed: _editarEstabelecimento),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: _mostrarOpcoesFoto,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2)),
                  clipBehavior: Clip.antiAlias,
                  child: _est.fotoPath != null
                      ? Image.file(File(_est.fotoPath!), width: 160, height: 160, fit: BoxFit.cover)
                      : Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 40, color: theme.colorScheme.primary), const SizedBox(height: 8), Text('Adicionar foto', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12))]),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(child: Text('Toque para adicionar ou trocar a foto', style: TextStyle(color: Colors.grey[500], fontSize: 12))),
            const SizedBox(height: 32),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [Icon(Icons.store, color: theme.colorScheme.primary, size: 20), const SizedBox(width: 8), Expanded(child: Text(_est.nome, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)))]),
                  const SizedBox(height: 16),
                  if (_est.descricao.isNotEmpty) ...[Text(_est.descricao, style: TextStyle(color: Colors.grey[400], height: 1.5)), const SizedBox(height: 16)],
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.location_on, color: Colors.grey[500], size: 18), const SizedBox(width: 8), Expanded(child: Text('${_est.latitude.toStringAsFixed(6)}, ${_est.longitude.toStringAsFixed(6)}', style: TextStyle(color: Colors.grey[500])))]),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Configurar Pontos', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Defina quantos pontos o cliente ganha por visita', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _pontosController, keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Pontos por visita', labelStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[700]!)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.primary)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _salvarPontos,
                          style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.card_giftcard, color: theme.colorScheme.primary, size: 20), const SizedBox(width: 8),
                      Expanded(child: Text('Recompensas', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))),
                      IconButton(icon: const Icon(Icons.add_circle_outline), color: theme.colorScheme.primary, onPressed: _adicionarRecompensa),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Recompensas que os clientes podem resgatar com os pontos', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 16),
                  if (_recompensas.isEmpty)
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Icon(Icons.card_giftcard_outlined, size: 40, color: Colors.grey[600]), const SizedBox(height: 8),
                          Text('Nenhuma recompensa cadastrada', style: TextStyle(color: Colors.grey[500])), const SizedBox(height: 4),
                          Text('Toque em + para adicionar', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    )
                  else
                    ..._recompensas.map((rec) => Container(
                      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: theme.colorScheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                            child: Text('${rec.pontosNecessarios} pts', style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(rec.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 2),
                                Text(rec.descricao, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(icon: Icon(Icons.edit_outlined, color: Colors.grey[500], size: 18), onPressed: () => _editarRecompensa(rec)),
                          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18), onPressed: () => _removerRecompensa(rec)),
                        ],
                      ),
                    )),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code, color: theme.colorScheme.primary), const SizedBox(width: 8),
                      Text('QR Code do Estabelecimento', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Compartilhe este QR com seus clientes\npara que eles acumulem pontos', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: _est.qrCodeData != null
                        ? QrImageView(
                      data: _est.qrCodeData!, version: QrVersions.auto, size: 200, backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    )
                        : const SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator())),
                  ),
                  const SizedBox(height: 16),
                  if (_est.qrCodeData != null) Text('ID: ${_est.id}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}