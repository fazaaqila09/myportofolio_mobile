import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Halaman formulir untuk menambahkan Experience baru.
///
/// Field dan aturan validasinya mengikuti model `Experience` dan
/// `ExperienceForm` pada proyek Django `myportofolio`.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  // Batas panjang mengikuti max_length di model Django.
  static const int _titleMaxLength = 255; // title = CharField(max_length=255)
  static const int _roleMaxLength = 100; // role = CharField(max_length=100)
  static const int _urlMaxLength = 200; // URLField: max_length bawaan 200

  // Kunci untuk mengakses FormState: menjalankan validate() dan reset().
  final _formKey = GlobalKey<FormState>();

  // Controller menyimpan isian setiap field teks dan ikut dikosongkan oleh
  // _formKey.currentState!.reset().
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();

  @override
  void dispose() {
    // Controller wajib dilepas agar tidak terjadi kebocoran memori.
    _titleController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    super.dispose();
  }

  // Validator

  /// Isian wajib: menolak nilai kosong, nilai yang hanya berisi spasi
  /// (karena di-trim dulu), dan nilai yang melebihi [maxLength] karakter.
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
    return null; // null berarti valid
  }

  /// Isian opsional: boleh kosong, tetapi tetap dibatasi [maxLength] karakter.
  static String? _validateOptional(String? value, String label, int maxLength) {
    final text = value?.trim() ?? '';
    if (text.length > maxLength) {
      return '$label maksimal $maxLength karakter (sekarang ${text.length}).';
    }
    return null;
  }

  /// URL opsional: boleh kosong; jika diisi harus URL http/https yang memiliki
  /// host (setara URLField di Django) dan tidak lebih dari [_urlMaxLength].
  static String? _validateOptionalUrl(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(text);
    final isWebUrl = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      return 'Masukkan URL yang valid, diawali http:// atau https://';
    }
    if (text.length > _urlMaxLength) {
      return 'URL maksimal $_urlMaxLength karakter.';
    }
    return null;
  }

  // Tampilan

  /// Satu field teks dengan gaya yang seragam (border membulat, label, hint).
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar memakai warna primer tema yang sama dengan halaman utama.
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon drawer (dan tombol kembali) berwarna putih agar terlihat.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer yang sama dengan halaman utama dan form proyek.
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView membuat seluruh field dan tombol Simpan tetap
        // bisa dijangkau pada layar sempit atau saat papan ketik muncul.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Nama organisasi / kegiatan (wajib) ===
              _buildTextField(
                controller: _titleController,
                label: 'Nama Organisasi / Kegiatan',
                hint: 'Contoh: COMPFEST 18',
                validator: (value) => _validateRequired(
                  value,
                  'Nama organisasi / kegiatan',
                  maxLength: _titleMaxLength,
                ),
              ),

              // === Peran / posisi (opsional) ===
              _buildTextField(
                controller: _roleController,
                label: 'Peran / Posisi (opsional)',
                hint: 'Contoh: VPIC of Transportation',
                validator: (value) =>
                    _validateOptional(value, 'Peran / posisi', _roleMaxLength),
              ),

              // === Deskripsi (wajib) ===
              _buildTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Ceritakan pengalamanmu',
                maxLines: 5,
                validator: (value) => _validateRequired(value, 'Deskripsi'),
              ),

              // === URL foto dokumentasi (opsional) ===
              _buildTextField(
                controller: _thumbnailController,
                label: 'URL Foto Dokumentasi (opsional)',
                hint: 'https://...',
                keyboardType: TextInputType.url,
                validator: _validateOptionalUrl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
