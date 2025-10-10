class ApiConfig{
  /// Base URL utama API kamu
  static const String baseUrl = 'http://127.0.0.1:93/api';
  static const String basePublicUrl = 'http://127.0.0.1:93';
}

class ApiEndpoints{
  //  Auth
  static const String loginSatker = '${ApiConfig.baseUrl}/login-satker';
  static const String logoutSatker = '${ApiConfig.baseUrl}/logout-satker';

  //  Data Master (superadmin)
  static const String dataSatker = '${ApiConfig.baseUrl}/datasatker';

  // Dapatkan URL foto user
  static String fotoSatker(String fileName) {
    return '${ApiConfig.basePublicUrl}/assets/img/satker/$fileName';
  }

  //static const String fotoUser = '${ApiConfig.baseUrl}/assets/img/satker/${user['foto']}';
  //static const String fotoUser = 'http://127.0.0.1:93/assets/img/satker/${user['foto']}';

  //  Dashboard
  static const String dashboardSummary = '${ApiConfig.baseUrl}/dashboard-summary';

  //  Data Berita
  static const String dataBerita = '${ApiConfig.baseUrl}/data-berita';

  //  Tambahan contoh lain
  static const String konfigurasiBerita = '${ApiConfig.baseUrl}/konfigurasi-berita';
  //
}