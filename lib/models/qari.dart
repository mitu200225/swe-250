class Qari{

  String? id;
  String? name;
  String? path;
  String? format;
  String? suras;



  Qari({this.id,this.name, this.path, this.format, /*required server, required */this.suras});


  factory Qari.fromMp3QuranJson(Map<String, dynamic> json) {
    return Qari(
      id: json['id'].toString(),
      name: json['name'],
      path: json['Server'], // Base URL to audio
      format: json['format'] ?? 'mp3',
      suras: json['suras'],
    );
  }

}