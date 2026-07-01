# Plano de Testes de Usabilidade

## 1. Objetivo

Este documento apresenta o planejamento dos testes de usabilidade do aplicativo **GRUDA AÍ!**, cujo objetivo é avaliar se usuários conseguem realizar as principais funcionalidades do sistema de maneira intuitiva, eficiente e sem dificuldades significativas.

Os testes foram definidos com base na Especificação do Projeto e no Projeto de Interface, contemplando os fluxos do **Cliente** e do **Estabelecimento**. :contentReference[oaicite:0]{index=0} :contentReference[oaicite:1]{index=1}

---

# 2. Objetivos dos Testes

Os testes possuem os seguintes objetivos:

- Avaliar a facilidade de navegação entre as telas;
- Verificar se os usuários compreendem os fluxos do aplicativo sem auxílio;
- Identificar dificuldades durante o cadastro e autenticação;
- Validar a utilização da leitura de QR Code;
- Avaliar o processo de geração e utilização de recompensas;
- Identificar melhorias relacionadas à experiência do usuário.

---

# 3. Perfil dos Participantes

Os testes deverão ser realizados com dois perfis distintos de usuários.

## Cliente

Características:

- Idade entre 18 e 60 anos;
- Usuário de smartphone Android;
- Sem conhecimento prévio do aplicativo.

Quantidade sugerida:

- 5 participantes.

---

## Estabelecimento

Características:

- Proprietários ou funcionários de estabelecimentos comerciais;
- Familiaridade básica com smartphones.

Quantidade sugerida:

- 3 participantes.

---

# 4. Ambiente de Testes

Os testes serão realizados em:

- Smartphone Android;
- Aplicativo instalado via APK;
- Conexão com a internet;
- Ambiente silencioso;
- Observador responsável pelo acompanhamento dos testes.

---

# 5. Cenários de Teste

## Cenário 1 — Cadastro do Cliente

### Objetivo

Verificar se um novo usuário consegue criar sua conta.

### Operações

1. Abrir o aplicativo.
2. Selecionar a opção "Cliente".
3. Informar nome, e-mail e senha.
4. Finalizar o cadastro.
5. Realizar o login.

### Resultado Esperado

O usuário consegue criar sua conta sem auxílio.

---

## Cenário 2 — Escanear QR Code

### Objetivo

Validar o fluxo principal do cliente.

### Operações

1. Abrir o aplicativo.
2. Acessar a câmera.
3. Escanear o QR Code fornecido pelo estabelecimento.
4. Confirmar o recebimento da pontuação ou cupom.

### Resultado Esperado

O QR Code é reconhecido rapidamente e a recompensa é registrada na carteira do usuário.

---

## Cenário 3 — Consultar Carteira

### Objetivo

Avaliar a facilidade de localizar os pontos e recompensas.

### Operações

1. Abrir a tela "Minhas Carteiras".
2. Selecionar um estabelecimento.
3. Verificar saldo de pontos.
4. Visualizar recompensas disponíveis.

### Resultado Esperado

O usuário localiza facilmente suas informações.

---

## Cenário 4 — Cadastro do Estabelecimento

### Objetivo

Avaliar o processo de cadastro empresarial.

### Operações

1. Selecionar o perfil Empresa.
2. Escolher um plano.
3. Informar os dados do estabelecimento.
4. Informar a localização.
5. Finalizar o cadastro.

### Resultado Esperado

O estabelecimento é cadastrado corretamente.

---

## Cenário 5 — Cadastro de Recompensa

### Objetivo

Validar a configuração do programa de fidelidade.

### Operações

1. Abrir o painel administrativo.
2. Definir a quantidade de pontos por visita.
3. Criar uma recompensa.
4. Salvar.

### Resultado Esperado

A recompensa fica disponível para os clientes.

---

## Cenário 6 — Gerar QR Code

### Objetivo

Verificar a facilidade de geração do QR Code.

### Operações

1. Abrir o menu de geração.
2. Gerar um QR Code.
3. Exibir o código para um cliente.

### Resultado Esperado

O QR Code é gerado corretamente e pode ser utilizado pelo cliente.

---

# 6. Métricas Avaliadas

Durante os testes serão observados os seguintes indicadores:

- Tempo necessário para concluir cada tarefa;
- Quantidade de erros cometidos;
- Necessidade de auxílio do avaliador;
- Número de tentativas para completar cada operação;
- Taxa de sucesso das tarefas.

---

# 7. Questionário Pós-Teste

Após finalizar os testes, cada participante responderá às seguintes perguntas:

1. O aplicativo foi fácil de utilizar?
2. As informações estavam claras?
3. Foi fácil encontrar as funcionalidades desejadas?
4. Você encontrou alguma dificuldade?
5. Utilizaria este aplicativo em uma situação real?
6. Qual funcionalidade poderia ser melhorada?

As respostas poderão ser registradas utilizando uma escala de 1 a 5, sendo:

- 1 — Muito ruim
- 2 — Ruim
- 3 — Regular
- 4 — Bom
- 5 — Excelente

---

# 8. Critérios de Aceitação

Os testes serão considerados satisfatórios caso:

- Pelo menos 90% das tarefas sejam concluídas com sucesso;
- Os usuários consigam concluir os fluxos principais sem auxílio significativo;
- O tempo médio para execução das tarefas permaneça dentro do esperado;
- A avaliação média de satisfação seja igual ou superior a 4 em uma escala de 1 a 5.

---

# 9. Referências

- Especificação do Projeto. :contentReference[oaicite:2]{index=2}
- Projeto de Interface. :contentReference[oaicite:3]{index=3}
- Digital.gov – Usability Testing: https://digital.gov/topics/usability/
