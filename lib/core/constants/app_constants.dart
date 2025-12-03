class AppConstants {
  static const String appName = 'SMK Informatika Ciputat';
  static const String appTitle = 'Top Rank Siswa Menggunakan Algoritma TOPSIS';
  static const String copyright = '© SMK Informatika Ciputat - 2025';
  
  static const double maxWidth = 1200.0;
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;
  
  static const double borderRadiusSM = 8.0;
  static const double borderRadiusMD = 12.0;
  static const double borderRadiusLG = 16.0;
  static const double borderRadiusXL = 24.0;
  static const double borderRadiusXS = 4.0;
  
  static const String tujuanTitle = 'Tujuan';
  static const String tujuanDescription = 
      'Sistem ini dirancang untuk membantu proses seleksi dan pemeringkatan siswa '
      'secara objektif menggunakan metode TOPSIS (Technique for Order Preference '
      'by Similarity to Ideal Solution). Dengan pendekatan multi-kriteria, sistem '
      'dapat menghasilkan ranking yang adil dan transparan berdasarkan berbagai '
      'aspek penilaian seperti nilai akademik, kehadiran, sikap, dan kriteria lainnya.';
  
  static const String mengapaTopsisTitle = 'Mengapa TOPSIS?';
  static const String mengapaTopsisDescription = 
      'TOPSIS adalah salah satu metode pengambilan keputusan multi-kriteria yang '
      'paling populer dan terpercaya. Metode ini bekerja dengan prinsip bahwa '
      'alternatif terbaik adalah yang memiliki jarak terdekat dengan solusi ideal '
      'positif dan jarak terjauh dari solusi ideal negatif. Keunggulan TOPSIS: '
      'konsep sederhana, proses komputasi efisien, kemampuan mengukur kinerja '
      'relatif dari alternatif dalam bentuk matematis, dan hasil yang mudah dipahami.';
  
  static const List<String> topsisSteps = [
    'Normalisasi Matriks Keputusan',
    'Pembobotan Matriks Ternormalisasi',
    'Menentukan Solusi Ideal Positif & Negatif',
    'Menghitung Jarak ke Solusi Ideal',
    'Menghitung Nilai Preferensi',
    'Perangkingan Alternatif',
  ];
}
