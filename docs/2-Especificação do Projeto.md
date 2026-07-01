# Especificações do Projeto

## Stack Tecnológica

Frontend: Flutter & Dart - Aplicativo mobile para usuários (B2C) e interface para empresas (B2B).

Backend / BaaS: Firebase Authentication para gestão de usuários e Firestore para banco de dados NoSQL em tempo real.




## Requisitos Funcionais

### Módulo Empresa (B2B):

Cadastro e autenticação do estabelecimento.

Geração de QR Codes dinâmicos e atrelados a um desconto/benefício.

Leitura e validação de cupons resgatados pelos clientes.


### Módulo Usuário (B2C):

Cadastro e autenticação do usuário.

Câmera embutida para escanear o QR Code gerado pelo estabelecimento.

"Carteira Digital" para armazenar e visualizar cupons disponíveis e já utilizados.



## Requisitos Não Funcionais

Segurança (Uso Único): O QR Code gerado e o cupom resgatado devem ser invalidados no banco de dados (Firebase) imediatamente após o primeiro uso, evitando compartilhamento indevido.

Desempenho: O sistema deve processar a leitura do QR Code e a validação do cupom de forma quase instantânea.

Usabilidade: Interfaces distintas e intuitivas para o fluxo do lojista (focado em agilidade no balcão) e do consumidor (focado na clareza dos descontos).



## Fluxo de Uso (User Flow)

O cliente consome no estabelecimento e paga a conta.

A empresa acessa o app e gera um QR Code de recompensa.

O cliente abre o app "Gruda aí!" e escaneia o código.

Um cupom é gerado e salvo na carteira digital do cliente.

Na próxima visita, o cliente apresenta o cupom pelo app, a empresa valida, e o desconto é aplicado, invalidando o código em seguida.

> **Links Úteis**:
> - [O que são Requisitos Funcionais e Requisitos Não Funcionais?](https://codificar.com.br/requisitos-funcionais-nao-funcionais/)
> - [O que são requisitos funcionais e requisitos não funcionais?](https://analisederequisitos.com.br/requisitos-funcionais-e-requisitos-nao-funcionais-o-que-sao/)
