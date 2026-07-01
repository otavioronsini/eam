# Arquitetura da Solução

## Visão Geral

O **GRUDA AÍ!** é uma aplicação mobile desenvolvida em **Flutter**, cujo objetivo é gerenciar programas de fidelidade entre estabelecimentos comerciais e clientes por meio de QR Codes. A solução utiliza uma arquitetura em camadas, separando a interface do usuário, a lógica de negócio, os serviços de acesso aos dados e a infraestrutura fornecida pelo Firebase.

A aplicação possui dois perfis de utilização:

- **Cliente (B2C):** responsável por escanear QR Codes, acumular pontos e resgatar recompensas.
- **Empresa (B2B):** responsável pelo gerenciamento do estabelecimento, cadastro de recompensas e geração de QR Codes.

O armazenamento das informações é realizado no **Cloud Firestore**, enquanto a autenticação dos usuários é feita pelo **Firebase Authentication**.

---

# Diagrama de Componentes

A Figura 1 apresenta a arquitetura da solução.

```text
                        +----------------------+
                        |     Usuário          |
                        | Cliente / Empresa    |
                        +----------+-----------+
                                   |
                                   |
                      Interface Flutter (Mobile)
                                   |
        +--------------------------+-------------------------+
        |                          |                         |
        |                          |                         |
+----------------+        +------------------+     +----------------+
|   Telas (UI)   | -----> | Regras de Negócio| ---> | Serviços       |
| Widgets        |        | Controllers      |      | Firebase       |
+----------------+        +------------------+      +--------+-------+
                                                              |
                          +-----------------------------------+
                          |
          +---------------+------------------+
          |                                  |
+-------------------------+       +---------------------------+
| Firebase Authentication |       | Cloud Firestore           |
| Login e Cadastro        |       | Usuários, Empresas,       |
|                         |       | Recompensas e QR Codes    |
+-------------------------+       +---------------------------+
```

**Figura 1 – Arquitetura da Solução**

---

# Componentes da Solução

A solução é composta pelos seguintes módulos.

## Interface Mobile

Desenvolvida utilizando **Flutter**, é responsável por toda a interação com o usuário.

Principais telas:

- Login;
- Cadastro de Cliente;
- Cadastro de Empresa;
- Seleção de Plano;
- Cadastro do Estabelecimento;
- Seleção da Localização;
- Carteira Digital;
- Empresas Parceiras;
- Geração de QR Code;
- Cadastro de Recompensas;
- Minha Conta.

---

## Camada de Lógica de Negócio

Responsável por implementar as regras da aplicação.

Entre suas responsabilidades estão:

- validação de formulários;
- gerenciamento da autenticação;
- controle das regras de pontuação;
- geração dos QR Codes;
- gerenciamento das recompensas;
- sincronização com o Firebase.

---

## Serviços

Camada responsável pela comunicação entre o aplicativo e os serviços externos.

São implementados serviços para:

- autenticação;
- leitura e gravação no Firestore;
- gerenciamento de usuários;
- gerenciamento de empresas;
- armazenamento das recompensas;
- atualização dos pontos dos clientes.

---

## Firebase Authentication

Responsável pelo gerenciamento dos usuários do sistema.

Principais funcionalidades:

- cadastro;
- login;
- autenticação segura;
- identificação do usuário logado.

---

## Cloud Firestore

Banco de dados NoSQL utilizado pelo aplicativo.

São armazenadas informações como:

- usuários;
- empresas;
- localização dos estabelecimentos;
- programas de fidelidade;
- recompensas;
- pontuação dos clientes;
- QR Codes gerados.

---

## Leitor de QR Code

O aplicativo utiliza a câmera do dispositivo para leitura dos QR Codes gerados pelos estabelecimentos.

Após a leitura:

1. o código é validado;
2. os pontos são registrados;
3. a carteira do cliente é atualizada.

---

# Fluxo da Solução

O funcionamento da aplicação ocorre conforme o fluxo apresentado abaixo.

```text
Cliente/Empresa

        │
        ▼

Aplicativo Flutter

        │
        ▼

Validação das informações

        │
        ▼

Firebase Authentication
(Login/Cadastro)

        │
        ▼

Cloud Firestore

        │
        ▼

Atualização dos dados

        │
        ▼

Resposta ao aplicativo

        │
        ▼

Interface atualizada
```

---

# Tecnologias Utilizadas

A solução foi desenvolvida utilizando as seguintes tecnologias.

| Tecnologia | Finalidade |
|------------|------------|
| Flutter | Desenvolvimento do aplicativo mobile |
| Dart | Linguagem de programação |
| Firebase Authentication | Autenticação dos usuários |
| Cloud Firestore | Banco de dados em tempo real |
| Google Maps / Platform Maps Flutter | Seleção da localização dos estabelecimentos |
| QR Code Scanner | Leitura dos QR Codes |
| Git | Controle de versão |
| GitHub | Hospedagem do código-fonte |
| Android Studio | Desenvolvimento e testes |
| Visual Studio Code | Desenvolvimento |

---

# Arquitetura Tecnológica

```text
                Usuário
                    │
                    ▼
            Aplicativo Flutter
                    │
      ┌─────────────┼─────────────┐
      ▼             ▼             ▼
 Interface      Firebase Auth   Google Maps
                    │
                    ▼
            Cloud Firestore
                    │
                    ▼
           Dados sincronizados
                    │
                    ▼
             Atualização da UI
```

---

# Hospedagem

Como se trata de uma aplicação mobile, não existe hospedagem tradicional da interface.

A solução foi disponibilizada através de um **APK Android**, permitindo sua instalação diretamente em dispositivos móveis.

O código-fonte foi hospedado em um repositório privado no **GitHub**, utilizado para controle de versão e desenvolvimento colaborativo.

A infraestrutura de backend é totalmente baseada no **Firebase**, utilizando os serviços gerenciados pelo Google para autenticação e armazenamento dos dados, eliminando a necessidade de servidores próprios.

---

# Considerações

A arquitetura adotada privilegia a separação de responsabilidades entre interface, regras de negócio e persistência de dados, facilitando a manutenção e evolução do sistema. A utilização do Flutter permite o desenvolvimento de uma interface única para dispositivos Android, enquanto o Firebase fornece serviços escaláveis para autenticação e armazenamento das informações do programa de fidelidade.
