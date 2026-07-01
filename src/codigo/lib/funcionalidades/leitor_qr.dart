import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../domain/cliente_repository.dart';
import '../domain/estabelecimento_repository.dart';

class LeitorQRPage extends StatefulWidget {
  final String clienteId;
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;

  const LeitorQRPage({
    super.key,
    required this.clienteId,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
  });

  @override
  State<LeitorQRPage> createState() => _LeitorQRPageState();
}

class _LeitorQRPageState extends State<LeitorQRPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _aoDetectar(BarcodeCapture capture) async {
    if (_processando) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null) return;

    final rawValue = barcode.rawValue;

    if (rawValue == null || !rawValue.startsWith('qr:')) {
      return;
    }

    setState(() => _processando = true);

    final token = rawValue.substring('qr:'.length);

    final qr = await widget.estabelecimentoRepo.getQrCode(token);

    if (qr == null) {
      _mostrarErro('QR Code inválido');
      return;
    }

    if (qr['usado'] == 1) {
      _mostrarErro('Este QR Code já foi utilizado.');
      return;
    }

    final estId = qr['estabelecimento_id'] as String;

    final est = await widget.estabelecimentoRepo.getEstabelecimento(estId);

    if (est == null) {
      _mostrarErro('Estabelecimento não encontrado');
      return;
    }

    // Pontos definidos pelo estabelecimento no momento em que esse QR Code
    // específico foi gerado. Mantemos o valor da loja como fallback apenas
    // para QR Codes antigos que não tenham esse campo.
    final pontos = (qr['pontos'] as num?)?.toInt() ?? est.pontosPorVisita;

    try {
      await widget.clienteRepo.adicionarPontos(
        widget.clienteId,
        estId,
        pontos,
      );

      await widget.estabelecimentoRepo.marcarQrComoUsado(token);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+$pontos pts em ${est.nome}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _mostrarErro('Erro ao processar pontos: $e');
    }
  }

  void _mostrarErro(String msg) {
    setState(() => _processando = false);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Escanear QR Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _aoDetectar),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_processando)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        color: theme.colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 40,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Aponte a câmera para o QR Code\ndo estabelecimento para ganhar pontos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}