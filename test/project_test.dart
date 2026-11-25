import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/models/project.dart';

void main() {
  group('Project', () {
    test('fromJson membaca respons DRF (snake_case)', () {
      final project = Project.fromJson(<String, dynamic>{
        'id': '6f1c2a4e-1111-4c2b-9d1e-123456789abc',
        'title': 'MyPortfolio',
        'title_indo': '',
        'description': 'Website portofolio',
        'description_indo': '',
        'category': 'software',
        'category_display': 'Software / Web',
        'thumbnail': null,
        'project_url': 'https://example.com/',
        'star_count': 2,
        'is_starred': false,
        'starred_by_names': 'andi, budi',
      });

      expect(project.id, '6f1c2a4e-1111-4c2b-9d1e-123456789abc');
      expect(project.title, 'MyPortfolio');
      expect(project.projectUrl, 'https://example.com/');
      expect(project.categoryLabel, 'Software / Web');
      expect(project.starCount, 2);
      // thumbnail bernilai null di JSON menjadi string kosong
      expect(project.thumbnail, isEmpty);
    });

    test('toJson hanya mengirim field yang bisa ditulis', () {
      const project = Project(
        title: 'Proyek Baru',
        description: 'Dibuat dari Flutter',
        category: 'design',
        projectUrl: 'https://example.com/baru/',
        thumbnail: 'https://example.com/baru.png',
        categoryDisplay: 'Design',
        starCount: 5,
        id: 'tidak-boleh-terkirim',
      );

      expect(project.toJson(), <String, dynamic>{
        'title': 'Proyek Baru',
        'description': 'Dibuat dari Flutter',
        'category': 'design',
        'project_url': 'https://example.com/baru/',
        'thumbnail': 'https://example.com/baru.png',
      });
    });

    test('categoryLabel memakai pilihan lokal jika server tidak mengirim', () {
      const project = Project(
        title: 'A',
        description: 'B',
        category: 'music',
        projectUrl: 'https://example.com/',
      );
      expect(project.categoryLabel, 'Music / Audio');
    });
  });
}
