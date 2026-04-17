class Trilho {
  final int id;
  final String nome;
  final double distancia;
  final String dificuldade;
  final String descricao;
  final String coordenadas;
  final double desnivel;

  Trilho({
    required this.id,
    required this.nome,
    required this.distancia,
    required this.dificuldade,
    required this.descricao,
    required this.coordenadas,
    required this.desnivel,
  });

  factory Trilho.fromMap(Map<String, dynamic> map) {
    return Trilho(
      id: map['id_trilho'],
      nome: map['nome'],
      distancia: map['distancia']?.toDouble() ?? 0.0,
      dificuldade: map['dificuldade'] ?? "",
      descricao: map['descricao'] ?? "",
      coordenadas: map['coordenadas'] ?? "",
      desnivel: map['desnivel']?.toDouble() ?? 0.0,
    );
  }
}
