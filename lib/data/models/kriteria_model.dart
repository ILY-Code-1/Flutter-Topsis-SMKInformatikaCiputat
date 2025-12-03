enum KriteriaType { benefit, cost }

class KriteriaModel {
  final String nama;
  final double bobot;
  final KriteriaType type;

  KriteriaModel({
    required this.nama,
    required this.bobot,
    this.type = KriteriaType.benefit,
  });

  factory KriteriaModel.fromMap(Map<String, dynamic> map) {
    return KriteriaModel(
      nama: map['nama'] ?? '',
      bobot: (map['bobot'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] == 'cost' ? KriteriaType.cost : KriteriaType.benefit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'bobot': bobot,
      'type': type == KriteriaType.cost ? 'cost' : 'benefit',
    };
  }

  @override
  String toString() => 'KriteriaModel(nama: $nama, bobot: $bobot, type: $type)';
}
