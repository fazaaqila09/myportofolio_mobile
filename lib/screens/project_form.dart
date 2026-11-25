import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Form tambah proyek yang dikirim ke `POST /api/v1/projects/`.
///
/// Kolomnya mengikuti `ProjectSerializer` Django dari Tutorial 07: Title,
/// Description, Category, Project URL, dan Project Image URL (opsional,
/// disimpan di field `thumbnail`).
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Batas panjang mengikuti model Django (CharField 255, URLField 200).
  static const int _titleMaxLength = 255;
  static const int _urlMaxLength = 200;
  static const String _defaultCategory = 'software';

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _category = _defaultCategory;
  bool _isSubmitting = false;

  // Dinaikkan setiap form di-reset agar dropdown dibuat ulang dengan
  // kategori bawaan.
  int _formVersion = 0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _projectUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // Validasi

  static String? _validateRequired(
    String? value,
    String label, {
    int? maxLength,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return '$label tidak boleh kosong!';
    }
    if (maxLength != null && text.length > maxLength) {
      return '$label maksimal $maxLength karakter (sekarang ${text.length}).';
    }
    return null;
  }

  /// URL harus diawali http:// atau https:// dan punya host, sama seperti
  /// `URLField` di Django. Jika [isRequired] false, isian kosong diterima.
  static String? _validateUrl(
    String? value,
    String label, {
    bool isRequired = true,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return isRequired ? '$label tidak boleh kosong!' : null;
    }
    final uri = Uri.tryParse(text);
    final isValid =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isValid) {
      return 'Masukkan URL yang valid, diawali http:// atau https://';
    }
    if (text.length > _urlMaxLength) {
      return '$label maksimal $_urlMaxLength karakter '
          '(sekarang ${text.length}).';
    }
    return null;
  }

  // Aksi

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Cek login lagi: token bisa saja sudah hilang (misalnya logout dari
    // drawer) setelah form ini dibuka.
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final apiClient = context.read<ApiClient>();
    final authState = context.read<AuthState>();
    final token = authState.token;
    if (token == null) return;

    final newProject = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      projectUrl: _projectUrlController.text.trim(),
      thumbnail: _imageUrlController.text.trim(),
    );

    setState(() {
      _isSubmitting = true;
    });
    try {
      // Berhasil = 201 Created; server mengembalikan proyek beserta id-nya.
      final created = await apiClient.createProject(newProject, token: token);
      if (!mounted) return;
      await _showSuccessDialog(created);
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        // Token sudah tidak berlaku: keluar, lalu minta login ulang.
        await authState.logout();
        if (!mounted) return;
        _showSnackBar(
          'Sesi login berakhir. Silakan login lagi, lalu tekan Save.',
        );
        await ensureLoggedIn(context);
      } else {
        _showSnackBar(
          'Gagal menyimpan proyek (${e.statusCode}): ${e.readableMessage}',
        );
      }
    } on Exception {
      if (!mounted) return;
      _showSnackBar(
        'Tidak dapat terhubung ke server. Pastikan server Django berjalan.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog(Project project) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${project.title}'),
                Text('Description: ${project.description}'),
                Text('Category: ${project.categoryLabel}'),
                Text('Project URL: ${project.projectUrl}'),
                Text(
                  'Project Image URL: '
                  '${project.thumbnail.isEmpty ? '-' : project.thumbnail}',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    // reset() dulu untuk menghapus pesan error, baru kosongkan isian.
    _formKey.currentState!.reset();
    _titleController.clear();
    _descriptionController.clear();
    _projectUrlController.clear();
    _imageUrlController.clear();
    setState(() {
      _category = _defaultCategory;
      _formVersion++;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Tampilan

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'Judul proyek',
                validator: (value) => _validateRequired(
                  value,
                  'Title',
                  maxLength: _titleMaxLength,
                ),
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Deskripsi proyek',
                maxLines: 5,
                validator: (value) => _validateRequired(value, 'Description'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  key: ValueKey(_formVersion),
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: projectCategories.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    setState(() {
                      _category = newValue;
                    });
                  },
                ),
              ),
              _buildTextField(
                controller: _projectUrlController,
                label: 'Project URL',
                hint: 'https://github.com/username/proyek',
                keyboardType: TextInputType.url,
                validator: (value) => _validateUrl(value, 'Project URL'),
              ),
              _buildTextField(
                controller: _imageUrlController,
                label: 'Project Image URL (Optional)',
                hint: 'https://example.com/gambar.png',
                keyboardType: TextInputType.url,
                validator: (value) =>
                    _validateUrl(value, 'Project Image URL', isRequired: false),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
