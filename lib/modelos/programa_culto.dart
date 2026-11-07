import 'item_programa.dart';

class ProgramaCulto {
  final String id;
  String titulo;
  String data;
  String hora;

  String sinodo;
  String local; // Pastorado
  String congregacao;

  String dirigente;
  String pregador;
  String orador;
  String tipoCulto;
  List<ItemPrograma> itens;

  ProgramaCulto({
    required this.id,
    required this.titulo,
    required this.data,
    required this.hora,
    this.sinodo = '',
    this.local = '',
    this.congregacao = '',
    this.dirigente = '',
    this.pregador = '',
    this.orador = '',
    this.tipoCulto = 'padrao',
    List<ItemPrograma>? itens,
  }) : itens = itens ?? [];

  bool get cultoEspecial => tipoCulto == 'especial';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'data': data,
      'hora': hora,
      'sinodo': sinodo,
      'local': local,
      'congregacao': congregacao,
      'dirigente': dirigente,
      'pregador': pregador,
      'orador': orador,
      'tipoCulto': tipoCulto,
      'itens': itens.map((item) => item.toMap()).toList(),
    };
  }

  factory ProgramaCulto.fromMap(Map<String, dynamic> map) {
    final lista = map['itens'];

    return ProgramaCulto(
      id: map['id']?.toString() ?? '',
      titulo: map['titulo']?.toString() ?? '',
      data: map['data']?.toString() ?? '',
      hora: map['hora']?.toString() ?? '',
      sinodo: map['sinodo']?.toString() ?? '',
      local: map['local']?.toString() ?? '',
      congregacao: map['congregacao']?.toString() ?? '',
      dirigente: map['dirigente']?.toString() ?? '',
      pregador: map['pregador']?.toString() ?? '',
      orador: map['orador']?.toString() ?? '',
      tipoCulto: map['tipoCulto']?.toString() ?? 'padrao',
      itens: lista is List
          ? lista
              .whereType<Map>()
              .map(
                (item) => ItemPrograma.fromMap(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : [],
    );
  }

  ProgramaCulto copyWith({
    String? id,
    String? titulo,
    String? data,
    String? hora, 
    String? sinodo,
    String? local,
    String? congregacao,
    String? dirigente,
    String? pregador,
    String? orador,
    String? tipoCulto,
    List<ItemPrograma>? itens,
  }) {
    return ProgramaCulto(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      sinodo: sinodo ?? this.sinodo,
      local: local ?? this.local,
      congregacao: congregacao ?? this.congregacao,
      dirigente: dirigente ?? this.dirigente,
      pregador: pregador ?? this.pregador,
      orador: orador ?? this.orador,
      tipoCulto: tipoCulto ?? this.tipoCulto,
      itens: itens ?? this.itens,
    );
  }
}