/// Definições dos planos de assinatura disponíveis para uma Empresa.
///
/// Tudo num único lugar de propósito: para mudar limite, nome ou preço de um
/// plano, basta editar os mapas abaixo.
class Plano {
  static const String gratis = 'gratis';
  static const String basico = 'basico';
  static const String intermediario = 'intermediario';
  static const String top = 'top';

  /// Planos pagos, na ordem em que devem aparecer na tela de assinatura.
  static const List<String> pagos = [basico, intermediario, top];

  /// Quantos estabelecimentos cada plano permite cadastrar.
  static const Map<String, int> _limites = {
    gratis: 1,
    basico: 2,
    intermediario: 3,
    top: 4,
  };

  static const Map<String, String> _nomes = {
    gratis: 'Grátis',
    basico: 'Básico',
    intermediario: 'Intermediário',
    top: 'Top',
  };

  /// Valores de exemplo — troque pelos preços reais que for cobrar.
  static const Map<String, double> _precos = {
    basico: 49.90,
    intermediario: 89.90,
    top: 129.90,
  };

  static int limiteDe(String plano) => _limites[plano] ?? 1;

  static String nomeDe(String plano) => _nomes[plano] ?? 'Grátis';

  static double precoDe(String plano) => _precos[plano] ?? 0;

  static bool ehValido(String plano) => _limites.containsKey(plano);

  /// Maior limite de restaurantes entre todos os planos existentes (hoje,
  /// o do plano Top). Usado como teto para permissões manuais concedidas
  /// por um superusuário: ele nunca pode liberar mais estabelecimentos do
  /// que o próprio plano mais alto permitiria.
  static int get limiteMaximo =>
      _limites.values.reduce((a, b) => a > b ? a : b);
}
