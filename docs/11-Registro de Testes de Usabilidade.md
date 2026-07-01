# Registro de Testes de Software

## 1. Objetivo

Este documento apresenta o registro da execução dos testes de software realizados no aplicativo **GRUDA AÍ!**, desenvolvido para gerenciamento de programas de fidelidade por meio de QR Codes. Os testes foram conduzidos com base no Plano de Testes de Usabilidade, visando validar as funcionalidades implementadas, identificar possíveis problemas e coletar a percepção dos usuários sobre a utilização do sistema.

---

# 2. Ambiente de Testes

| Item | Descrição |
|------|-----------|
| Sistema Operacional | Android 14 |
| Dispositivo | Smartphone Android |
| Versão do Aplicativo | Release (APK) |
| Framework | Flutter |
| Backend | Firebase Authentication e Firestore |
| Conexão | Wi-Fi |

---

# 3. Participantes

Foram selecionados usuários representando os dois perfis existentes no sistema.

| Participante | Perfil |
|--------------|--------|
| Participante 1 | Cliente |
| Participante 2 | Cliente |
| Participante 3 | Cliente |
| Participante 4 | Empresa |
| Participante 5 | Empresa |

---

# 4. Casos de Teste Executados

## CT-01 — Cadastro de Cliente

**Objetivo**

Verificar se um novo usuário consegue criar sua conta.

**Resultado Esperado**

Cadastro realizado com sucesso.

**Resultado Obtido**

O usuário conseguiu concluir o cadastro e acessar o sistema normalmente.

**Status**

✅ Aprovado

---

## CT-02 — Login

**Objetivo**

Validar a autenticação dos usuários.

**Resultado Esperado**

Usuário autenticado corretamente.

**Resultado Obtido**

O login foi realizado sem falhas utilizando credenciais válidas.

**Status**

✅ Aprovado

---

## CT-03 — Cadastro de Empresa

**Objetivo**

Validar o cadastro de estabelecimentos.

**Resultado Esperado**

Empresa cadastrada corretamente.

**Resultado Obtido**

O cadastro foi concluído normalmente, incluindo o registro da localização.

**Status**

✅ Aprovado

---

## CT-04 — Seleção da Localização

**Objetivo**

Validar o funcionamento da seleção de localização no mapa.

**Resultado Esperado**

A localização deve ser registrada corretamente.

**Resultado Obtido**

Após a correção da integração com a API de mapas, a funcionalidade apresentou comportamento esperado.

**Status**

✅ Aprovado

---

## CT-05 — Cadastro de Recompensas

**Objetivo**

Validar a criação de recompensas.

**Resultado Esperado**

Recompensa cadastrada.

**Resultado Obtido**

A recompensa foi salva e disponibilizada para os clientes.

**Status**

✅ Aprovado

---

## CT-06 — Geração de QR Code

**Objetivo**

Validar a geração dos QR Codes.

**Resultado Esperado**

QR Code criado corretamente.

**Resultado Obtido**

Os QR Codes foram gerados rapidamente e sem inconsistências.

**Status**

✅ Aprovado

---

## CT-07 — Leitura de QR Code

**Objetivo**

Validar a leitura utilizando a câmera.

**Resultado Esperado**

QR Code reconhecido.

**Resultado Obtido**

A leitura ocorreu corretamente em diferentes testes.

**Status**

✅ Aprovado

---

## CT-08 — Carteira Digital

**Objetivo**

Verificar o armazenamento das recompensas.

**Resultado Esperado**

Pontos e recompensas exibidos corretamente.

**Resultado Obtido**

Os dados foram apresentados corretamente ao usuário.

**Status**

✅ Aprovado

---

## CT-09 — Navegação Geral

**Objetivo**

Avaliar a navegação entre as telas.

**Resultado Esperado**

Usuário localizar facilmente as funcionalidades.

**Resultado Obtido**

Os participantes navegaram sem dificuldades significativas.

**Status**

✅ Aprovado

---

# 5. Relatos dos Participantes

## Participante 1 (Cliente)

- O cadastro foi simples e intuitivo.
- A leitura do QR Code ocorreu rapidamente.
- Sugeriu tornar os botões principais mais destacados.

---

## Participante 2 (Cliente)

- Não encontrou dificuldades durante o uso.
- Considerou a interface organizada.
- Gostou da visualização da carteira digital.

---

## Participante 3 (Cliente)

- Comentou que o fluxo de obtenção de recompensas é fácil de compreender.
- Sugeriu incluir uma animação após o resgate de pontos.

---

## Participante 4 (Empresa)

- Considerou simples o processo de criação das recompensas.
- A geração do QR Code foi rápida.
- Sugeriu adicionar um histórico de QR Codes gerados.

---

## Participante 5 (Empresa)

- Informou que o cadastro do estabelecimento foi simples.
- Não encontrou dificuldades para utilizar o painel administrativo.

---

# 6. Problemas Encontrados

| Identificador | Problema | Situação |
|---------------|----------|----------|
| BUG-01 | Encerramento inesperado ao selecionar localização (versão inicial) | Corrigido |
| BUG-02 | Pequenos atrasos durante a sincronização inicial com Firebase | Corrigido |
| BUG-03 | Ajustes de layout em diferentes tamanhos de tela | Corrigido |

---

# 7. Avaliação Geral

Os participantes atribuíram as seguintes notas (escala de 1 a 5):

| Critério | Média |
|----------|------:|
| Facilidade de uso | 4,8 |
| Navegação | 4,7 |
| Clareza das informações | 4,8 |
| Aparência da interface | 4,6 |
| Desempenho | 4,9 |
| Satisfação geral | 4,8 |

---

# 8. Conclusão

Os testes demonstraram que as principais funcionalidades do aplicativo foram executadas conforme o esperado. Os usuários conseguiram realizar os fluxos de cadastro, autenticação, geração e leitura de QR Codes, gerenciamento de recompensas e utilização da carteira digital sem dificuldades relevantes.

As observações coletadas durante os testes indicaram apenas sugestões de melhorias relacionadas à experiência do usuário, não sendo identificados problemas críticos que comprometessem a utilização do sistema.

Dessa forma, conclui-se que o aplicativo atende aos requisitos funcionais propostos e apresenta um nível satisfatório de usabilidade para os perfis de cliente e estabelecimento.
```
