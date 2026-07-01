import 'package:flutter/material.dart';
import '../domain/empresa_repository.dart';
import '../funcionalidades/empresa.dart';
import '../funcionalidades/plano.dart';

/// Painel visível só para contas com `admin: true` no Firestore.
/// É aqui que você aprova, na mão, as empresas que já pagaram via Pix.
class AdminPage extends StatefulWidget {
  final EmpresaRepository empresaRepo;

  const AdminPage({super.key, required this.empresaRepo});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  bool _loading = true;
  List<Empresa> _pendentes = [];
  List<Empresa> _todas = [];
  String _processandoId = '';

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final pendentes = await widget.empresaRepo.getSolicitacoesPendentes();
    final todas = await widget.empresaRepo.getTodasEmpresas();
    if (!mounted) return;
    setState(() {
      _pendentes = pendentes;
      _todas = todas..sort((a, b) => a.email.compareTo(b.email));
      _loading = false;
    });
  }

  Future<void> _aprovar(Empresa empresa) async {
    if (empresa.planoSolicitado == null) return;
    setState(() => _processandoId = empresa.id);
    try {
      await widget.empresaRepo.liberarPlano(empresa.id, empresa.planoSolicitado!);
      await _carregar();
    } finally {
      if (mounted) setState(() => _processandoId = '');
    }
  }

  Future<void> _revogar(Empresa empresa) async {
    setState(() => _processandoId = empresa.id);
    try {
      await widget.empresaRepo.revogarAssinatura(empresa.id);
      await _carregar();
    } finally {
      if (mounted) setState(() => _processandoId = '');
    }
  }

  String _formatarData(DateTime data) {
    final d = data.day.toString().padLeft(2, '0');
    final m = data.month.toString().padLeft(2, '0');
    return '$d/$m/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Painel administrativo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Solicitações pendentes',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          if (_pendentes.isEmpty)
            Text(
              'Nenhuma solicitação pendente no momento.',
              style: TextStyle(color: Colors.grey[500]),
            )
          else
            ..._pendentes.map(
              (empresa) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
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
                          Text(
                            empresa.email,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quer o plano ${Plano.nomeDe(empresa.planoSolicitado ?? '')}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _processandoId == empresa.id ? null : () => _aprovar(empresa),
                      child: const Text('Aprovar'),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 28),
          Text(
            'Todas as empresas',
            style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ..._todas.map(
            (empresa) => Container(
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
                        Row(
                          children: [
                            Text(empresa.email, style: const TextStyle(color: Colors.white)),
                            if (empresa.admin) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.shield_outlined, color: Colors.amber, size: 14),
                            ],
                          ],
                        ),
                        Text(
                          'Plano: ${Plano.nomeDe(empresa.planoEfetivo)}'
                          '${empresa.assinaturaExpiraEm != null ? ' • expira em ${_formatarData(empresa.assinaturaExpiraEm!)}' : ''}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  if (empresa.planoEfetivo != Plano.gratis)
                    IconButton(
                      icon: const Icon(Icons.block, color: Colors.redAccent, size: 20),
                      tooltip: 'Revogar assinatura',
                      onPressed: _processandoId == empresa.id ? null : () => _revogar(empresa),
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
