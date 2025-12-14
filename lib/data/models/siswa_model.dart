class SiswaModel {
  final String id;
  final String nama;
  final String kelas;
  final Map<String, double> nilai;
  double? skorTopsis;
  int? ranking;

  SiswaModel({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.nilai,
    this.skorTopsis,
    this.ranking,
  });

  factory SiswaModel.fromMap(Map<String, dynamic> map) {
    final nilai = <String, double>{};
    
    // Kolom yang bukan kriteria (tidak dihitung nilainya)
    final excludedKeys = {'id', 'no', 'nama', 'kelas'};
    
    map.forEach((key, value) {
      final lowerKey = key.toString().toLowerCase();
      if (!excludedKeys.contains(lowerKey)) {
        if (value is num) {
          nilai[key] = value.toDouble();
        } else if (value is String) {
          final parsed = double.tryParse(value);
          if (parsed != null) {
            nilai[key] = parsed;
          }
        }
      }
    });

    return SiswaModel(
      id: map['id']?.toString() ?? map['no']?.toString() ?? map['No']?.toString() ?? '',
      nama: map['nama']?.toString() ?? map['Nama']?.toString() ?? '',
      kelas: map['kelas']?.toString() ?? map['Kelas']?.toString() ?? '-',
      nilai: nilai,
      skorTopsis: (map['skorTopsis'] as num?)?.toDouble(),
      ranking: map['ranking'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'kelas': kelas,
      'nilai': nilai,
      'skorTopsis': skorTopsis,
      'ranking': ranking,
    };
  }

  SiswaModel copyWith({
    String? id,
    String? nama,
    String? kelas,
    Map<String, double>? nilai,
    double? skorTopsis,
    int? ranking,
  }) {
    return SiswaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      kelas: kelas ?? this.kelas,
      nilai: nilai ?? this.nilai,
      skorTopsis: skorTopsis ?? this.skorTopsis,
      ranking: ranking ?? this.ranking,
    );
  }

  @override
  String toString() {
    return 'SiswaModel(id: $id, nama: $nama, kelas: $kelas, nilai: $nilai, skorTopsis: $skorTopsis, ranking: $ranking)';
  }
}
