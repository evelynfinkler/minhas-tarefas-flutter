# Minhas tarefas

## Requisitos

- Flutter 3.47.4 ou uma versão estável compatível, com Dart incluído.
- Chrome para executar a versão Web.
- Android Studio com Android SDK, Java compatível e um celular ou emulador para executar a versão Android.
- Android 7.0 ou superior.
- Node.js para instalar as ferramentas de configuração do Firebase.

## Configuração do projeto

Abra no terminal a pasta que contém o arquivo `pubspec.yaml` e execute:

```powershell
flutter doctor
flutter pub get
```

Corrija as pendências indicadas pelo `flutter doctor` para a plataforma que será utilizada.

## Configuração do Firebase

O aplicativo utiliza Firebase Authentication com e-mail e senha e Firebase Realtime Database. Para vincular o aplicativo a um projeto Firebase, siga os passos abaixo.

1. Acesse o [Firebase Console](https://console.firebase.google.com/) e crie ou selecione um projeto.
2. Em Authentication, ative o método de login E-mail/senha.
3. Crie um Realtime Database em modo bloqueado e copie a URL do banco.
4. Em Realtime Database > Regras, copie todo o conteúdo do arquivo `database.rules.json` e clique em Publicar.
5. No terminal do Windows, instale as ferramentas e faça login:

```powershell
npm.cmd install -g firebase-tools
firebase.cmd login
dart pub global activate flutterfire_cli
```

6. Na pasta do projeto, execute o comando abaixo, substituindo `SEU_ID_DO_PROJETO` pelo ID mostrado nas configurações do Firebase:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=SEU_ID_DO_PROJETO --platforms=android,web --out=lib/firebase_options.dart
```

Confirme a substituição do arquivo `lib/firebase_options.dart`, caso seja solicitada. O identificador Android do aplicativo é `br.com.estudo.minhas_tarefas`.

7. Confira se a propriedade `databaseURL` nos blocos `FirebaseOptions` de Android e Web corresponde à URL do banco criado. Se a propriedade estiver ausente, adicione-a dentro de cada bloco:

```dart
databaseURL: 'URL_DO_REALTIME_DATABASE',
```

Substitua `URL_DO_REALTIME_DATABASE` pelo endereço completo copiado do console. Essa propriedade pertence ao arquivo gerado pelo FlutterFire, dentro de `FirebaseOptions`.

Ao utilizar os arquivos Firebase já configurados neste repositório, não é necessário gerá-los novamente. A conta utilizada para configurar outro projeto deve ter acesso a esse projeto no Firebase.

## Execução no navegador

Na pasta do projeto, execute:

```powershell
flutter run -d chrome
```

## Execução no Android

Inicie um emulador Android ou conecte um celular com a depuração USB ativada. Depois, execute:

```powershell
flutter devices
flutter run
```

Se houver mais de um dispositivo disponível, selecione o Android ou informe o identificador exibido pelo `flutter devices`:

```powershell
flutter run -d ID_DO_DISPOSITIVO
```

## Geração do APK de teste

Com o Android SDK configurado, execute:

```powershell
flutter build apk --debug
```

O arquivo será gerado em `build/app/outputs/flutter-apk/app-debug.apk`.
