# Gerenciador de Tarefas — Flutter + Firebase

Projeto da **P2 – Programação Mobile**. Aplicativo de gerenciamento de tarefas pessoais com:

- **Firebase Authentication** (e-mail/senha, cadastro com nome, login, logout, sessão persistente)
- **Firebase Realtime Database** (CRUD das tarefas com listeners em tempo real, dados isolados por usuário)
- **Drawer** (Início, Minhas tarefas, Configurações, Sobre o aplicativo, Sair) com nome e e-mail do usuário
- **ListView** com cor/ícone de prioridade, detalhes, edição, exclusão e filtro
- **SharedPreferences** (tema claro/escuro persistido)
- **ThemeData / ThemeMode** (`lightTheme` e `darkTheme` aplicados a todas as telas)
- **Models** `Usuario` e `Tarefa`

## Estrutura

```
lib/
├── main.dart
├── firebase_options.dart        (gerado pelo flutterfire configure)
├── models/        usuario.dart, tarefa.dart
├── screens/       auth_gate, login, cadastro_usuario, home, tarefas,
│                  tarefa_detalhe, cadastro_tarefa, configuracoes, sobre
├── services/      auth_service, firebase_service, preferences_service
├── widgets/       drawer_menu, confirmar_dialog
└── themes/        app_theme, theme_controller
database.rules.json              (regras de segurança do Realtime Database)
```

## Pré-requisitos

- Flutter SDK 3.22+ (Dart 3.4+) — verifique com `flutter doctor`
- Node.js + Firebase CLI: `npm install -g firebase-tools`
- FlutterFire CLI: `dart pub global activate flutterfire_cli`
- Uma conta Google

## Passo a passo

### 1) Gerar as pastas de plataforma (android/ios)
Dentro da pasta do projeto:
```bash
flutter create --project-name gerenciador_tarefas --org br.edu.p2 .
```
O comando só cria o que falta (android, ios, etc.) e mantém `lib/` e `pubspec.yaml`.
Apague o teste padrão, que não se aplica a este app: `rm test/widget_test.dart`.

### 2) Criar o projeto no Firebase
1. Acesse <https://console.firebase.google.com> → **Adicionar projeto**.
2. **Authentication** → *Começar* → aba *Sign-in method* → habilite **E-mail/senha**.
3. **Realtime Database** → *Criar banco de dados* → escolha a região → inicie em **modo bloqueado**.
4. Aba **Regras** do Realtime Database → cole o conteúdo de `database.rules.json` → **Publicar**.

### 3) Conectar o app ao Firebase
```bash
firebase login
flutterfire configure
```
Selecione o projeto criado e as plataformas (Android/iOS). O comando gera/sobrescreve
`lib/firebase_options.dart` e os arquivos nativos (`google-services.json`, etc.).

> Se o Realtime Database foi criado **depois** do `flutterfire configure`, rode o comando
> novamente para que a `databaseURL` entre em `firebase_options.dart`.

### 4) Dependências e execução
```bash
flutter pub get
flutter run
```
Android: se houver erro de `minSdkVersion`, defina `minSdk = 23` em `android/app/build.gradle(.kts)`.

## Estrutura dos dados no Realtime Database

```
usuarios/
  {uid}/ nome, email
tarefas/
  {uid}/
    {idTarefa}/ titulo, descricao, dataVencimento (milissegundos), prioridade (baixa|media|alta), concluida (bool)
```
As regras garantem que cada usuário só leia/escreva o próprio nó (`auth.uid === $uid`).

## Capturas de tela
Salve as capturas na pasta `screenshots/` (login, cadastro, home, drawer, lista, detalhes,
cadastro/edição de tarefa, tema escuro, Realtime Database no console).

## Roteiro do vídeo de demonstração
1. Cadastro de um usuário.
2. Login com e-mail e senha.
3. Cadastro de pelo menos duas tarefas.
4. Edição e exclusão de uma tarefa.
5. Tarefas no ListView.
6. Logout e login novamente.
7. Tema escuro em Configurações → fechar e reabrir o app (o tema permanece).
8. Console do Firebase mostrando os dados em `tarefas/{uid}` (e o usuário em Authentication).
