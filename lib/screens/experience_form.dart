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

  // Pilihan kategori disamakan dengan EXPERIENCE_CHOICES di model Django:
  // kunci = nilai yang disimpan, nilai = label yang ditampilkan.
  static const Map<String, String> _categories = {
    'organization': 'Organization',
    'committee': 'Committee',
    'volunteer': 'Volunteer',
    'part-time': 'Part-Time',
    'full-time': 'Full-Time',
    'internship': 'Internship',
  };

  // Kunci untuk mengakses FormState: menjalankan validate() dan reset().
  final _formKey = GlobalKey<FormState>();

  // Kategori terpilih; default 'full-time' sama seperti di model Django.
  String _category = 'full-time';

  // Tanggal disimpan sebagai DateTime; null berarti belum dipilih.
  // Tanggal selesai yang kosong berarti kegiatan masih berlangsung.
  DateTime? _startDate;
  DateTime? _endDate;

  // Controller menyimpan isian setiap field teks dan ikut dikosongkan oleh
  // _formKey.currentState!.reset().
  final _titleController = TextEditingController();
  final _roleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _thumbnailController = TextEditingController();
  // Controller tanggal hanya untuk menampilkan tanggal terpilih di field.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    // Controller wajib dilepas agar tidak terjadi kebocoran memori.
    _titleController.dispose();
    _roleController.dispose();
    _descriptionController.dispose();
    _thumbnailController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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

  /// Tanggal mulai wajib dipilih.
  String? _validateStartDate(String? _) {
    if (_startDate == null) {
      return 'Tanggal mulai wajib dipilih!';
    }
    return null;
  }

  /// Tanggal selesai boleh kosong (masih berlangsung), tetapi tidak boleh
  /// lebih awal dari tanggal mulai (sama seperti clean() di ExperienceForm).
  String? _validateEndDate(String? _) {
    final start = _startDate;
    final end = _endDate;
    if (start != null && end != null && end.isBefore(start)) {
      return 'Tanggal selesai tidak boleh sebelum tanggal mulai.';
    }
    return null;
  }

  // Tanggal

  /// Format YYYY-MM-DD, sama dengan format tanggal di Django.
  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Membuka kalender lewat showDatePicker(), lalu menyimpan hasilnya ke state
  /// dan menampilkannya di field. Membatalkan kalender tidak mengubah apa pun.
  Future<void> _pickDate({required bool isStart}) async {
    final current = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    // Halaman bisa saja sudah ditutup saat kalender masih terbuka.
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = _formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = _formatDate(picked);
      }
    });
  }

  /// Mengosongkan tanggal selesai (kembali ke status "masih berlangsung").
  void _clearEndDate() {
    setState(() {
      _endDate = null;
      _endDateController.clear();
    });
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

  /// Field tanggal: read-only, membuka kalender saat ditekan, dan tetap
  /// divalidasi oleh Form karena berupa TextFormField.
  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required VoidCallback onTap,
    required FormFieldValidator<String> validator,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: 'YYYY-MM-DD',
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          suffixIcon: suffixIcon,
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

              // === Kategori (wajib, pilihan dari EXPERIENCE_CHOICES) ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: _categories.entries
                      .map((entry) => DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Kategori wajib dipilih!' : null,
                ),
              ),

              // === URL foto dokumentasi (opsional) ===
              _buildTextField(
                controller: _thumbnailController,
                label: 'URL Foto Dokumentasi (opsional)',
                hint: 'https://...',
                keyboardType: TextInputType.url,
                validator: _validateOptionalUrl,
              ),

              // === Tanggal mulai (wajib) ===
              _buildDateField(
                controller: _startDateController,
                label: 'Tanggal Mulai',
                onTap: () => _pickDate(isStart: true),
                validator: _validateStartDate,
              ),

              // === Tanggal selesai (opsional; kosong = masih berlangsung) ===
              _buildDateField(
                controller: _endDateController,
                label: 'Tanggal Selesai (kosongkan jika masih berlangsung)',
                onTap: () => _pickDate(isStart: false),
                validator: _validateEndDate,
                suffixIcon: _endDate == null
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Kosongkan tanggal selesai',
                        onPressed: _clearEndDate,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
