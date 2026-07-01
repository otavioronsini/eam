import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../domain/estabelecimento_repository.dart';
import 'estabelecimento.dart';

/// Tela onde a empresa gera um QR Code de uso único.
///
/// Cada código gerado aqui só pode ser escaneado por UM cliente: assim que
/// é lido pela primeira vez (em [LeitorQRPage]), ele é marcado como usado
/// e deixa de funcionar. A empresa escolhe, no momento da geração:
///   - a qual estabelecimento o código fica atrelado (caso tenha mais de um)
///   - quantos pontos esse código específico vale
class GerarQrCodePage extends StatefulWidget {
  final EstabelecimentoRepository estabelecimentoRepo;
  final List<Estabelecimento> estabelecimentos;
  final String? estabelecimentoInicialId;

  const GerarQrCodePage({
    super.key,
    required this.estabelecimentoRepo,
    required this.estabelecimentos,
    this.estabelecimentoInicialId,
  });

  @override
  State<GerarQrCodePage> createState() => _GerarQrCodePageState();
}

class _GerarQrCodePageState extends State<GerarQrCodePage> {
  late Estabelecimento _estabelecimentoSelecionado;
  late final TextEditingController _pontosController;
  bool _gerando = false;

  /// Conteúdo (qr:token) do último código gerado nesta tela. Cada toque em
  /// "Gerar QR Code" cria um token novo — o anterior, se já tiver sido
  /// escaneado, simplesmente já não vale mais nada.
  String? _qrAtual;

  @override
  void initState() {
    super.initState();
    _estabelecimentoSelecionado = widget.estabelecimentos.firstWhere(
      (e) => e.id == widget.estabelecimentoInicialId,
      orElse: () => widget.estabelecimentos.first,
    );
    _pontosController = TextEditingController(
      text: _estabelecimentoSelecionado.pontosPorVisita.toString(),
    );
  }

  @override
  void dispose() {
    _pontosController.dispose();
    super.dispose();
  }

  Future<void> _gerar() async {
    final pontos = int.tryParse(_pontosController.text.trim());
    if (pontos == null || pontos < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor válido de pontos (mínimo 1)'),
        ),
      );
      return;
    }

    final estId = _estabelecimentoSelecionado.id;
    if (estId == null) return;

    setState(() => _gerando = true);

    try {
      const uuid = Uuid();
      final token = uuid.v4();

      await widget.estabelecimentoRepo.criarQrCode(estId, token, pontos);

      if (!mounted) return;
      setState(() {
        _qrAtual = 'qr:$token';
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar QR Code: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _gerando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final temMaisDeUm = widget.estabelecimentos.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Gerar QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estabelecimento',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    temMaisDeUm
                        ? 'Escolha a qual dos seus estabelecimentos este QR Code vai pertencer'
                        : 'Este QR Code será gerado para o estabelecimento abaixo',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  if (temMaisDeUm)
                    DropdownButtonFormField<Estabelecimento>(
                      initialValue: _estabelecimentoSelecionado,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[700]!),
                        ),
                      ),
                      items: widget.estabelecimentos
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (novo) {
                        if (novo == null) return;
                        setState(() {
                          _estabelecimentoSelecionado = novo;
                          _pontosController.text =
                              novo.pontosPorVisita.toString();
                          _qrAtual = null;
                        });
                      },
                    )
                  else
                    Row(
                      children: [
                        Icon(Icons.store, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _estabelecimentoSelecionado.nome,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pontos deste código',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quantos pontos o cliente ganha ao escanear este QR Code específico',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _pontosController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Pontos',
                      labelStyle: TextStyle(color: Colors.grey[500]),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.primary),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _gerando ? null : _gerar,
              icon: _gerando
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Icons.qr_code),
              label: Text(_qrAtual == null ? 'Gerar QR Code' : 'Gerar novo QR Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            if (_qrAtual != null) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: QrImageView(
                        data: _qrAtual!,
                        version: QrVersions.auto,
                        size: 220,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.info_outline, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Código de uso único: vale para apenas 1 cliente e depois deixa de funcionar.',
                              style: TextStyle(color: Colors.amber[100], fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mostre esta tela para o cliente escanear com o app',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
