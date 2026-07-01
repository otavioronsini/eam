import 'package:flutter/material.dart';
import '../domain/estabelecimento_repository.dart';
import '../domain/empresa_repository.dart';
import '../funcionalidades/cadastra_empresa.dart';
import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/empresa.dart';
import '../funcionalidades/plano.dart';
import '../funcionalidades/gerar_qr_code.dart';
import 'empresa_detalhe_page.dart';
import 'planos_page.dart';
import 'admin_page.dart';

class EmpresaPage extends StatefulWidget {
  final EstabelecimentoRepository estabelecimentoRepo;
  final EmpresaRepository empresaRepo;
  final String empresaId;

  const EmpresaPage({
    super.key,
    required this.estabelecimentoRepo,
    required this.empresaRepo,
    required this.empresaId,
  });

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  bool _loading = true;
  List<Estabelecimento> _estabelecimentos = [];
  Empresa? _empresa;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final estabelecimentos = await widget.estabelecimentoRepo
        .getEstabelecimentosDaEmpresa(widget.empresaId);
    final empresa = await widget.empresaRepo.getEmpresa(widget.empresaId);

    if (!mounted) return;

    setState(() {
      _loading = false;
      _estabelecimentos = estabelecimentos;
      _empresa = empresa;
    });
  }

  /// Limite de restaurantes do plano em vigor (grátis = 1, caso a empresa
  /// ainda não tenha nenhum plano registrado).
  int get _limite => _empresa?.limiteEstabelecimentos ?? 1;

  bool get _podeAdicionar => _estabelecimentos.length < _limite;

  Future<void> _cadastrar() async {
    if (!_podeAdicionar) {
      await _abrirPlanos();
      return;
    }

    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastraEmpresaPage(
          estabelecimentoRepo: widget.estabelecimentoRepo,
          empresaId: widget.empresaId,
        ),
      ),
    );

    if (resultado == true) {
      await _carregarDados();
    }
  }

  Future<void> _abrirPlanos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanosPage(
          empresaRepo: widget.empresaRepo,
          empresaId: widget.empresaId,
        ),
      ),
    );
    await _carregarDados();
  }

  Future<void> _abrirGeradorDeQrCode() async {
    if (_estabelecimentos.isEmpty) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GerarQrCodePage(
          estabelecimentoRepo: widget.estabelecimentoRepo,
          estabelecimentos: _estabelecimentos,
        ),
      ),
    );
  }

  Future<void> _abrirAdmin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminPage(empresaRepo: widget.empresaRepo),
      ),
    );
    await _carregarDados();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final empresa = _empresa;
    final planoNome = Plano.nomeDe(empresa?.planoEfetivo ?? Plano.gratis);
    final pendente = empresa?.statusPagamento == 'pendente';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Área da Empresa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (empresa?.admin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined, color: Colors.white),
              tooltip: 'Painel administrativo',
              onPressed: _abrirAdmin,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ===== Card com o plano atual =====
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_outlined, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plano $planoNome',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_estabelecimentos.length} de $_limite restaurante(s) cadastrados',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        if (pendente)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Solicitação de plano em análise',
                              style: TextStyle(color: Colors.amber[400], fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===== Lista de estabelecimentos =====
            Expanded(
              child: _estabelecimentos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 80,
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Você ainda não possui\num estabelecimento cadastrado',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _estabelecimentos.length,
                      itemBuilder: (context, index) {
                        final est = _estabelecimentos[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EmpresaDetalhePage(
                                    estabelecimento: est,
                                    estabelecimentoRepo:
                                        widget.estabelecimentoRepo,
                                  ),
                                ),
                              );

                              await _carregarDados();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: theme.colorScheme.primary,
                                    child: Icon(
                                      Icons.store,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          est.nome,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          est.descricao,
                                          style: TextStyle(
                                            color: Colors.grey[400],
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 20),

            // ===== Aviso de limite atingido =====
            if (!_podeAdicionar)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Você atingiu o limite de restaurantes do seu plano. '
                  'Assine um plano superior para cadastrar mais.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[300], fontSize: 13),
                ),
              ),

            // ===== Botão principal: adicionar estabelecimento =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _cadastrar,
                icon: Icon(_podeAdicionar ? Icons.add : Icons.lock_outline),
                label: Text(_podeAdicionar ? 'Adicionar estabelecimento' : 'Limite do plano atingido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _podeAdicionar ? theme.colorScheme.primary : Colors.grey[700],
                  foregroundColor: _podeAdicionar ? theme.colorScheme.onPrimary : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ===== Botão de gerar QR Code (uso único) =====
            if (_estabelecimentos.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _abrirGeradorDeQrCode,
                  icon: const Icon(Icons.qr_code),
                  label: const Text('Gerar QR Code'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey[600]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // ===== Botão de planos/assinatura (sempre visível, embaixo) =====
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _abrirPlanos,
                icon: const Icon(Icons.workspace_premium_outlined),
                label: const Text('Planos e assinatura'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey[600]!),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
