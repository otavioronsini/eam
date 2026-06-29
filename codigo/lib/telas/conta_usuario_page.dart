import 'package:flutter/material.dart';
import '../domain/cliente_repository.dart';
import '../funcionalidades/cliente.dart';

class ContaUsuarioPage extends StatefulWidget {
  final Cliente cliente;
  final ClienteRepository clienteRepo;

  const ContaUsuarioPage({
    super.key,
    required this.cliente,
    required this.clienteRepo,
  });

  @override
  State<ContaUsuarioPage> createState() => _ContaUsuarioPageState();
}

class _ContaUsuarioPageState extends State<ContaUsuarioPage> {
  Map<String, int> _totais = {
    'total_saldo': 0, 'total_ganhos': 0, 'total_utilizados': 0,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarTotais();
  }

  Future<void> _carregarTotais() async {
    if (widget.cliente.id == null) return;
    final totais = await widget.clienteRepo.getTotaisGlobais(widget.cliente.id!);
    if (!mounted) return;
    setState(() {
      _totais = totais;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Conta do Usuário', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 40, backgroundColor: theme.colorScheme.primary.withOpacity(0.2), child: Icon(Icons.person, size: 40, color: theme.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Text(widget.cliente.nome, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(widget.cliente.email, style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text('Estatísticas Globais', style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('Saldo', style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      Text('${_totais['total_saldo']}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Ganhos', style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      Text('+${_totais['total_ganhos']}', style: const TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('Utilizados', style: TextStyle(color: Colors.grey[400])),
                      const SizedBox(height: 8),
                      Text('-${_totais['total_utilizados']}', style: const TextStyle(color: Colors.redAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}