/// Contas de superusuário: acesso especial fora do fluxo normal de
/// Cliente/Empresa, usado só pela equipe do projeto para conceder, na mão,
/// permissão de cadastrar mais de 1 restaurante para uma empresa específica
/// (respeitando o teto definido pelos planos, veja [Plano.limiteMaximo]).
///
/// As contas em si são criadas no Firebase Authentication (mesmo lugar onde
/// vivem as contas de Cliente e Empresa) — este arquivo só define **quais
/// e-mails, depois de autenticados, têm permissão de abrir o painel de
/// superusuário**. Ver README do projeto para o passo a passo de como criar
/// essas contas no console do Firebase.
///
/// Importante: isto sozinho não impede que outra pessoa tente escrever
/// diretamente no Firestore. A proteção de verdade tem que vir das regras
/// de segurança do Firestore (veja o bloco sugerido no README), que devem
/// restringir a escrita dos campos `limiteExtra` e `admin` da coleção
/// `empresas` para requisições autenticadas com um destes e-mails.
class Superusuario {
  Superusuario._();

  static const List<String> emailsAutorizados = [
    'superadmin1@grudaai.com',
    'superadmin2@grudaai.com',
  ];

  static bool ehSuperusuario(String email) =>
      emailsAutorizados.contains(email.trim().toLowerCase());
}
