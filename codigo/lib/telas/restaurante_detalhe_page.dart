import 'dart:io';
import 'package:flutter/material.dart';
import '../domain/cliente_repository.dart';
import '../domain/estabelecimento_repository.dart';
import '../funcionalidades/estabelecimento.dart';
import '../funcionalidades/recompensa.dart';

class RestauranteDetalhePage extends StatefulWidget {
  final Estabelecimento estabelecimento;
  final String clienteId;
  final int saldo;
  final int totalGanhos;
  final int totalUtilizados;
  final ClienteRepository clienteRepo;
  final EstabelecimentoRepository estabelecimentoRepo;

  const RestauranteDetalhePage({
    super.key,
    required this.estabelecimento,
    required this.clienteId,
    required this.saldo,
    required this.totalGanhos,
    required this.totalUtilizados,
    required this.clienteRepo,
    required this.estabelecimentoRepo,
  });

  @override
  State<RestauranteDetalhePage> createState() =>
      _RestauranteDetalhePageState();
}

class _RestauranteDetalhePageState extends State<RestauranteDetalhePage> {
  late int _saldo;
  late int _totalGanhos;
  late int _totalUtilizados;
  List<Recompensa> _recompensas = [];

  @override
  void initState() {
    super.initState();
    _saldo = widget.saldo;
    _totalGanhos = widget.totalGanhos;
    _totalUtilizados = widget.totalUtilizados;
    _carregarRecompensas();
  }

  Future<void> _carregarRecompensas() async {
    final recs = await widget.estabelecimentoRepo.getRecompensasByEstabelecimento(widget.estabelecimento.id!);
    if (!mounted) return;
    setState(() => _recompensas = recs);
  }

  Future<void> _resgatarRecompensa(Recompensa rec) async {
    if (_saldo < rec.pontosNecessarios) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo insuficiente para resgatar esta recompensa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resgatar recompensa'),
        content: Text('Usar ${rec.pontosNecessarios} pontos para:\n"${rec.nome}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Resgatar'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final sucesso = await widget.clienteRepo.resgatarPontos(
      widget.clienteId,
      widget.estabelecimento.id!,
      rec.pontosNecessarios,
    );

    if (!mounted) return;

    if (sucesso) {
      setState(() {
        _saldo -= rec.pontosNecessarios;
        _totalUtilizados += rec.pontosNecessarios;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${rec.nome}" resgatado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao resgatar recompensa'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final est = widget.estabelecimento;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                est.nome,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  est.fotoPath != null
                      ? Image.file(
                    File(est.fotoPath!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholderImage(),
                  )
                      : _placeholderImage(),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF0F172A)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${est.latitude.toStringAsFixed(4)}, ${est.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  if (est.descricao.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      est.descricao,
                      style: TextStyle(color: Colors.grey[400], height: 1.4),
                    ),
                  ],
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color:
                          theme.colorScheme.primary.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text('Seus pontos aqui',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(color: Colors.grey)),
                        const SizedBox(height: 8),
                        Text(
                          '$_saldo pts',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Ganhos',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey)),
                                Text(
                                  '+$_totalGanhos',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Utilizados',
                                    style: theme.textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey)),
                                Text(
                                  '-$_totalUtilizados',
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (_recompensas.isNotEmpty) ...[
                    const SizedBox(height: 40),
                    Text('Recompensas',
                        style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    const SizedBox(height: 16),

                    ..._recompensas.map(
                          (rec) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(0.1),
                            child: Icon(Icons.local_offer,
                                color: theme.colorScheme.primary),
                          ),
                          title: Text(
                            rec.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            rec.descricao,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: ElevatedButton(
                            onPressed: _saldo >= rec.pontosNecessarios
                                ? () => _resgatarRecompensa(rec)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[800],
                              disabledForegroundColor: Colors.grey[600],
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(20),
                              ),
                            ),
                            child: Text('${rec.pontosNecessarios} pts'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Image.network(
      'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.grey[850],
        child: const Center(
          child: Icon(Icons.store, size: 80, color: Colors.grey),
        ),
      ),
    );
  }
}