class Validadores {
  static String? nome(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu nome.';
    if (valor.trim().length > 80) return 'Use até 80 caracteres.';
    return null;
  }

  static String? email(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe seu e-mail.';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(valor.trim())) {
      return 'Informe um e-mail válido.';
    }
    return null;
  }

  static String? senha(String? valor) {
    if (valor == null || valor.isEmpty) return 'Informe sua senha.';
    return null;
  }

  static String? novaSenha(String? valor) {
    final erro = senha(valor);
    if (erro != null) return erro;
    if (valor!.length < 6) return 'A senha deve ter pelo menos 6 caracteres.';
    return null;
  }

  static String? titulo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Informe o título da tarefa.';
    }
    if (valor.trim().length > 100) return 'Use até 100 caracteres.';
    return null;
  }
}
