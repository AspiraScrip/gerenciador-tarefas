class Usuario {
  final String uid;
  final String nome;
  final String email;

  const Usuario({required this.uid, required this.nome, required this.email});

  Map<String, dynamic> toMap() => {'nome': nome, 'email': email};

  factory Usuario.fromMap(String uid, Map map) => Usuario(
        uid: uid,
        nome: map['nome']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
      );
}
