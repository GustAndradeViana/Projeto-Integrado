class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.email,
    required this.perfil,
    this.criadoEm,
  });

  final int id;
  final String nome;
  final String email;
  final String perfil;
  final String? criadoEm;

  bool get isCliente => perfil == 'cliente';
  bool get isPrestador => perfil == 'prestador';
}