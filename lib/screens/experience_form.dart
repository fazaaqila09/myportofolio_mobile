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
  // Kunci untuk mengakses FormState: menjalankan validate() dan reset().
  final _formKey = GlobalKey<FormState>();

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
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field formulir ditambahkan pada langkah berikutnya.
            ],
          ),
        ),
      ),
    );
  }
}
