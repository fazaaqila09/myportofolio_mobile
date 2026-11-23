import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  // Lebar maksimum isi halaman, agar tampilan tetap rapi di jendela lebar.
  static const double _maxContentWidth = 480;

  final String npm = "2506613142";
  final String nama = "Muhammad Faza Aqila";
  final String kelas = "PBP C";

  // Tombol aksi beserta warnanya. Shade 700 dipilih supaya teks dan ikon
  // putih di atasnya tetap terbaca (kontras cukup tinggi).
  final List<ItemHomepage> items = [
    ItemHomepage("Lihat Experience", Icons.work, Colors.blue.shade700),
    ItemHomepage("Tambah Experience", Icons.add_circle, Colors.green.shade700),
    ItemHomepage("Tambah Proyek", Icons.add_box, Colors.purple.shade700),
    ItemHomepage("Logout", Icons.logout, Colors.red.shade700),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur visual dasar halaman (AppBar, Body, SnackBar).
    return Scaffold(
      // AppBar menampilkan bar bagian atas halaman aplikasi.
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        // Ikon menu (hamburger) drawer dibuat putih agar terlihat di atas AppBar.
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Drawer berisi navigasi ke halaman lain.
      drawer: const LeftDrawer(),
      // Body bisa digulir agar isi halaman tidak meluap di layar pendek, dan
      // lebarnya dibatasi agar kartu tidak membesar berlebihan di layar lebar.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Baris horizontal untuk menampilkan 3 InfoCard secara sejajar.
                // Expanded membagi lebar baris sama rata sehingga tidak meluap.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: InfoCard(title: 'NPM', content: npm)),
                    Expanded(child: InfoCard(title: 'Name', content: nama)),
                    Expanded(child: InfoCard(title: 'Class', content: kelas)),
                  ],
                ),

                const SizedBox(height: 16.0),

                // Pesan sambutan.
                const Padding(
                  padding: EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Selamat datang di MyPortfolio Mobile!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),

                // GridView menampilkan 4 kartu tombol dalam kisi 2 x 2.
                GridView.count(
                  // Yang digulir adalah halaman, bukan kisinya.
                  primary: false,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  // shrinkWrap agar ukuran kisi menyesuaikan tinggi konten anak.
                  shrinkWrap: true,
                  children: items.map((ItemHomepage item) {
                    return ItemCard(item);
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan judul (title) dan isi (content).
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan efek bayangan kartu elevasi 2 unit.
      elevation: 2.0,
      child: Container(
        // Lebar kartu mengikuti Expanded dari Row di MyHomePage.
        width: double.infinity,
        padding: const EdgeInsets.all(12.0),
        // Menyusun teks title dan content secara vertikal.
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// Model data untuk satu tombol aksi di halaman utama.
///
/// Warna latar disimpan di model, sehingga [ItemCard] cukup membaca
/// `item.color` tanpa percabangan if-else per tombol.
class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  ItemHomepage(this.name, this.icon, this.color);
}
