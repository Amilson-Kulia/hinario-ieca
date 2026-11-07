import 'biblia_capitulo.dart';

class BibliaLivro {
  final String id; // Ex: "GEN", "MAT"
  final String nome; // Ex: "Gênesis", "Mateus"
  final List<BibliaCapitulo> capitulos;

  BibliaLivro({
    required this.id,
    required this.nome,
    required this.capitulos,
  });
}