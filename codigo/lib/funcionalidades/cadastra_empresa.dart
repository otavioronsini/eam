import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import '../domain/estabelecimento_repository.dart';
import 'estabelecimento.dart';
import 'mapa_selecao.dart';
import '../telas/empresa_detalhe_page.dart';
import 'dart:io';
import 'mapa_android.dart';

class CadastraEmpresaPage extends StatefulWidget {
  final Estabelecimento? estabelecimento;
  final EstabelecimentoRepository estabelecimentoRepo;
  final String empresaId;

  const CadastraEmpresaPage({
    super.key,
    this.estabelecimento,
    required this.estabelecimentoRepo,
    required this.empresaId,
  });

  @override
  State<CadastraEmpresaPage> createState() => _CadastraEmpresaPageState();
}

class _CadastraEmpresaPageState extends State<CadastraEmpresaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;

  double? _latitude;
  double? _longitude;

  bool get _editando => widget.estabelecimento != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.estabelecimento?.nome ?? '',
    );
    _descricaoController = TextEditingController(
      text: widget.estabelecimento?.descricao ?? '',
    );
    _latitude = widget.estabelecimento?.latitude;
    _longitude = widget.estabelecimento?.longitude;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _selecionarLocalizacao() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (Platform.isAndroid) {
            return AndroidMap(
              latitudeInicial: _latitude,
              longitudeInicial: _longitude,
            );
          }
          return MapaSelecaoPage(
            latitudeInicial: _latitude,
            longitudeInicial: _longitude,
          );
        },
      ),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione a localização no mapa')));
      return;
    }

    if (_editando) {
      final updated = widget.estabelecimento!.copyWith(
        nome: _nomeController.text.trim(),
        latitude: _latitude!, longitude: _longitude!,
        descricao: _descricaoController.text.trim(),
      );
      await widget.estabelecimentoRepo.updateEstabelecimento(updated);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => EmpresaDetalhePage(estabelecimento: updated, estabelecimentoRepo: widget.estabelecimentoRepo),
      ));
    } else {
      final estabelecimento = Estabelecimento(
        id: widget.empresaId,
        nome: _nomeController.text.trim(),
        latitude: _latitude!, longitude: _longitude!,
        descricao: _descricaoController.text.trim(),
      );

      final id = await widget.estabelecimentoRepo.insertEstabelecimento(estabelecimento);
      if (!mounted) return;
      final estSalvo = await widget.estabelecimentoRepo.getEstabelecimento(id);
      if (!mounted || estSalvo == null) return;

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => EmpresaDetalhePage(estabelecimento: estSalvo, estabelecimentoRepo: widget.estabelecimentoRepo),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizacaoTexto = _latitude == null
        ? 'Nenhuma localização selecionada'
        : 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}';

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(_editando ? 'Editar estabelecimento' : 'Cadastrar estabelecimento', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomeController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selecionarLocalizacao,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                child: const Text('Selecionar localização no mapa'),
              ),
              const SizedBox(height: 8),
              Text(localizacaoTexto, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                ),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_editando ? 'Salvar alterações' : 'Salvar', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}