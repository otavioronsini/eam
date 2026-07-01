import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'endereco_search_bar.dart';
import 'geocoding_service.dart';

class AndroidMap extends StatefulWidget {
  final double? latitudeInicial;
  final double? longitudeInicial;

  const AndroidMap({super.key, this.latitudeInicial, this.longitudeInicial});

  @override
  State<AndroidMap> createState() => _AndroidMapState();
}

class _AndroidMapState extends State<AndroidMap> {
  final MapController _mapController = MapController();
  LatLng? selecionado;

  @override
  void initState() {
    super.initState();

    if (widget.latitudeInicial != null && widget.longitudeInicial != null) {
      selecionado = LatLng(widget.latitudeInicial!, widget.longitudeInicial!);
    }
  }

  void _aoEncontrarEndereco(ResultadoEndereco resultado) {
    final local = LatLng(resultado.latitude, resultado.longitude);
    setState(() {
      selecionado = local;
    });
    _mapController.move(local, 17);
  }

  @override
  Widget build(BuildContext context) {
    final centro = selecionado ?? LatLng(-21.787, -46.561);

    return Scaffold(
      appBar: AppBar(title: const Text('Selecionar localização')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centro,
              initialZoom: 15,
              onTap: (tapPosition, point) {
                setState(() {
                  selecionado = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.eam',
              ),
              if (selecionado != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: selecionado!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: EnderecoSearchBar(onEnderecoSelecionado: _aoEncontrarEndereco),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selecionado);
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
