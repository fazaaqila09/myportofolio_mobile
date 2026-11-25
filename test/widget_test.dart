import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_detail_screen.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

/// Server palsu: login berhasil hanya untuk owner/rahasia.
ApiClient _fakeApi({List<Map<String, dynamic>> projects = const []}) {
  return ApiClient(
    baseUrl: 'http://test.local',
    client: MockClient((request) async {
      if (request.url.path == '/api/v1/auth/token/') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        if (body['username'] == 'owner' && body['password'] == 'rahasia') {
          return http.Response(jsonEncode({'token': 'abc123'}), 200);
        }
        return http.Response(
          jsonEncode({
            'non_field_errors': ['Unable to log in with provided credentials.'],
          }),
          400,
        );
      }
      if (request.url.path == '/api/v1/projects/') {
        return http.Response(jsonEncode(projects), 200);
      }
      return http.Response('', 404);
    }),
  );
}

Widget _wrap(ApiClient apiClient, Widget home) {
  return MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: apiClient),
      ChangeNotifierProvider<AuthState>(create: (_) => AuthState(apiClient)),
    ],
    child: MaterialApp(home: home),
  );
}

/// Halaman uji berisi satu tombol yang menjalankan `ensureLoggedIn`.
class _GuardHarness extends StatelessWidget {
  const _GuardHarness({required this.onResult});

  final void Function(bool loggedIn) onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async => onResult(await ensureLoggedIn(context)),
          child: const Text('Tambah Proyek'),
        ),
      ),
    );
  }
}

Finder get _loginButton => find.widgetWithText(ElevatedButton, 'Login');

void main() {
  testWidgets('belum login: guard membuka LoginScreen, lalu lanjut setelah '
      'login berhasil', (tester) async {
    bool? result;
    await tester.pumpWidget(
      _wrap(_fakeApi(), _GuardHarness(onResult: (value) => result = value)),
    );

    await tester.tap(find.text('Tambah Proyek'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // Field kosong ditolak validator
    await tester.tap(_loginButton);
    await tester.pump();
    expect(find.text('Username cannot be empty!'), findsOneWidget);
    expect(find.text('Password cannot be empty!'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'rahasia');
    await tester.tap(_loginButton);
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsNothing);
    expect(result, isTrue);
    final context = tester.element(find.text('Tambah Proyek'));
    expect(Provider.of<AuthState>(context, listen: false).token, 'abc123');
  });

  testWidgets('login gagal menampilkan SnackBar dan tetap di LoginScreen', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(_fakeApi(), const LoginScreen()));

    await tester.enterText(find.byType(TextFormField).at(0), 'owner');
    await tester.enterText(find.byType(TextFormField).at(1), 'salah');
    await tester.tap(_loginButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Login gagal (400)'), findsOneWidget);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('daftar proyek tampil tanpa login dan membuka detail', (
    tester,
  ) async {
    final apiClient = _fakeApi(
      projects: [
        <String, dynamic>{
          'id': '6f1c2a4e-1111-4c2b-9d1e-123456789abc',
          'title': 'MyPortfolio',
          'description': 'Website portofolio pribadi',
          'category': 'software',
          'category_display': 'Software / Web',
          'thumbnail': null,
          'project_url': 'https://example.com/',
          'star_count': 3,
        },
      ],
    );
    await tester.pumpWidget(_wrap(apiClient, const ProjectListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('MyPortfolio'), findsOneWidget);
    expect(find.text('Software / Web'), findsOneWidget);

    await tester.tap(find.text('MyPortfolio'));
    await tester.pumpAndSettle();

    expect(find.byType(ProjectDetailScreen), findsOneWidget);
    expect(find.text('https://example.com/'), findsOneWidget);
    // thumbnail kosong: tidak ada widget gambar
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('daftar proyek kosong menampilkan pesan', (tester) async {
    await tester.pumpWidget(_wrap(_fakeApi(), const ProjectListScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No projects found.'), findsOneWidget);
  });
}
