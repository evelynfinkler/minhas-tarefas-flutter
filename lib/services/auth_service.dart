import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  Usuario? _converter(User? user) => user == null
      ? null
      : Usuario(
          uid: user.uid,
          nome: user.displayName?.trim().isNotEmpty == true
              ? user.displayName!
              : user.email?.split('@').first ?? 'Usuário',
          email: user.email ?? '',
        );
  Usuario? get usuarioAtual => _converter(_auth.currentUser);
  Stream<Usuario?> get usuarioChanges => _auth.userChanges().map(_converter);

  Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: senha);
  }

  Future<void> cadastrar(String nome, String email, String senha) async {
    final resultado = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: senha);
    await resultado.user!.updateDisplayName(nome.trim());
  }

  Future<void> sair() => _auth.signOut();
}
