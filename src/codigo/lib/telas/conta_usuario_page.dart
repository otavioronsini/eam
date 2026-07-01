import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  late Cliente _cliente;
  final ImagePicker _picker = ImagePicker();

  Map<String, int> _totais = {
    'total_saldo': 0, 'total_ganhos': 0, 'total_utilizados': 0,
  };
  bool _loading = true;
  bool _salvandoNome = false;

  @override
  void initState() {
    super.initState();
    _cliente = widget.cliente;
    _carregarTotais();
  }

  Future<void> _carregarTotais() async {
    if (_cliente.id == null) return;
    final totais = await widget.clienteRepo.getTotaisGlobais(_cliente.id!);
    if (!mounted) return;
    setState(() {
      _totais = totais;
      _loading = false;
    });
  }

  Future<void> _escolherFoto(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (foto == null) return;

      final atualizado = _cliente.copyWith(fotoPath: foto.path);
      setState(() => _cliente = atualizado);
      await widget.clienteRepo.updateCliente(_cliente);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar foto: $e')));
    }
  }

  Future<void> _removerFoto() async {
    final atualizado = Cliente(
      id: _cliente.id,
      nome: _cliente.nome,
      email: _cliente.email,
      fotoPath: null,
    );
    setState(() => _cliente = atualizado);
    await widget.clienteRepo.updateCliente(_cliente);
  }

  void _mostrarOpcoesFoto() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Foto de Perfil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(context);
                  _escolherFoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _escolherFoto(ImageSource.gallery);
                },
              ),
              if (_cliente.fotoPath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text(
                    'Remover foto',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _removerFoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editarNome() async {
    final controller = TextEditingController(text: _cliente.nome);
    final formKey = GlobalKey<FormState>();

    final novoNome = await showDialog<String>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          title: const Text('Editar nome'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(context, controller.text.trim());
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (novoNome == null || novoNome == _cliente.nome) return;

    setState(() => _salvandoNome = true);
    try {
      final atualizado = _cliente.copyWith(nome: novoNome);
      await widget.clienteRepo.updateCliente(atualizado);
      if (!mounted) return;
      setState(() => _cliente = atualizado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome atualizado com sucesso')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar nome: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvandoNome = false);
    }
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
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _mostrarOpcoesFoto,
                    child: Stack(
                      children: [
                        Hero(
                          tag: 'avatar_perfil',
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                            backgroundImage: _cliente.fotoPath != null
                                ? FileImage(File(_cliente.fotoPath!))
                                : null,
                            child: _cliente.fotoPath == null
                                ? Icon(Icons.person, size: 44, color: theme.colorScheme.primary)
                                : null,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF0F172A), width: 2),
                            ),
                            child: Icon(Icons.camera_alt, size: 16, color: theme.colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_cliente.nome, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      _salvandoNome
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : GestureDetector(
                              onTap: _editarNome,
                              child: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                            ),
                    ],
                  ),
                  Text(_cliente.email, style: TextStyle(color: Colors.grey[400])),
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
