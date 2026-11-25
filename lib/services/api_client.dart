import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:myportofolio_mobile/config.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Exception thrown when an API request returns a non-2xx status code.
class ApiException implements Exception {
  const ApiException(this.statusCode, this.message);

  final int statusCode;
  final String message;

  /// Pesan singkat yang aman ditampilkan ke pengguna.
  ///
  /// Isi respons mentah ([message]) tidak ditampilkan langsung karena bisa
  /// berupa halaman error HTML atau stack trace saat `DEBUG=True` di Django.
  String get readableMessage {
    if (statusCode == 401) {
      return 'Sesi login tidak valid. Silakan login lagi.';
    }
    if (statusCode == 403) {
      return 'Akun ini tidak punya izin untuk melakukan aksi ini.';
    }
    if (statusCode == 404) {
      return 'Data tidak ditemukan.';
    }
    if (statusCode >= 500) {
      return 'Terjadi kesalahan pada server. Coba lagi nanti.';
    }
    // 400: pesan validasi DRF, misalnya {"project_url": ["Enter a valid URL."]}
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic> && decoded.isNotEmpty) {
        return decoded.entries
            .map((entry) {
              final value = entry.value;
              final text = value is List ? value.join(' ') : value.toString();
              final isGeneral =
                  entry.key == 'detail' || entry.key == 'non_field_errors';
              return isGeneral ? text : '${entry.key}: $text';
            })
            .join('\n');
      }
    } on FormatException {
      // Bukan JSON (misalnya halaman HTML), pakai pesan umum di bawah.
    }
    return 'Permintaan tidak dapat diproses.';
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// HTTP client for the MyPortfolio Django REST Framework backend.
class ApiClient {
  ApiClient({http.Client? client, this.baseUrl = apiBaseUrl})
    : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Project>> getProjects() async {
    final response = await _client.get(
      _uri('/api/v1/projects/'),
      headers: const {'Accept': 'application/json'},
    );
    _ensureSuccess(response);

    final decoded = _decodeBody(response) as List<dynamic>;
    return decoded
        .map((item) => Project.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Project> createProject(
    Project project, {
    required String token,
  }) async {
    final response = await _client.post(
      _uri('/api/v1/projects/'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(project.toJson()),
    );
    _ensureSuccess(response);

    final decoded = _decodeBody(response) as Map<String, dynamic>;
    return Project.fromJson(decoded);
  }

  Future<String> obtainToken(String username, String password) async {
    final response = await _client.post(
      _uri('/api/v1/auth/token/'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );
    _ensureSuccess(response);

    final decoded = _decodeBody(response) as Map<String, dynamic>;
    return decoded['token'] as String;
  }

  Future<void> logout({required String token}) async {
    final response = await _client.post(
      _uri('/api/v1/auth/logout/'),
      headers: {'Accept': 'application/json', 'Authorization': 'Token $token'},
    );
    _ensureSuccess(response);
  }

  /// DRF mengirim `Content-Type: application/json` tanpa `charset`, sehingga
  /// `response.body` akan dibaca sebagai Latin-1. Byte-nya di-decode sebagai
  /// UTF-8 agar huruf non-ASCII (misalnya emoji) tidak rusak.
  Object? _decodeBody(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    throw ApiException(response.statusCode, response.body);
  }
}
