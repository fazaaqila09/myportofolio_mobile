import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Proyek portofolio yang disinkronkan dengan Django REST Framework API
/// (`/api/v1/projects/`).
///
/// Field-nya mengikuti `ProjectSerializer` di backend saya (Tutorial 07):
/// `id`, `title`, `description`, `category`, `project_url`, dan `thumbnail`
/// (URL gambar proyek, opsional). Field hasil hitungan server seperti
/// `category_display` dan `star_count` hanya dibaca, tidak ikut dikirim.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.description,
    required this.category,
    required this.projectUrl,
    this.thumbnail = '',
    this.categoryDisplay = '',
    this.starCount = 0,
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// UUID dari server. Tidak dikirim saat POST karena dibuat oleh Django.
  @JsonKey(includeToJson: false)
  final String? id;

  final String title;
  final String description;

  /// Kunci kategori Django, misalnya `software` (lihat [projectCategories]).
  final String category;

  /// Label kategori dari server, misalnya `Software / Web`.
  @JsonKey(includeToJson: false, defaultValue: '')
  final String categoryDisplay;

  final String projectUrl;

  /// URL gambar proyek (opsional). Django mengirim `null` jika kosong.
  @JsonKey(defaultValue: '')
  final String thumbnail;

  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}

/// Pilihan kategori, sama dengan `Project.CATEGORY_CHOICES` di Django.
const Map<String, String> projectCategories = {
  'film': 'Film & Video',
  'software': 'Software / Web',
  'design': 'Design',
  'writing': 'Writing',
  'music': 'Music / Audio',
  'other': 'Other',
};

/// Helper tampilan. Ditaruh di extension (bukan getter di dalam kelas) agar
/// tidak ikut terbaca oleh `json_serializable`.
extension ProjectDisplay on Project {
  /// Label kategori yang siap ditampilkan.
  String get categoryLabel {
    if (categoryDisplay.isNotEmpty) {
      return categoryDisplay;
    }
    return projectCategories[category] ?? category;
  }
}
