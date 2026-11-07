class TextoLiturgico {
  final String titulo;
  final String subtitulo;
  final String texto;
  final String idioma;
  final String categoria;

  const TextoLiturgico({
    required this.titulo,
    required this.subtitulo,
    required this.texto,
    this.idioma = 'Português',
    this.categoria = 'Textos Litúrgicos',
  });
}
