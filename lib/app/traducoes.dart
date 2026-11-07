import 'idioma_atual.dart';

class Traducoes {
  static const Map<String, String> pt = {
    'home': 'Home',
    'hinario': 'Hinário',
    'favoritos': 'Favoritos',
    'sobre': 'Sobre',
    'hino_do_dia': 'Hino do Dia',
    'palavra_do_dia': 'Palavra do Dia',
    'cantar_agora': 'Cantar Agora',
    'pesquisar_hino': 'Pesquisar hino...',
    'nenhum_hino': 'Nenhum hino encontrado',
    'resultados': 'resultados',
  };

  static const Map<String, String> umb = {
    // vamos preencher depois
  };

  static String texto(String chave) {
    if (IdiomaAtual.idioma == 'umb') {
      return umb[chave] ?? chave;
    }

    return pt[chave] ?? chave;
  }
}