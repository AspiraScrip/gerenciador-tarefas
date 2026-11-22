import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Emite o usuário logado (ou null). O Firebase restaura a sessão sozinho
  /// quando o app é reaberto, então este stream já cobre o RF01 (sessão).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;

  String get uid => _auth.currentUser!.uid;

  Future<void> cadastrar({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
    final user = cred.user!;
    final usuario = Usuario(
      uid: user.uid,
      nome: nome.trim(),
      email: user.email ?? email.trim(),
    );
    await user.updateDisplayName(usuario.nome);
    await _db.child('usuarios/${user.uid}').set(usuario.toMap());
  }

  Future<void> entrar({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: senha);
  }

  Future<void> sair() => _auth.signOut();

  /// Acompanha os dados do usuário em tempo real (nome/e-mail).
  Stream<Usuario> usuarioStream(User user) {
    return _db.child('usuarios/${user.uid}').onValue.map((event) {
      final valor = event.snapshot.value;
      if (valor is Map) return Usuario.fromMap(user.uid, valor);
      return Usuario(
        uid: user.uid,
        nome: user.displayName ?? user.email?.split('@').first ?? 'Usuário',
        email: user.email ?? '',
      );
    });
  }

  static String traduzirErro(Object erro) {
    if (erro is FirebaseAuthException) {
      switch (erro.code) {
        case 'invalid-email':
          return 'E-mail inválido.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'E-mail ou senha incorretos.';
        case 'user-disabled':
          return 'Esta conta foi desativada.';
        case 'email-already-in-use':
          return 'Já existe uma conta com este e-mail.';
        case 'weak-password':
          return 'Senha fraca. Use pelo menos 6 caracteres.';
        case 'network-request-failed':
          return 'Sem conexão com a internet.';
        case 'too-many-requests':
          return 'Muitas tentativas. Tente novamente mais tarde.';
        case 'operation-not-allowed':
          return 'Login por e-mail/senha não está habilitado no Firebase.';
        default:
          return 'Erro de autenticação (${erro.code}).';
      }
    }
    return 'Ocorreu um erro inesperado: $erro';
  }
}
