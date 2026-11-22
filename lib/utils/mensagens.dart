import 'package:firebase_core/firebase_core.dart';

String mensagemErro(Object erro) {
  if (erro is FirebaseException) {
    return switch (erro.code) {
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'invalid-email' => 'O e-mail informado é inválido.',
      'weak-password' => 'Escolha uma senha mais forte.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' ||
      'invalid-login-credentials' =>
        'E-mail ou senha incorretos.',
      'user-disabled' => 'Esta conta está desativada.',
      'too-many-requests' => 'Muitas tentativas. Aguarde e tente novamente.',
      'network-request-failed' ||
      'disconnected' ||
      'unavailable' =>
        'Verifique sua conexão e tente novamente.',
      'permission-denied' ||
      'permission_denied' =>
        'Não foi possível acessar seus dados. Confira as regras do banco.',
      'operation-not-allowed' =>
        'Ative o login por e-mail e senha no Firebase.',
      _ => 'Não foi possível concluir a operação. Tente novamente.',
    };
  }
  return 'Não foi possível concluir a operação. Tente novamente.';
}
