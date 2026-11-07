class ReferenciaIeca {
  final int id;
  final String fonte;
  final String url;
  final String data;

  const ReferenciaIeca({
    required this.id,
    required this.fonte,
    required this.url,
    required this.data,
  });

  factory ReferenciaIeca.fromJson(Map<String, dynamic> json) {
    return ReferenciaIeca(
      id: json['id'] as int,
      fonte: json['fonte'] as String,
      url: json['url'] as String,
      data: json['data'] as String,
    );
  }
}