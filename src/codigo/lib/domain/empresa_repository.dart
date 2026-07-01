import '../funcionalidades/empresa.dart';

abstract class EmpresaRepository {
  /// Cria o documento da empresa caso ainda não exista (idempotente).
  Future<void> garantirEmpresa(String id, String nome, String email);

  Future<Empresa?> getEmpresa(String id);

  /// A empresa pede para assinar um plano. Fica com statusPagamento
  /// 'pendente' até um admin liberar.
  Future<void> solicitarPlano(String id, String plano);

  /// Cancela uma solicitação pendente.
  Future<void> cancelarSolicitacao(String id);

  /// Libera de fato um plano para a empresa (assinatura de 30 dias a partir
  /// de agora). Usado pelo admin para aprovar uma solicitação, ou pela
  /// própria conta admin para testar os limites de cada plano.
  Future<void> liberarPlano(String id, String plano);

  /// Cancela a assinatura paga e volta a empresa para o plano grátis.
  Future<void> revogarAssinatura(String id);

  /// Lista de empresas com solicitação de plano pendente (uso do admin).
  Future<List<Empresa>> getSolicitacoesPendentes();

  /// Lista de todas as empresas cadastradas (uso do admin).
  Future<List<Empresa>> getTodasEmpresas();

  /// Busca uma empresa pelo e-mail da conta (uso do superusuário, para
  /// encontrar a conta antes de conceder uma permissão). Retorna `null`
  /// se nenhuma empresa tiver esse e-mail.
  Future<Empresa?> buscarPorEmail(String email);

  /// Define manualmente quantos estabelecimentos essa empresa pode
  /// cadastrar, além do que o plano contratado já permitiria (uso do
  /// superusuário). Passe `null` para remover a permissão extra e voltar
  /// a valer só o limite do plano.
  Future<void> definirLimiteExtra(String id, int? limite);
}
