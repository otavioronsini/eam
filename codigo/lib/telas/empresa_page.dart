import 'package:flutter/material.dart';
import '../domain/estabelecimento_repository.dart';
import '../funcionalidades/cadastra_empresa.dart';
import '../funcionalidades/estabelecimento.dart';
import 'empresa_detalhe_page.dart';

class EmpresaPage extends StatefulWidget {
  final EstabelecimentoRepository estabelecimentoRepo;
  final String empresaId;

  const EmpresaPage({
    super.key,
    required this.estabelecimentoRepo,
    required this.empresaId,
  });

  @override
  State<EmpresaPage> createState() => _EmpresaPageState();
}

class _EmpresaPageState extends State<EmpresaPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarEstabelecimento();
  }

  Future<void> _carregarEstabelecimento() async {
    final est = await widget.estabelecimentoRepo.getEstabelecimento(widget.empresaId);

    if (!mounted) return;
    setState(() {
      _loading = false;
    });

    if (est != null) {
      _irParaDetalhe(est);
    }
  }

  void _irParaDetalhe(Estabelecimento est) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmpresaDetalhePage(
          estabelecimento: est,
          estabelecimentoRepo: widget.estabelecimentoRepo,
        ),
      ),
    );
  }

  void _cadastrar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastraEmpresaPage(
          estabelecimentoRepo: widget.estabelecimentoRepo,
          empresaId: widget.empresaId,
        ),
      ),
    );
    _carregarEstabelecimento();
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
        title: const Text('Área da Empresa', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.store_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Você ainda não possui\num estabelecimento cadastrado',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cadastrar estabelecimento', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}