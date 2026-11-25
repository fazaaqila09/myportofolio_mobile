import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';

const String _baseUrl = 'http://test.local';

Map<String, dynamic> _projectJson({String title = 'MyPortfolio'}) {
  return <String, dynamic>{
    'id': '6f1c2a4e-1111-4c2b-9d1e-123456789abc',
    'title': title,
    'description': 'Website portofolio',
    'category': 'software',
    'category_display': 'Software / Web',
    'thumbnail': null,
    'project_url': 'https://example.com/',
    'star_count': 0,
  };
}

/// Respons JSON seperti DRF: `Content-Type` tanpa `charset`.
http.Response _jsonResponse(Object? body, int statusCode) {
  return http.Response.bytes(
    utf8.encode(jsonEncode(body)),
    statusCode,
    headers: const {'content-type': 'application/json'},
  );
}

void main() {
  group('ApiClient', () {
    test('getProjects mengambil daftar proyek tanpa token', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: _baseUrl,
        client: MockClient((request) async {
          sent = request;
          return _jsonResponse([_projectJson(title: 'Kedai Kopi ☕')], 200);
        }),
      );

      final projects = await apiClient.getProjects();

      expect(sent.method, 'GET');
      expect(sent.url.toString(), '$_baseUrl/api/v1/projects/');
      expect(sent.headers.containsKey('Authorization'), isFalse);
      // Teks non-ASCII tetap utuh walaupun respons tidak menyebut charset
      expect(projects.single.title, 'Kedai Kopi ☕');
    });

    test('createProject mengirim token dan body JSON', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: _baseUrl,
        client: MockClient((request) async {
          sent = request;
          return _jsonResponse(_projectJson(title: 'Proyek Baru'), 201);
        }),
      );
      const newProject = Project(
        title: 'Proyek Baru',
        description: 'Website portofolio',
        category: 'software',
        projectUrl: 'https://example.com/',
      );

      final created = await apiClient.createProject(newProject, token: 'abc');

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/projects/');
      expect(sent.headers['Authorization'], 'Token abc');
      expect(sent.headers['Content-Type'], startsWith('application/json'));
      final body = jsonDecode(sent.body) as Map<String, dynamic>;
      expect(body['title'], 'Proyek Baru');
      expect(body['project_url'], 'https://example.com/');
      expect(body.containsKey('id'), isFalse);
      expect(created.id, isNotNull);
    });

    test('obtainToken mengembalikan token dari server', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: _baseUrl,
        client: MockClient((request) async {
          sent = request;
          return _jsonResponse({'token': 'abc123'}, 200);
        }),
      );

      final token = await apiClient.obtainToken('owner', 'rahasia');

      expect(token, 'abc123');
      expect(sent.url.path, '/api/v1/auth/token/');
      expect(jsonDecode(sent.body), {
        'username': 'owner',
        'password': 'rahasia',
      });
    });

    test('status non-2xx dilempar sebagai ApiException', () async {
      final apiClient = ApiClient(
        baseUrl: _baseUrl,
        client: MockClient((request) async {
          return _jsonResponse({
            'non_field_errors': ['Unable to log in with provided credentials.'],
          }, 400);
        }),
      );

      await expectLater(
        apiClient.obtainToken('owner', 'salah'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having(
                (e) => e.readableMessage,
                'readableMessage',
                'Unable to log in with provided credentials.',
              ),
        ),
      );
    });

    test('logout mengirim token ke endpoint logout', () async {
      late http.Request sent;
      final apiClient = ApiClient(
        baseUrl: _baseUrl,
        client: MockClient((request) async {
          sent = request;
          return http.Response('', 204);
        }),
      );

      await apiClient.logout(token: 'abc');

      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/auth/logout/');
      expect(sent.headers['Authorization'], 'Token abc');
    });
  });

  group('ApiException.readableMessage', () {
    test('tidak menampilkan isi respons mentah', () {
      const notFound = ApiException(404, '<html>debug page</html>');
      const serverError = ApiException(500, 'Traceback ...');
      expect(notFound.readableMessage, 'Data tidak ditemukan.');
      expect(serverError.readableMessage, isNot(contains('Traceback')));
    });

    test('menampilkan pesan validasi per field', () {
      const badRequest = ApiException(
        400,
        '{"project_url": ["Enter a valid URL."]}',
      );
      expect(badRequest.readableMessage, 'project_url: Enter a valid URL.');
    });
  });

  group('AuthState', () {
    test('login menyimpan token dan memberi tahu listener', () async {
      final authState = AuthState(
        ApiClient(
          baseUrl: _baseUrl,
          client: MockClient((request) async {
            return _jsonResponse({'token': 'abc123'}, 200);
          }),
        ),
      );
      var notified = 0;
      authState.addListener(() => notified++);

      await authState.login('owner', 'rahasia');

      expect(authState.isLoggedIn, isTrue);
      expect(authState.token, 'abc123');
      expect(notified, 1);
    });

    test('logout tetap menghapus token walaupun server menolak', () async {
      final authState = AuthState(
        ApiClient(
          baseUrl: _baseUrl,
          client: MockClient((request) async {
            return _jsonResponse({'detail': 'Invalid token.'}, 401);
          }),
        ),
        initialToken: 'kedaluwarsa',
      );

      await authState.logout();

      expect(authState.isLoggedIn, isFalse);
      expect(authState.token, isNull);
    });
  });
}
