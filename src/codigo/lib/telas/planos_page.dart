import 'package:flutter/material.dart';
import '../domain/empresa_repository.dart';
import '../funcionalidades/empresa.dart';
import '../funcionalidades/plano.dart';

class PlanosPage extends StatefulWidget {
  final EmpresaRepository empresaRepo;
  final String empresaId;

  const PlanosPage({
    super.key,
    required this.empresaRepo,
    required this.empresaId,
  });

  @override
  State<PlanosPage> createState() => _PlanosPageState();
}

class _PlanosPageState extends State<PlanosPage> {
  Empresa? _empresa;
  bool _loading = true;
  bool _processando = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final empresa = await widget.empresaRepo.getEmpresa(widget.empresaId);
    if (!mounted) return;
    setState(() {
      _empresa = empresa;
      _loading = false;
    });
  }

  Future<void> _solicitar(String plano) async {
    setState(() => _processando = true);
    try {
      await widget.empresaRepo.solicitarPlano(widget.empresaId, plano);
      await _carregar();
      if (!mounted) return;
      _mostrarInstrucoesPagamento(plano);
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _cancelarSolicitacao() async {
    setState(() => _processando = true);
    try {
      await widget.empresaRepo.cancelarSolicitacao(widget.empresaId);
      await _carregar();
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _definirPlanoAdmin(String plano) async {
    setState(() => _processando = true);
    try {
      await widget.empresaRepo.liberarPlano(widget.empresaId, plano);
      await _carregar();
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  void _mostrarInstrucoesPagamento(String plano) {
    final empresaEmail = _empresa?.email ?? 'sua conta';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Solicitação enviada',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Para concluir a assinatura do plano ${Plano.nomeDe(plano)} '
              '(R\$ ${Plano.precoDe(plano).toStringAsFixed(2)}/mês), faça o '
              'pagamento via Pix para:',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            const SelectableText(
              'pedrogarciacarvalho2114@gmail.com',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.amber[100], fontSize: 13, height: 1.4),
                        children: [
                          const TextSpan(text: 'Obrigatório: '),
                          TextSpan(
                            text: 'no comentário do Pix, informe o e-mail da '
                                'sua conta cadastrada no app ($empresaEmail)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(
                            text: '. É assim que identificamos qual conta deve '
                                'receber a assinatura.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Assim que o pagamento for confirmado, o plano é liberado pelo '
              'administrador e o limite de restaurantes é atualizado na hora.',
              style: TextStyle(color: Colors.grey[400], fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final empresa = _empresa;
    final planoAtual = empresa?.planoEfetivo ?? Plano.gratis;
    final pendente = empresa?.statusPagamento == 'pendente';
    final planoPendente = empresa?.planoSolicitado;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Planos e assinatura',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (pendente)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Solicitação do plano ${Plano.nomeDe(planoPendente ?? '')} em análise',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Assim que o pagamento for confirmado, o plano será liberado.',
                    style: TextStyle(color: Colors.amber[100], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () =>
                            _mostrarInstrucoesPagamento(planoPendente ?? ''),
                        child: const Text('Ver instruções do Pix'),
                      ),
                      TextButton(
                        onPressed: _processando ? null : _cancelarSolicitacao,
                        style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                        child: const Text('Cancelar solicitação'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          for (final plano in Plano.pagos)
            _PlanoCard(
              plano: plano,
              atual: plano == planoAtual,
              desabilitado: _processando || (pendente && planoPendente == plano),
              onAssinar: () => _solicitar(plano),
            ),
          if (empresa?.admin == true) ...[
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Modo administrador (testes)',
              style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Libera o plano direto, sem precisar de pedido nem Pix — só para '
              'testar os limites de cada assinatura.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [Plano.gratis, ...Plano.pagos].map((p) {
                final ativo = p == planoAtual;
                return ElevatedButton(
                  onPressed: _processando
                      ? null
                      : () => p == Plano.gratis
                          ? null
                          : _definirPlanoAdmin(p),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ativo ? theme.colorScheme.primary : Colors.grey[800],
                    foregroundColor: ativo ? theme.colorScheme.onPrimary : Colors.white,
                  ),
                  child: Text('Definir ${Plano.nomeDe(p)}'),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanoCard extends StatelessWidget {
  final String plano;
  final bool atual;
  final bool desabilitado;
  final VoidCallback onAssinar;

  const _PlanoCard({
    required this.plano,
    required this.atual,
    required this.desabilitado,
    required this.onAssinar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: atual ? Border.all(color: theme.colorScheme.primary, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                Plano.nomeDe(plano),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (atual) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Atual',
                    style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 11),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Até ${Plano.limiteDe(plano)} restaurantes cadastrados',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Text(
            'R\$ ${Plano.precoDe(plano).toStringAsFixed(2)} / mês',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (atual || desabilitado) ? null : onAssinar,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(atual ? 'Plano atual' : 'Quero assinar'),
            ),
          ),
        ],
      ),
    );
  }
}
