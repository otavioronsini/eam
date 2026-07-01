import 'dart:convert';
import 'package:http/http.dart' as http;

/// Resultado de uma busca de endereço.
class ResultadoEndereco {
  final String descricao;
  final double latitude;
  final double longitude;

  ResultadoEndereco({
    required this.descricao,
    required this.latitude,
    required this.longitude,
  });
}

/// Busca endereços usando a API pública do OpenStreetMap (Nominatim).
///
/// Não exige chave de API, então funciona sem precisar configurar
/// faturamento do Google Maps — ideal para projeto de faculdade.
class GeocodingService {
  static const _baseUrl = 'https://nominatim.openstreetmap.org/search';

  static Future<List<ResultadoEndereco>> buscarEndereco(String query) async {
    final termo = query.trim();
    if (termo.isEmpty) return [];

    final uri = Uri.parse(_baseUrl).replace(queryParameters: {
      'format': 'json',
      'addressdetails': '0',
      'limit': '5',
      'countrycodes': 'br',
      'q': termo,
    });

    try {
      final response = await http.get(
        uri,
        // O Nominatim exige um User-Agent identificável no cabeçalho.
        headers: {'User-Agent': 'eam-gruda-ai/1.0'},
      );

      if (response.statusCode != 200) return [];

      final List<dynamic> dados = jsonDecode(response.body) as List<dynamic>;

      return dados.map((item) {
        final mapa = item as Map<String, dynamic>;
        return ResultadoEndereco(
          descricao: mapa['display_name'] as String? ?? termo,
          latitude: double.parse(mapa['lat'] as String),
          longitude: double.parse(mapa['lon'] as String),
        );
      }).toList();
    } catch (_) {
      // Sem internet, timeout, ou resposta inesperada: trata como "sem resultado".
      return [];
    }
  }
}
