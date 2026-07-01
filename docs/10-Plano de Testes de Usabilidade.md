# Plano de Testes de Usabilidade

## 1. Objetivo

Este documento apresenta o planejamento dos testes de usabilidade do aplicativo **GRUDA AÍ!**, desenvolvido em Flutter, com o objetivo de avaliar a facilidade de uso, eficiência e compreensão dos fluxos principais por usuários finais e estabelecimentos parceiros.

Os testes contemplam as principais funcionalidades implementadas no sistema, como autenticação, cadastro de estabelecimentos, seleção de localização, geração e leitura de QR Code, gerenciamento de recompensas e utilização da carteira de fidelidade.

---

# 2. Objetivos dos Testes

Os testes possuem os seguintes objetivos:

- Avaliar a facilidade de navegação entre as telas;
- Verificar se os usuários compreendem os fluxos do sistema sem treinamento prévio;
- Validar o processo de cadastro de clientes e empresas;
- Avaliar o processo de seleção de localização no mapa;
- Verificar a facilidade de geração e leitura de QR Codes;
- Avaliar o gerenciamento de recompensas e estabelecimentos;
- Identificar possíveis dificuldades de utilização.

---

# 3. Participantes

Serão selecionados usuários pertencentes aos dois perfis existentes no sistema.

## Cliente

Perfil:

- Usuário de smartphone Android;
- Idade superior a 18 anos;
- Sem conhecimento prévio do aplicativo.

Quantidade sugerida:

- 5 participantes.

---

## Empresa

Perfil:

- Proprietário ou funcionário de estabelecimento comercial;
- Conhecimento básico em smartphones.

Quantidade sugerida:

- 3 participantes.

---

# 4. Ambiente de Testes

Os testes serão realizados utilizando:

- Smartphone Android;
- APK da versão Release;
- Conexão com a internet;
- Banco de dados Firebase configurado;
- QR Codes previamente cadastrados para teste.

---

# 5. Cenários de Teste

## Cenário 1 — Cadastro do Cliente

### Objetivo

Verificar se um novo usuário consegue criar uma conta.

### Operações

1. Abrir o aplicativo.
2. Selecionar a opção de cadastro.
3. Informar nome, e-mail e senha.
4. Confirmar o cadastro.
5. Efetuar login.

### Resultado Esperado

O usuário conclui o cadastro e acessa o sistema sem dificuldades.

---

## Cenário 2 — Cadastro da Empresa

### Objetivo

Avaliar o fluxo de cadastro de estabelecimentos.

### Operações

1. Selecionar o perfil Empresa.
2. Informar os dados do estabelecimento.
3. Selecionar a localização utilizando o mapa.
4. Salvar o cadastro.

### Resultado Esperado

O estabelecimento é cadastrado corretamente e sua localização é registrada.

---

## Cenário 3 — Cadastro de Plano

### Objetivo

Verificar se o estabelecimento consegue selecionar um plano disponível.

### Operações

1. Acessar a tela de planos.
2. Escolher um plano.
3. Confirmar a seleção.

### Resultado Esperado

O plano é associado ao estabelecimento.

---

## Cenário 4 — Cadastro de Recompensas

### Objetivo

Validar o gerenciamento das recompensas oferecidas pelo estabelecimento.

### Operações

1. Acessar o painel do estabelecimento.
2. Criar uma nova recompensa.
3. Definir a quantidade de pontos necessária.
4. Salvar.

### Resultado Esperado

A recompensa passa a aparecer para os clientes.

---

## Cenário 5 — Gerar QR Code

### Objetivo

Avaliar a geração de QR Codes de fidelidade.

### Operações

1. Acessar a opção "Gerar QR Code".
2. Gerar um novo código.
3. Exibir o código para um cliente.

### Resultado Esperado

O QR Code é criado corretamente e fica disponível para leitura.

---

## Cenário 6 — Leitura do QR Code

### Objetivo

Verificar o funcionamento da câmera integrada.

### Operações

1. Abrir a função de leitura.
2. Apontar a câmera para um QR Code válido.
3. Confirmar o recebimento da recompensa.

### Resultado Esperado

O QR Code é reconhecido rapidamente e os pontos são registrados.

---

## Cenário 7 — Consulta da Carteira

### Objetivo

Avaliar a facilidade para visualizar os estabelecimentos cadastrados.

### Operações

1. Abrir a tela principal.
2. Selecionar um estabelecimento.
3. Consultar saldo de pontos.
4. Visualizar recompensas disponíveis.

### Resultado Esperado

As informações são apresentadas de forma clara.

---

## Cenário 8 — Consulta dos Dados da Conta

### Objetivo

Validar a visualização das informações do usuário.

### Operações

1. Abrir a tela "Minha Conta".
2. Verificar os dados cadastrados.

### Resultado Esperado

Os dados são exibidos corretamente.

---

## Cenário 9 — Navegação Geral

### Objetivo

Avaliar a organização da interface.

### Operações

Solicitar que o usuário navegue livremente entre:

- Página Inicial;
- Empresas;
- Carteira;
- Conta;
- Detalhes do estabelecimento.

### Resultado Esperado

O usuário consegue localizar todas as funcionalidades sem auxílio.

---

# 6. Dados Coletados

Durante cada teste serão registrados:

- Tempo para conclusão das tarefas;
- Número de erros;
- Quantidade de solicitações de ajuda;
- Número de tentativas necessárias;
- Taxa de conclusão das tarefas.

Também serão anotadas observações referentes à navegação, compreensão das telas e dificuldades encontradas.

---

# 7. Questionário Pós-Teste

Após concluir todas as tarefas, cada participante responderá ao seguinte questionário.

Avalie cada item utilizando uma escala de 1 a 5.

| Item | Avaliação |
|-------|-----------|
| Facilidade de uso | 1 2 3 4 5 |
| Facilidade de navegação | 1 2 3 4 5 |
| Clareza das informações | 1 2 3 4 5 |
| Facilidade para localizar funções | 1 2 3 4 5 |
| Velocidade do aplicativo | 1 2 3 4 5 |
| Aparência da interface | 1 2 3 4 5 |
| Satisfação geral | 1 2 3 4 5 |

Perguntas abertas:

- O que foi mais fácil durante o uso?
- Qual funcionalidade apresentou maior dificuldade?
- Houve alguma tela que gerou dúvidas?
- Que melhorias você sugere para futuras versões?

---

# 8. Critérios de Aceitação

Os testes serão considerados satisfatórios caso:

- Pelo menos 90% das tarefas sejam concluídas com sucesso;
- Os usuários realizem os fluxos principais sem necessidade constante de auxílio;
- A média de satisfação seja igual ou superior a 4 em uma escala de 1 a 5;
- Não sejam identificados erros críticos que impeçam a utilização do aplicativo.

---

# 9. Ferramentas Utilizadas

- Aplicativo GRUDA AÍ! (APK Release)
- Smartphones Android
- Firebase
- Câmera do dispositivo
- QR Codes de teste
- Formulário de avaliação dos participantes

---

# 10. Referências

- Especificação do Projeto.
- Projeto de Interface.
- Digital.gov – Usability Testing  
  https://digital.gov/topics/usability/
