import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/cliente_repository.dart';
import '../domain/estabelecimento_repository.dart';
import '../funcionalidades/cliente.dart';
import '../funcionalidades/leitor_qr.dart';
import 'conta_usuario_page.dart';
import 'restaurante_detalhe_page.dart';

class ClientePage extends StatefulWidget {
  final Cliente cliente;
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;

  const ClientePage({
    super.key,
    required this.cliente,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
  });

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class _ClientePageState extends State<ClientePage> {
  List<Map<String, dynamic>> _carteiras = [];
  bool _loading = true;
  late Cliente _cliente;

  @override
  void initState() {
    super.initState();
    _cliente = widget.cliente;
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    if (_cliente.id == null) return;

    final dados = await widget.clienteRepo.getAllPontosByCliente(_cliente.id!);
    if (!mounted) return;
    setState(() {
      _carteiras = dados;
      _loading = false;
    });
  }

  Future<void> _abrirContaUsuario() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContaUsuarioPage(
          cliente: _cliente,
          clienteRepo: widget.clienteRepo,
        ),
      ),
    );

    if (_cliente.id == null) return;
    final atualizado = await widget.clienteRepo.getCliente(_cliente.id!);
    if (!mounted || atualizado == null) return;
    setState(() => _cliente = atualizado);
  }

  void _scanearQR() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LeitorQRPage(
          clienteId: _cliente.id!,
          clienteRepo: widget.clienteRepo,
          estabelecimentoRepo: widget.estabelecimentoRepo,
        ),
      ),
    );
    _carregarDados();
  }

  void _abrirDetalhe(Map<String, dynamic> item) async {
    final estId = item['estabelecimento_id'] as String;
    final est = await widget.estabelecimentoRepo.getEstabelecimento(estId);
    if (est == null || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestauranteDetalhePage(
          estabelecimento: est,
          clienteId: _cliente.id!,
          clienteEmail: _cliente.email,
          clienteNome: _cliente.nome,
          saldo: (item['saldo'] as int?) ?? 0,
          totalGanhos: (item['total_ganhos'] as int?) ?? 0,
          totalUtilizados: (item['total_utilizados'] as int?) ?? 0,
          clienteRepo: widget.clienteRepo,
          estabelecimentoRepo: widget.estabelecimentoRepo,
        ),
      ),
    );
    _carregarDados();
  }

  IconData _iconePorNome(String nome) {
    final n = nome.toLowerCase();
    if (n.contains('pizza')) return Icons.local_pizza;
    if (n.contains('café') || n.contains('cafe')) return Icons.coffee;
    if (n.contains('burger') || n.contains('hamburguer') || n.contains('lanche')) return Icons.fastfood;
    if (n.contains('restaurante') || n.contains('comida')) return Icons.restaurant;
    if (n.contains('bar') || n.contains('drink')) return Icons.local_drink;
    if (n.contains('sorvete') || n.contains('gelado')) return Icons.icecream;
    return Icons.store;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Minhas Carteiras', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Hero(
              tag: 'avatar_perfil',
              child: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundImage: _cliente.fotoPath != null
                    ? FileImage(File(_cliente.fotoPath!))
                    : null,
                child: _cliente.fotoPath == null
                    ? Icon(Icons.person, color: theme.colorScheme.primary)
                    : null,
              ),
            ),
            onPressed: _abrirContaUsuario,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _carregarDados,
        child: _carteiras.isEmpty
            ? ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text('Nenhum estabelecimento visitado', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Escaneie um QR Code para começar!', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: _carteiras.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final local = _carteiras[index];
            final nome = local['nome'] as String? ?? 'Estabelecimento';
            final saldo = (local['saldo'] as int?) ?? 0;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _abrirDetalhe(local),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      child: Icon(_iconePorNome(nome), color: theme.colorScheme.primary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nome, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Toque para ver recompensas', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$saldo', style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                        Text('pts', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanearQR,
        icon: Icon(Icons.qr_code_scanner, color: theme.colorScheme.onPrimary),
        label: Text('Ganhar Pontos', style: TextStyle(color: theme.colorScheme.onPrimary)),
        backgroundColor: theme.colorScheme.primary,
      ),
    );
  }
}