# Plano de Testes de Software

## Plano de Testes

O objetivo deste plano de testes é validar se todas as funcionalidades do aplicativo **GRUDA AÍ!** atendem aos requisitos funcionais e não funcionais definidos durante a especificação do projeto, garantindo que tanto os estabelecimentos quanto os clientes consigam utilizar a plataforma de forma segura, intuitiva e eficiente.

## Os testes foram elaborados considerando os dois principais fluxos da aplicação: o módulo da empresa (B2B) e o módulo do cliente (B2C). Os cenários foram definidos com base nos requisitos do sistema, como autenticação, geração de QR Code, acúmulo de pontos, carteira digital e resgate de recompensas.

# Cenários de Testes

| ID    | Cenário de Teste                  | Objetivo                                                    | Resultado Esperado                               |
| ----- | --------------------------------- | ----------------------------------------------------------- | ------------------------------------------------ |
| CT-01 | Cadastro de Empresa               | Verificar se um estabelecimento consegue criar uma conta    | Cadastro realizado com sucesso e acesso liberado |
| CT-02 | Login da Empresa                  | Validar autenticação do estabelecimento                     | Login efetuado corretamente                      |
| CT-03 | Cadastro de Cliente               | Verificar criação de conta do usuário                       | Conta criada e acesso ao aplicativo              |
| CT-04 | Login do Cliente                  | Validar autenticação do cliente                             | Login realizado com sucesso                      |
| CT-05 | Criação de Programa de Fidelidade | Verificar cadastro de pontos e recompensas                  | Programa salvo corretamente                      |
| CT-06 | Geração de QR Code                | Validar geração de QR Code exclusivo                        | QR Code criado e disponível para leitura         |
| CT-07 | Leitura do QR Code                | Confirmar que o cliente consegue escanear o código          | Pontos adicionados à carteira do cliente         |
| CT-08 | Carteira Digital                  | Verificar exibição dos estabelecimentos e saldo de pontos   | Informações apresentadas corretamente            |
| CT-09 | Resgate de Recompensa             | Validar troca de pontos por benefício                       | Pontuação descontada e recompensa registrada     |
| CT-10 | Validação de Cupom                | Confirmar utilização do benefício pelo estabelecimento      | Cupom validado apenas uma vez                    |
| CT-11 | Reutilização de QR Code           | Garantir que QR Code de uso único não possa ser reutilizado | Sistema bloqueia nova utilização                 |
| CT-12 | Desempenho da Leitura             | Avaliar tempo de resposta do sistema                        | Leitura e processamento em poucos segundos       |

---

# Funcionalidades Avaliadas

Durante os testes foram avaliadas as seguintes funcionalidades:

* Cadastro e autenticação de usuários e estabelecimentos.
* Configuração do programa de fidelidade.
* Geração de QR Codes.
* Leitura de QR Codes pelo cliente.
* Armazenamento de pontos na carteira digital.
* Exibição das recompensas disponíveis.
* Resgate de recompensas.
* Validação do cupom pelo estabelecimento.
* Invalidação de QR Codes e cupons após o primeiro uso.
* Tempo de resposta das operações.

Essas funcionalidades correspondem diretamente aos requisitos funcionais e não funcionais definidos na especificação do projeto.

---

# Grupo de Usuários

Os testes foram realizados utilizando dois perfis de usuários:

**Administrador (Empresa)**

* Cadastro do estabelecimento.
* Configuração do programa de fidelidade.
* Criação de recompensas.
* Geração e validação de QR Codes.

**Cliente**

* Cadastro e login.
* Escaneamento dos QR Codes.
* Consulta da carteira digital.
* Acúmulo de pontos.
* Resgate de recompensas.

Os participantes utilizaram smartphones Android com acesso à internet para simular o ambiente real de utilização do sistema.

---

# Ferramentas Utilizadas

Durante o desenvolvimento e os testes foram utilizadas as seguintes ferramentas:

| Ferramenta                   | Finalidade                                       |
| ---------------------------- | ------------------------------------------------ |
| Flutter                      | Desenvolvimento e execução do aplicativo         |
| Firebase Authentication      | Testes de autenticação                           |
| Cloud Firestore              | Persistência e validação dos dados               |
| Android Studio               | Execução dos testes em emuladores e dispositivos |
| Emulador Android             | Simulação de diferentes aparelhos                |
| Dispositivos físicos Android | Testes de usabilidade e desempenho               |

---

# Ferramentas de Testes (Opcional)

Os testes foram realizados principalmente de forma manual, simulando situações reais de uso do aplicativo.

Foram utilizados:

* **Testes Funcionais:** para verificar se cada funcionalidade atende aos requisitos especificados.
* **Testes de Integração:** para validar a comunicação entre Flutter e Firebase.
* **Testes de Usabilidade:** avaliando facilidade de navegação, clareza das telas e fluxo do usuário.
* **Testes de Validação:** garantindo que QR Codes e cupons sejam utilizados apenas uma única vez, conforme requisito de segurança.
* **Testes de Desempenho:** verificando o tempo de resposta durante autenticação, leitura do QR Code e atualização da carteira digital.

---

# Resultado Esperado

Ao final da execução dos testes espera-se confirmar que:

* Todos os fluxos do estabelecimento funcionam corretamente.
* O cliente consegue acumular pontos sem inconsistências.
* O resgate de recompensas ocorre corretamente.
* QR Codes e cupons são invalidados após o primeiro uso.
* A carteira digital apresenta as informações atualizadas.
* O sistema responde rapidamente às operações, proporcionando boa experiência ao usuário.

Dessa forma, os testes demonstram que os requisitos definidos para o aplicativo **GRUDA AÍ!** foram atendidos e que a aplicação apresenta funcionamento consistente para seus dois perfis de usuários.
