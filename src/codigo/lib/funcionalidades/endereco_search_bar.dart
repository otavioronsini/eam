import 'package:flutter/material.dart';
import 'geocoding_service.dart';

/// Barra de pesquisa de endereço para ser usada sobre um mapa.
///
/// Mostra uma lista de sugestões abaixo do campo de texto; ao tocar em
/// uma delas, dispara [onEnderecoSelecionado] com as coordenadas exatas.
class EnderecoSearchBar extends StatefulWidget {
  final ValueChanged<ResultadoEndereco> onEnderecoSelecionado;

  const EnderecoSearchBar({super.key, required this.onEnderecoSelecionado});

  @override
  State<EnderecoSearchBar> createState() => _EnderecoSearchBarState();
}

class _EnderecoSearchBarState extends State<EnderecoSearchBar> {
  final _controller = TextEditingController();
  List<ResultadoEndereco> _resultados = [];
  bool _buscando = false;
  bool _mostrarResultados = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _buscar() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _buscando = true;
      _mostrarResultados = true;
    });

    final resultados = await GeocodingService.buscarEndereco(query);

    if (!mounted) return;
    setState(() {
      _resultados = resultados;
      _buscando = false;
    });

    if (resultados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nenhum endereço encontrado. Tente incluir rua, número e cidade.',
          ),
        ),
      );
    }
  }

  void _selecionar(ResultadoEndereco resultado) {
    setState(() {
      _mostrarResultados = false;
      _resultados = [];
      _controller.text = resultado.descricao;
    });
    widget.onEnderecoSelecionado(resultado);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(12),
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _buscar(),
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: 'Buscar endereço (rua, número, cidade...)',
              hintStyle: TextStyle(color: Colors.grey[600]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              suffixIcon: _buscando
                  ? const Padding(
                      padding: EdgeInsets.all(14),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.black54),
                      onPressed: _buscar,
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        if (_mostrarResultados && _resultados.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _resultados.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final r = _resultados[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Colors.black54,
                  ),
                  title: Text(
                    r.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                  onTap: () => _selecionar(r),
                );
              },
            ),
          ),
      ],
    );
  }
}
