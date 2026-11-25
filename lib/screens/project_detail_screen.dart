import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Halaman detail satu proyek yang dipilih dari [ProjectListScreen].
///
/// Gambar proyek hanya ditampilkan jika `thumbnail` tidak kosong.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          project.title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (project.thumbnail.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  project.thumbnail,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Text('Gambar tidak dapat dimuat.'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              project.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.category_outlined, size: 18),
                label: Text(project.categoryLabel),
              ),
            ),
            const SizedBox(height: 16),
            _DetailSection(
              title: 'Description',
              child: Text(project.description),
            ),
            _DetailSection(
              title: 'Project URL',
              child: SelectableText(project.projectUrl),
            ),
            _DetailSection(
              title: 'Stars',
              child: Text(project.starCount.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Satu bagian detail: judul tebal kecil dan isinya di bawah.
class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
