import 'package:flutter/material.dart';
import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'endereco_search_bar.dart';
import 'geocoding_service.dart';

class MapaSelecaoPage extends StatefulWidget {
  final double? latitudeInicial;
  final double? longitudeInicial;

  const MapaSelecaoPage({
    super.key,
    this.latitudeInicial,
    this.longitudeInicial,
  });

  @override
  State<MapaSelecaoPage> createState() => _MapaSelecaoPageState();
}

class _MapaSelecaoPageState extends State<MapaSelecaoPage> {
  late CameraPosition _cameraPosition;
  LatLng? _selectedLocation;
  PlatformMapController? _mapController;

  @override
  void initState() {
    super.initState();
    if (widget.latitudeInicial != null && widget.longitudeInicial != null) {
      _selectedLocation =
          LatLng(widget.latitudeInicial!, widget.longitudeInicial!);
      _cameraPosition = CameraPosition(
        target: _selectedLocation!,
        zoom: 16,
      );
    } else {
      _cameraPosition = const CameraPosition(
        target: LatLng(-23.55052, -46.633308),
        zoom: 14,
      );
    }
  }

  void _confirmarSelecao() {
    if (_selectedLocation == null) return;
    Navigator.pop(context, _selectedLocation);
  }

  void _aoEncontrarEndereco(ResultadoEndereco resultado) {
    final local = LatLng(resultado.latitude, resultado.longitude);
    setState(() {
      _selectedLocation = local;
    });
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: local, zoom: 17),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{
      if (_selectedLocation != null)
        Marker(
          markerId: MarkerId('selecionado'),
          position: _selectedLocation!,
        ),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecione a localização'),
        actions: [
          TextButton(
            onPressed: _selectedLocation == null ? null : _confirmarSelecao,
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PlatformMap(
            initialCameraPosition: _cameraPosition,
            markers: markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: true,
            onTap: (location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 16,
            child: EnderecoSearchBar(onEnderecoSelecionado: _aoEncontrarEndereco),
          ),
          if (_selectedLocation != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: ElevatedButton(
                onPressed: _confirmarSelecao,
                child: const Text('Confirmar localização'),
              ),
            ),
        ],
      ),
    );
  }
}
