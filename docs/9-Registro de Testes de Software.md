# Relatório de Testes de Software

## Introdução

## Este relatório apresenta os resultados obtidos durante a execução dos testes do aplicativo **GRUDA AÍ!**, desenvolvidos a partir do Plano de Testes previamente definido. O objetivo foi verificar se as funcionalidades implementadas atendem aos requisitos funcionais e não funcionais especificados, além de avaliar a experiência dos usuários durante a utilização do sistema. Os testes contemplaram os dois fluxos principais da aplicação: o módulo do estabelecimento (B2B) e o módulo do cliente (B2C).

# Execução dos Testes

Os testes foram realizados utilizando dispositivos Android físicos e emuladores, simulando situações reais de utilização do aplicativo. Foram avaliadas as funcionalidades de cadastro, autenticação, geração de QR Code, leitura do código, gerenciamento da carteira digital, resgate de recompensas e validação dos benefícios.

A tabela a seguir apresenta um resumo dos resultados obtidos.

| ID    | Cenário Testado                        | Resultado                |
| ----- | -------------------------------------- | ------------------------ |
| CT-01 | Cadastro da Empresa                    | Aprovado                 |
| CT-02 | Login da Empresa                       | Aprovado                 |
| CT-03 | Cadastro do Cliente                    | Aprovado                 |
| CT-04 | Login do Cliente                       | Aprovado                 |
| CT-05 | Configuração do Programa de Fidelidade | Aprovado                 |
| CT-06 | Geração de QR Code                     | Aprovado                 |
| CT-07 | Leitura do QR Code                     | Aprovado                 |
| CT-08 | Carteira Digital                       | Aprovado                 |
| CT-09 | Resgate de Recompensas                 | Aprovado                 |
| CT-10 | Validação de Cupom                     | Aprovado                 |
| CT-11 | Bloqueio de Reutilização do QR Code    | Aprovado                 |
| CT-12 | Desempenho Geral                       | Aprovado com observações |

---

# Evidências dos Testes

Durante os testes foi possível comprovar que:

* O cadastro e autenticação funcionaram corretamente para empresas e clientes.
* O estabelecimento conseguiu configurar programas de fidelidade e recompensas sem inconsistências.
* Os QR Codes foram gerados corretamente e puderam ser lidos pelos clientes.
* Após a leitura, os pontos foram registrados corretamente na carteira digital.
* O resgate das recompensas atualizou automaticamente o saldo de pontos do usuário.
* Os cupons foram invalidados após sua utilização, impedindo reutilização e garantindo o requisito de segurança.
* As telas apresentaram comportamento consistente com o fluxo definido no Projeto de Interface.

---

# Avaliação dos Resultados

De forma geral, os resultados foram satisfatórios e demonstraram que os principais requisitos da aplicação foram atendidos.

## Pontos Fortes

* Interface simples e intuitiva para clientes e estabelecimentos.
* Processo rápido de cadastro e autenticação.
* Geração e leitura de QR Codes funcionando corretamente.
* Carteira digital organizada e de fácil utilização.
* Integração eficiente com o Firebase para autenticação e armazenamento dos dados.
* Segurança garantida pela invalidação automática dos QR Codes e cupons após o primeiro uso.

## Pontos Fracos

Durante os testes também foram identificados alguns aspectos que podem ser aprimorados:

* Pequeno tempo de carregamento em algumas operações quando a conexão com a internet apresenta instabilidade.
* Ausência de mensagens mais detalhadas para alguns erros de autenticação.
* Necessidade de melhorar o feedback visual durante operações de processamento, como geração e validação dos QR Codes.
* Ainda não foram realizados testes com um grande número de usuários simultâneos, impossibilitando avaliar completamente a escalabilidade da aplicação.

---

# Falhas Detectadas

Durante a fase de testes foram observadas as seguintes situações:

| Falha Identificada                      | Impacto | Solução Proposta                                                          |
| --------------------------------------- | ------- | ------------------------------------------------------------------------- |
| Lentidão em conexões instáveis          | Baixo   | Implementar indicadores de carregamento e otimizar consultas ao Firestore |
| Mensagens de erro genéricas             | Baixo   | Criar mensagens mais claras para orientar o usuário                       |
| Pouco feedback visual durante operações | Médio   | Adicionar animações e indicadores de progresso                            |
| Ausência de testes de carga             | Médio   | Realizar testes com múltiplos usuários simultaneamente em futuras versões |

---

# Melhorias Propostas

Com base nos resultados obtidos, a equipe pretende implementar nas próximas iterações:

* Otimização das consultas ao Firebase para reduzir o tempo de resposta.
* Implementação de mensagens de erro mais descritivas.
* Inclusão de indicadores visuais de carregamento durante operações críticas.
* Realização de testes automatizados para funcionalidades principais.
* Execução de testes de carga e desempenho com múltiplos usuários simultâneos.
* Ampliação dos testes de usabilidade com um grupo maior de usuários para identificar oportunidades de melhoria na experiência de uso.

---

# Conclusão

Os testes realizados demonstraram que o aplicativo **GRUDA AÍ!** atende aos requisitos definidos para o projeto, apresentando funcionamento consistente nas principais funcionalidades de cadastro, autenticação, geração de QR Codes, acúmulo de pontos, carteira digital e resgate de recompensas.

As falhas encontradas possuem baixo impacto e não comprometem o funcionamento da aplicação, sendo relacionadas principalmente à experiência do usuário e ao desempenho em condições específicas de uso. As melhorias propostas serão incorporadas nas próximas iterações do desenvolvimento, tornando o sistema mais robusto, eficiente e intuitivo para seus usuários.
