class DataPray {
  final String status;
  final Query query;
  final Schedule jadwal;

  DataPray({this.status, this.query, this.jadwal});

  factory DataPray.fromJson(Map<String, dynamic> json) {
    return DataPray(
        status: json['status'] as String,
        query: Query.fromJson(
          json['query'],
        ),
        jadwal: Schedule.fromJson(json['jadwal']));
  }
}

class Query {
  final String format;
  final String kota;
  final String tanggal;

  Query({this.format, this.kota, this.tanggal});
  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
        format: json['format'] as String,
        kota: json['kota'] as String,
        tanggal: json['tanggal'] as String);
  }
}

class Schedule {
  final String status;
  final Data data;

  Schedule({this.status, this.data});
  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
        status: json['status'] as String, data: Data.fromJson(json['data']));
  }
}

class Data {
  final String subuh;
  final String terbit;
  final String imsak;
  final String dhuha;
  final String dzuhur;
  final String ashar;
  final String maghrib;
  final String isya;

  Data(
      {this.subuh,
      this.terbit,
      this.imsak,
      this.dhuha,
      this.dzuhur,
      this.ashar,
      this.maghrib,
      this.isya});
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      ashar: json['ashar'] as String,
      dhuha: json['dhuha'] as String,
      dzuhur: json['dzuhur'] as String,
      subuh: json['subuh'] as String,
      imsak: json['imsak'] as String,
      maghrib: json['maghrib'] as String,
      isya: json['isya'] as String,
      terbit: json['terbit'] as String,
    );
  }
}
