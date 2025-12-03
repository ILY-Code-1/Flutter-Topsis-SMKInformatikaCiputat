import 'dart:math';
import '../models/siswa_model.dart';
import '../models/kriteria_model.dart';

class TopsisService {
  List<SiswaModel> hitungTopsis(
    List<SiswaModel> siswaList,
    List<KriteriaModel> kriteriaList,
  ) {
    if (siswaList.isEmpty || kriteriaList.isEmpty) return [];

    final matriksNormalisasi = _normalisasiMatriks(siswaList, kriteriaList);
    final matriksTerbobot = _pembobotanMatriks(matriksNormalisasi, kriteriaList);
    final solusiIdeal = _hitungSolusiIdeal(matriksTerbobot, kriteriaList);
    final jarakIdeal = _hitungJarakIdeal(matriksTerbobot, solusiIdeal);
    final nilaiPreferensi = _hitungNilaiPreferensi(jarakIdeal);

    final hasilList = <SiswaModel>[];
    for (int i = 0; i < siswaList.length; i++) {
      hasilList.add(siswaList[i].copyWith(skorTopsis: nilaiPreferensi[i]));
    }

    hasilList.sort((a, b) => (b.skorTopsis ?? 0).compareTo(a.skorTopsis ?? 0));

    for (int i = 0; i < hasilList.length; i++) {
      hasilList[i] = hasilList[i].copyWith(ranking: i + 1);
    }

    return hasilList;
  }

  List<Map<String, double>> _normalisasiMatriks(
    List<SiswaModel> siswaList,
    List<KriteriaModel> kriteriaList,
  ) {
    final pembagi = <String, double>{};

    for (var kriteria in kriteriaList) {
      double sumSquare = 0;
      for (var siswa in siswaList) {
        final nilai = siswa.nilai[kriteria.nama] ?? 0;
        sumSquare += nilai * nilai;
      }
      pembagi[kriteria.nama] = sqrt(sumSquare);
    }

    final matriksNormalisasi = <Map<String, double>>[];
    for (var siswa in siswaList) {
      final nilaiNormalisasi = <String, double>{};
      for (var kriteria in kriteriaList) {
        final nilai = siswa.nilai[kriteria.nama] ?? 0;
        final pembagiVal = pembagi[kriteria.nama] ?? 1;
        nilaiNormalisasi[kriteria.nama] =
            pembagiVal > 0 ? nilai / pembagiVal : 0;
      }
      matriksNormalisasi.add(nilaiNormalisasi);
    }

    return matriksNormalisasi;
  }

  List<Map<String, double>> _pembobotanMatriks(
    List<Map<String, double>> matriksNormalisasi,
    List<KriteriaModel> kriteriaList,
  ) {
    final matriksTerbobot = <Map<String, double>>[];

    for (var baris in matriksNormalisasi) {
      final nilaiTerbobot = <String, double>{};
      for (var kriteria in kriteriaList) {
        nilaiTerbobot[kriteria.nama] =
            (baris[kriteria.nama] ?? 0) * kriteria.bobot;
      }
      matriksTerbobot.add(nilaiTerbobot);
    }

    return matriksTerbobot;
  }

  Map<String, Map<String, double>> _hitungSolusiIdeal(
    List<Map<String, double>> matriksTerbobot,
    List<KriteriaModel> kriteriaList,
  ) {
    final solusiIdealPositif = <String, double>{};
    final solusiIdealNegatif = <String, double>{};

    for (var kriteria in kriteriaList) {
      final nilaiKriteria = matriksTerbobot
          .map((m) => m[kriteria.nama] ?? 0)
          .toList();

      if (kriteria.type == KriteriaType.benefit) {
        solusiIdealPositif[kriteria.nama] =
            nilaiKriteria.reduce((a, b) => a > b ? a : b);
        solusiIdealNegatif[kriteria.nama] =
            nilaiKriteria.reduce((a, b) => a < b ? a : b);
      } else {
        solusiIdealPositif[kriteria.nama] =
            nilaiKriteria.reduce((a, b) => a < b ? a : b);
        solusiIdealNegatif[kriteria.nama] =
            nilaiKriteria.reduce((a, b) => a > b ? a : b);
      }
    }

    return {
      'positif': solusiIdealPositif,
      'negatif': solusiIdealNegatif,
    };
  }

  List<Map<String, double>> _hitungJarakIdeal(
    List<Map<String, double>> matriksTerbobot,
    Map<String, Map<String, double>> solusiIdeal,
  ) {
    final jarakIdeal = <Map<String, double>>[];
    final solusiPositif = solusiIdeal['positif']!;
    final solusiNegatif = solusiIdeal['negatif']!;

    for (var baris in matriksTerbobot) {
      double jarakPositif = 0;
      double jarakNegatif = 0;

      for (var key in baris.keys) {
        final nilai = baris[key] ?? 0;
        jarakPositif += pow(nilai - (solusiPositif[key] ?? 0), 2);
        jarakNegatif += pow(nilai - (solusiNegatif[key] ?? 0), 2);
      }

      jarakIdeal.add({
        'positif': sqrt(jarakPositif),
        'negatif': sqrt(jarakNegatif),
      });
    }

    return jarakIdeal;
  }

  List<double> _hitungNilaiPreferensi(List<Map<String, double>> jarakIdeal) {
    final nilaiPreferensi = <double>[];

    for (var jarak in jarakIdeal) {
      final dPositif = jarak['positif'] ?? 0;
      final dNegatif = jarak['negatif'] ?? 0;
      final total = dPositif + dNegatif;
      nilaiPreferensi.add(total > 0 ? dNegatif / total : 0);
    }

    return nilaiPreferensi;
  }
}
