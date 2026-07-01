import 'package:flutter/material.dart';
import '../domain/auth_repository.dart';
import '../domain/empresa_repository.dart';
import '../funcionalidades/empresa.dart';
import '../funcionalidades/plano.dart';

/// Painel do superusuário: busca uma empresa pelo e-mail e concede (ou
/// remove) a permissão manual de cadastrar mais restaurantes do que o
/// plano contratado normalmente permitiria — sempre respeitando o teto
/// definido por [Plano.limiteMaximo].
///
/// A atualização é gravada direto no Firestore assim que confirmada: na
/// próxima vez que a conta em questão abrir/recarregar a Área da Empresa,
/// o novo limite já aparece (o app inteiro funciona assim, sem listeners
/// em tempo real — é o mesmo padrão usado no resto do projeto).
class SuperusuarioPainelPage extends StatefulWidget {
  final EmpresaRepository empresaRepo;
  final AuthRepository authRepo;

  const SuperusuarioPainelPage({
    super.key,
    required this.empresaRepo,
    required this.authRepo,
  });

  @override
  State<SuperusuarioPainelPage> createState() => _SuperusuarioPainelPageState();
}

class _SuperusuarioPainelPageState extends State<SuperusuarioPainelPage> {
  final _emailController = TextEditingController();

  bool _buscando = false;
  bool _salvando = false;
  bool _jaBuscou = false;
  Empresa? _empresaEncontrada;
  int? _valorSelecionado;

  bool _carregandoLista = true;
  List<Empresa> _comPermissaoExtra = [];

  @override
  void initState() {
    super.initState();
    _carregarComPermissaoExtra();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _carregarComPermissaoExtra() async {
    setState(() => _carregandoLista = true);
    final todas = await widget.empresaRepo.getTodasEmpresas();
    if (!mounted) return;
    setState(() {
      _comPermissaoExtra = todas.where((e) => e.limiteExtra != null).toList()
        ..sort((a, b) => a.email.compareTo(b.email));
      _carregandoLista = false;
    });
  }

  Future<void> _buscar() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      _buscando = true;
      _jaBuscou = false;
      _empresaEncontrada = null;
    });

    final empresa = await widget.empresaRepo.buscarPorEmail(email);

    if (!mounted) return;
    setState(() {
      _buscando = false;
      _jaBuscou = true;
      _empresaEncontrada = empresa;
      _valorSelecionado = empresa?.limiteEstabelecimentos;
    });
  }

  Future<void> _salvarPermissao() async {
    final empresa = _empresaEncontrada;
    final valor = _valorSelecionado;
    if (empresa == null || valor == null) return;

    setState(() => _salvando = true);
    try {
      // Só grava como permissão extra se realmente ultrapassar o que o
      // plano já dá de graça; senão grava null (evita um valor "morto"
      // que nunca teria efeito, veja Empresa.limiteEstabelecimentos).
      final limitePlano = Plano.limiteDe(empresa.planoEfetivo);
      final novoLimiteExtra = valor > limitePlano ? valor : null;

      await widget.empresaRepo.definirLimiteExtra(empresa.id, novoLimiteExtra);
      final atualizada = await widget.empresaRepo.getEmpresa(empresa.id);

      if (!mounted) return;
      setState(() {
        _empresaEncontrada = atualizada;
        _valorSelecionado = atualizada?.limiteEstabelecimentos;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão atualizada: ${empresa.email} agora pode cadastrar $valor restaurante(s)')),
      );
      await _carregarComPermissaoExtra();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _removerPermissao([Empresa? empresaAlvo]) async {
    final empresa = empresaAlvo ?? _empresaEncontrada;
    if (empresa == null) return;

    setState(() => _salvando = true);
    try {
      await widget.empresaRepo.definirLimiteExtra(empresa.id, null);

      if (_empresaEncontrada?.id == empresa.id) {
        final atualizada = await widget.empresaRepo.getEmpresa(empresa.id);
        if (!mounted) return;
        setState(() {
          _empresaEncontrada = atualizada;
          _valorSelecionado = atualizada?.limiteEstabelecimentos;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão manual removida de ${empresa.email}')),
      );
      await _carregarComPermissaoExtra();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _sair() async {
    await widget.authRepo.logout();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final empresa = _empresaEncontrada;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Painel de superusuário', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Sair',
            onPressed: _sair,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Conceder permissão por e-mail',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Digite o e-mail da conta Empresa e escolha até quantos '
            'restaurantes ela pode cadastrar (respeitando o teto de '
            '${Plano.limiteMaximo} do plano ${Plano.nomeDe(Plano.top)}).',
            style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  onSubmitted: (_) => _buscar(),
                  decoration: InputDecoration(
                    labelText: 'E-mail da empresa',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _buscando ? null : _buscar,
                  child: _buscando
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                        )
                      : const Icon(Icons.search),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_jaBuscou && empresa == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Nenhuma empresa encontrada com esse e-mail.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),

          if (empresa != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(Icons.store, color: theme.colorScheme.onPrimary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(empresa.nome, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text(empresa.email, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text('Plano: ${Plano.nomeDe(empresa.planoEfetivo)}', style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                      Text('Limite atual: ${empresa.limiteEstabelecimentos} restaurante(s)', style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                    ],
                  ),
                  if (empresa.limiteExtra != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Permissão manual ativa (${empresa.limiteExtra})',
                          style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  Text(
                    'Definir quantidade liberada',
                    style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(Plano.limiteMaximo, (i) => i + 1).map((n) {
                      final selecionado = _valorSelecionado == n;
                      return ChoiceChip(
                        label: Text('$n restaurante${n > 1 ? 's' : ''}'),
                        selected: selecionado,
                        onSelected: _salvando ? null : (_) => setState(() => _valorSelecionado = n),
                        selectedColor: theme.colorScheme.primary,
                        labelStyle: TextStyle(color: selecionado ? theme.colorScheme.onPrimary : Colors.grey[300]),
                        backgroundColor: const Color(0xFF0F172A),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: (_salvando || _valorSelecionado == null) ? null : _salvarPermissao,
                          child: _salvando
                              ? SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.onPrimary),
                                )
                              : const Text('Salvar permissão'),
                        ),
                      ),
                      if (empresa.limiteExtra != null) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _salvando ? null : () => _removerPermissao(),
                          child: const Text('Remover'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),
          const Divider(color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'Contas com permissão manual concedida',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (_carregandoLista)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (_comPermissaoExtra.isEmpty)
            Text('Nenhuma permissão manual concedida no momento.', style: TextStyle(color: Colors.grey[500]))
          else
            ..._comPermissaoExtra.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(e.email, style: const TextStyle(color: Colors.white)),
                          Text('${e.limiteExtra} restaurante(s) liberado(s) manualmente', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                      tooltip: 'Remover permissão',
                      onPressed: _salvando ? null : () => _removerPermissao(e),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
