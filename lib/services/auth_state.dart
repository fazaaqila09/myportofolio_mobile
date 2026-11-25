import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

/// Holds the in-memory authentication token for the current session.
///
/// Token hanya disimpan di memori, jadi setelah aplikasi ditutup pengguna
/// perlu login lagi. Widget yang memakai `context.watch<AuthState>()` dibangun
/// ulang setiap kali status login berubah.
class AuthState extends ChangeNotifier {
  AuthState(this._apiClient, {String? initialToken}) : _token = initialToken;

  final ApiClient _apiClient;
  String? _token;

  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _apiClient.obtainToken(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    final current = _token;
    if (current == null) return;

    try {
      await _apiClient.logout(token: current);
    } on ApiException {
      // Token mungkin sudah dicabut di server (401). Token lokal tetap dihapus.
    } on Exception {
      // Server tidak bisa dihubungi. Token lokal tetap dihapus.
    } finally {
      // Selalu keluar di sisi aplikasi, walaupun permintaan ke server gagal.
      _token = null;
      notifyListeners();
    }
  }
}
