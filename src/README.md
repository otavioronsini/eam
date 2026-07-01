# Instruções de Utilização

# Instalação do APK (Android)

Caso não seja necessário executar o código-fonte, é possível utilizar a versão já compilada do aplicativo.

## Download

1. Acesse o repositório do projeto no GitHub.
2. Localize o arquivo `app-release.apk`.
3. Faça o download do arquivo para o dispositivo Android.

## Instalação

1. Transfira o arquivo `flutter-apk.zip` para o dispositivo Android, caso o download tenha sido realizado em um computador.
2. Extraia o conteúdo da pasta e baixe o arquivo 'app-release.apk'
3. Abra o arquivo APK no dispositivo.
4. Caso seja solicitado, permita a instalação de aplicativos de fontes desconhecidas nas configurações do Android.
5. Confirme a instalação e aguarde sua conclusão.
6. Após instalada, a aplicação estará disponível na lista de aplicativos do dispositivo.

> **Observação:** Caso o Android exiba um aviso de segurança, selecione a opção para prosseguir com a instalação, desde que o APK tenha sido obtido diretamente do repositório oficial do projeto.

---

# Instruções de Utilização


## Requisitos

- Flutter SDK 3.x
- Dart SDK (compatível com o Flutter instalado)
- Android Studio ou Visual Studio Code
- Emulador Android ou dispositivo físico com depuração USB habilitada

## Configuração do projeto

1. Extraia o projeto.
2. Abra a pasta do projeto no Android Studio ou VS Code.
3. No terminal, execute:

```bash
flutter pub get
```

Caso alguma dependência não seja instalada automaticamente, execute:

```bash
flutter pub add platform_maps_flutter sqflite path
flutter pub get
```

## Executando o projeto

Verifique se há um dispositivo conectado:

```bash
flutter devices
```

Execute a aplicação:

```bash
flutter run
```

Ou utilize o botão **Run** do Android Studio/VS Code.

## Estrutura do projeto

```
lib/
 ├── domain/
 ├── funcionalidades/
 ├── telas/
 ├── firebase_options.dart
 └── main.dart
```

## Dependências principais

- Flutter
- Google Fonts
- SQFlite (banco de dados local)
- Path
- Platform Maps Flutter

## Observações

- O projeto utiliza Flutter como framework principal.
- Para executar corretamente, mantenha todas as dependências atualizadas.
- Caso ocorram erros de compilação, execute:

```bash
flutter clean
flutter pub get
flutter run
```

## Encerramento

Para finalizar a execução:

- pressione `q` no terminal do Flutter; ou
- encerre a aplicação pelo Android Studio/VS Code.
