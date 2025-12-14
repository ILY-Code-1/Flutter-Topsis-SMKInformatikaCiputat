import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/siswa_model.dart';
import '../models/kriteria_model.dart';
import '../models/riwayat_model.dart';
import '../../core/utils/key_generator.dart';

class FirebaseService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'topsis_results';

  /// Simpan hasil perhitungan TOPSIS ke Firestore
  /// Return: Key unik (TOPSIS-XXXXXX)
  Future<String> simpanHasil({
    required String namaFile,
    required List<SiswaModel> hasil,
    required List<KriteriaModel> kriteria,
  }) async {
    final key = KeyGenerator.generate();

    await _firestore.collection(_collection).doc(key).set({
      'key': key,
      'namaFile': namaFile,
      'tanggal': FieldValue.serverTimestamp(),
      'jumlahSiswa': hasil.length,
      'kriteria': kriteria.map((k) => k.toMap()).toList(),
      'hasil': hasil.map((s) => s.toMap()).toList(),
    });

    return key;
  }

  /// Ambil hasil berdasarkan key
  Future<RiwayatModel?> getHasilByKey(String key) async {
    if (!KeyGenerator.isValidKey(key)) return null;

    final doc = await _firestore.collection(_collection).doc(key).get();
    if (!doc.exists) return null;

    return _docToRiwayatModel(doc);
  }

  /// Ambil semua riwayat (limit 50, terbaru dulu)
  Future<List<RiwayatModel>> getAllRiwayat({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(_collection)
        .orderBy('tanggal', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => _docToRiwayatModel(doc)).toList();
  }

  /// Hapus riwayat berdasarkan key
  Future<void> hapusRiwayat(String key) async {
    await _firestore.collection(_collection).doc(key).delete();
  }

  /// Cek apakah key sudah ada
  Future<bool> isKeyExists(String key) async {
    final doc = await _firestore.collection(_collection).doc(key).get();
    return doc.exists;
  }

  /// Convert Firestore document ke RiwayatModel
  RiwayatModel _docToRiwayatModel(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime tanggal;
    if (data['tanggal'] is Timestamp) {
      tanggal = (data['tanggal'] as Timestamp).toDate();
    } else {
      tanggal = DateTime.now();
    }

    return RiwayatModel(
      id: data['key'] ?? doc.id,
      tanggal: tanggal,
      namaFile: data['namaFile'] ?? '',
      jumlahSiswa: data['jumlahSiswa'] ?? 0,
      kriteria: (data['kriteria'] as List?)
              ?.map((k) => KriteriaModel.fromMap(k as Map<String, dynamic>))
              .toList() ??
          [],
      hasil: (data['hasil'] as List?)
              ?.map((s) => SiswaModel.fromMap(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
