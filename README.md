# myportofolio_mobile

Aplikasi mobile Flutter untuk portofolio pribadi, pendamping website portofolio Django (`myportofolio`).

Nama : Muhammad Faza Aqila

NPM : 2506613142

Kelas : PBP C

## Cara Menjalankan

Prasyarat: Flutter SDK sudah terpasang dan `flutter doctor` tidak menunjukkan masalah untuk perangkat yang dipakai (Chrome atau emulator Android).

```bash
cd myportofolio_mobile
flutter pub get      # mengambil dependency dari pubspec.yaml
flutter run          # pilih perangkat: Chrome atau emulator
flutter analyze      # memeriksa kode (target: No issues found!)
```

Saat aplikasi berjalan, tekan `r` di terminal untuk *hot reload* dan `R` untuk *hot restart*.

## Progres Mingguan

| Tugas | Isi |
|---|---|
| Tutorial 08 | Membuat proyek Flutter, memisahkan `menu.dart` dari `main.dart`, menyusun `InfoCard` dan `ItemCard`. |
| Tugas 7 | Mengisi `InfoCard` dengan NPM, nama, dan kelas sendiri; menambah atribut `color` pada `ItemHomepage` sehingga setiap `ItemCard` (Lihat Experience, Tambah Experience, Logout) punya warna latar berbeda; SnackBar sesuai nama tombol; `flutter analyze` bersih. |
| Tutorial 09 | Menambah drawer (`LeftDrawer`), form Tambah Proyek dengan validasi dan dialog, navigasi `push`/`pushReplacement`, memisahkan `lib/screens/` dan `lib/widgets/`, serta beralih ke paket `material_ui`. |
| Tugas 8 | Form Tambah Experience (`experience_form.dart`) dengan 7 field sesuai model Django, validasi kosong/spasi, panjang, URL, dan urutan tanggal, *date picker*, dialog ringkasan; dibuka dari kartu (`push`) dan drawer (`pushReplacement`); halaman utama dibuat bisa digulir dan tidak *overflow*. |

### Tugas 7

1. *Widget tree* adalah susunan bertingkat seluruh widget yang membentuk tampilan aplikasi. Di Flutter, hampir semua hal adalah widget, dan setiap widget bisa membungkus widget lain sehingga terbentuk pohon dengan satu akar. Widget induk (*parent*) menentukan di mana dan bagaimana anaknya (*child*/*children*) ditampilkan, misalnya `Padding` memberi jarak, `Column` menyusun anak secara vertikal, dan `Center` menaruh anaknya di tengah. Anak menerima batas ukuran (*constraints*) dari induknya, menentukan ukurannya sendiri, lalu induk mengatur posisinya. Data dan tema juga mengalir dari atas ke bawah, sehingga widget di bawah bisa membaca informasi dari leluhurnya lewat `BuildContext`, seperti `Theme.of(context)` atau `ScaffoldMessenger.of(context)`. Di aplikasi ini pohonnya berbentuk `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → `AppBar` dan `Padding` → `Column` → `Row` berisi tiga `InfoCard` serta `GridView` berisi tiga `ItemCard`.

2. Widget yang saya gunakan:
   - `MyApp`, `MyHomePage`, `InfoCard`, `ItemCard`: widget buatan sendiri turunan `StatelessWidget`; masing-masing untuk akar aplikasi, halaman utama, kartu identitas, dan kartu tombol aksi.
   - `MaterialApp`: akar aplikasi yang menyediakan tema, judul, dan navigasi bergaya Material Design.
   - `Scaffold`: kerangka halaman yang menyediakan tempat untuk `AppBar`, `body`, dan SnackBar.
   - `AppBar`: bar judul di bagian atas halaman.
   - `Text`: menampilkan teks, seperti judul, data profil, dan nama tombol.
   - `Padding`: memberi jarak di sekeliling widget anaknya.
   - `Column` dan `Row`: menyusun anak secara vertikal dan horizontal (tiga `InfoCard` disusun dengan `Row`).
   - `Center`: menaruh anaknya di tengah ruang yang tersedia.
   - `SizedBox`: memberi jarak kosong dengan ukuran tertentu.
   - `Card`: kartu dengan bayangan (*elevation*) sebagai wadah `InfoCard`.
   - `Container`: mengatur lebar dan *padding* isi kartu.
   - `GridView.count`: menyusun tombol aksi dalam kisi 3 kolom.
   - `Material`: memberi warna latar dan sudut melengkung pada kartu tombol, sekaligus menjadi permukaan untuk efek riak.
   - `InkWell`: menangkap ketukan (`onTap`) dan menampilkan efek riak (*ripple*).
   - `Icon`: menampilkan ikon pada setiap tombol.
   - `SnackBar`: pesan singkat di bawah layar setelah tombol ditekan, ditampilkan lewat `ScaffoldMessenger`.
   - `MediaQuery`: dibaca lewat `MediaQuery.of(context)` untuk menyesuaikan lebar `InfoCard` dengan lebar layar.

3. `MaterialApp` membungkus seluruh aplikasi dan menyediakan fondasi Material Design: tema (`ThemeData` dan `ColorScheme`), judul aplikasi, halaman awal (`home`), sistem navigasi antarhalaman (`Navigator`), serta pengaturan bahasa dan arah teks. Widget ini dipakai sebagai akar karena widget Material di bawahnya bergantung pada hal-hal yang ia sediakan. Misalnya `Scaffold`, `AppBar`, dan `Card` mengambil warna dari tema, sedangkan `ScaffoldMessenger` yang dipakai SnackBar juga disediakan oleh `MaterialApp`. Dengan menaruhnya di akar, satu pengaturan tema seperti `ColorScheme.fromSeed(seedColor: Colors.indigo)` berlaku untuk seluruh aplikasi tanpa perlu diatur ulang di setiap widget.

4. `StatelessWidget` tidak menyimpan data yang berubah selama aplikasi berjalan; tampilannya hanya ditentukan oleh nilai yang diberikan saat widget dibuat, sehingga isinya hanya berubah jika induknya membuat ulang widget itu dengan nilai baru. `StatefulWidget` dipasangkan dengan objek `State` yang bisa menyimpan data yang berubah, lalu memanggil `setState()` agar Flutter menggambar ulang tampilan. Pilih `StatelessWidget` untuk tampilan yang isinya tetap, seperti halaman menu ini: NPM, nama, kelas, dan daftar tombol tidak pernah berubah, dan SnackBar ditampilkan oleh `ScaffoldMessenger`, bukan disimpan sebagai *state* halaman. Pilih `StatefulWidget` jika tampilan harus berubah karena interaksi atau data, misalnya penghitung pada aplikasi bawaan Flutter, isian form, *checkbox*, atau data yang dimuat dari API.

5. `BuildContext` adalah penanda posisi sebuah widget di dalam widget tree. Setiap metode `build(BuildContext context)` menerima *context* milik widget tersebut, dan *context* inilah yang dipakai untuk mencari widget atau data milik leluhurnya. Di aplikasi ini, `Theme.of(context).colorScheme.primary` mengambil warna tema dari `MaterialApp` untuk `AppBar`, `MediaQuery.of(context).size.width` membaca lebar layar untuk mengatur lebar `InfoCard`, dan `ScaffoldMessenger.of(context)` di dalam `ItemCard` mencari `ScaffoldMessenger` terdekat untuk menampilkan SnackBar. Karena pencariannya selalu ke atas mulai dari posisi *context*, memakai *context* yang tepat itu penting: widget yang posisinya di atas `MaterialApp` tidak akan menemukan tema atau `ScaffoldMessenger`-nya.

6. *Hot reload* menyuntikkan kode Dart yang baru ke aplikasi yang sedang berjalan lalu menjalankan ulang metode `build`, sehingga perubahan tampilan terlihat dalam hitungan detik **tanpa kehilangan *state***. Misalnya, setelah mengganti data `InfoCard` atau warna tombol, cukup tekan `r` di terminal. *Hot restart* (tombol `R`) memuat ulang kode dan menjalankan aplikasi dari awal mulai `main()`, sehingga seluruh *state* kembali ke nilai awal, tetapi tetap lebih cepat daripada menghentikan aplikasi. *Hot reload* tidak cukup ketika perubahan tidak terjadi di dalam `build`, misalnya mengubah fungsi `main()`, nilai awal variabel global atau `static`, kode di `initState()`, atau mengubah `StatelessWidget` menjadi `StatefulWidget` (dan sebaliknya); untuk kasus ini perlu *hot restart*. *Full restart* (hentikan lalu jalankan ulang `flutter run`) diperlukan jika perubahannya di luar kode Dart, seperti menambah *package* di `pubspec.yaml` atau mengubah kode *native* Android/iOS.

#### Disclosure AI

**Alat:** Claude (aplikasi Claude, model Opus) dengan akses baca ke folder proyek di laptop**.

**Link Percakapan:** https://claude.ai/share/a0f17bf1-fff7-410a-8147-de5b377d8c90

**Cara pemakaian:** Saya meminta AI menjelaskan isi PDF tugas **tanpa memberikan jawaban**, lalu memandu urutan pengerjaan. Setiap kali satu langkah selesai, AI membaca `lib/menu.dart`, `lib/main.dart`, dan riwayat commit untuk mengecek hasilnya, lalu hanya menunjuk bagian yang belum sesuai tanpa menuliskan kode perbaikannya. Dalam sesi ini AI tidak menuliskan kode Dart maupun jawaban pertanyaan reflektif nomor 1–6. AI juga tidak menjalankan perintah Git; commit dan push saya lakukan sendiri.

#### Log Prompting AI: Tugas 7

| No | Prompt saya | Hasil |
|---|---|---|
| 1 | PDF Tugas 7 + "jelasin tugas ini ngapain, jangan kasih tau jawabannya" | Ringkasan checklist (struktur proyek, `InfoCard`, `ItemCard` berwarna, SnackBar, `flutter analyze`, Git, README) tanpa kode. |
| 2 | "pandu saya berdasarkan urutan buat ngerjain tugas 7 ini" | Urutan 9 langkah beserta petunjuk, cara mengecek hasil, dan contoh pesan commit per langkah. |
| 3 | "coba cek langkah 2 saya udah bener?" | `InfoCard` sudah benar; diingatkan bahwa perubahan belum di-commit. |
| 4 | "coba cek langkah 3" | Atribut `color` di `ItemHomepage` sudah benar; diberi tahu bahwa daftar `items` akan error sampai warna diisi (langkah 4). |
| 5 | "coba cek langkah 4 dan 5" | Warna tiap item dan pemakaian `item.color` di `ItemCard` sudah benar. |
| 6 | "coba cek langkah 6" | Format pesan SnackBar sudah sesuai. |
| 7 | Tangkapan layar `flutter analyze` | Hasil "No issues found!" dikonfirmasi; disarankan menunda `flutter upgrade` sampai tugas dikumpulkan. |
| 8 | "saya udah kerjain yang 6 pertanyaan apakah benar?" | Keenam jawaban dinilai benar; AI menunjukkan bahwa README belum punya AI disclosure dan cara menjalankan proyek. |


**Strategi prompting:** Saya meminta penjelasan dan pengecekan, bukan jawaban jadi, supaya kode dan jawaban reflektif tetap saya kerjakan sendiri. Pengecekan diminta per langkah agar kesalahan ketahuan lebih awal dan setiap langkah bisa di-commit terpisah.

**Bagian yang dibantu AI:** penjelasan tugas, urutan pengerjaan, pengecekan hasil langkah 2–7 dan jawaban nomor 1–6, serta penulisan bagian Cara Menjalankan, Progres Mingguan.

**Keterbatasan AI dan yang saya periksa sendiri:**

1. **AI tidak bisa menjalankan aplikasi Flutter.** AI hanya membaca kode, sehingga tidak bisa memastikan tampilan, warna tombol, dan SnackBar benar-benar muncul. Hal itu harus dicek dengan menjalankan aplikasi sendiri.
2. **`flutter analyze` saya jalankan sendiri** di laptop, dengan hasil *No issues found!*.
3. **Data pribadi diperiksa sendiri.** AI tidak bisa memastikan NPM dan kelas yang tertulis di `InfoCard` sudah benar, jadi saya mencocokkannya sendiri.

### Tugas 8

1. `Navigator.push()` menumpuk halaman baru di atas halaman yang sedang tampil, sehingga halaman lama tetap ada di bawahnya dan bisa dikembalikan dengan tombol back. `Navigator.pushReplacement()` mengganti halaman yang sedang tampil dengan halaman baru, sehingga halaman lama dibuang dari tumpukan dan tidak bisa dikembalikan dengan back. `Navigator.pop()` mengeluarkan halaman paling atas dari tumpukan dan kembali ke halaman di bawahnya; tombol back bawaan perangkat atau browser melakukan hal yang sama, dan di form saya `Navigator.pop(dialogContext)` dipakai untuk menutup dialog ringkasan. Kartu **Tambah Experience** di `widgets/project_card.dart` membuka form dengan `Navigator.push()`, jadi setelah form terbuka pengguna bisa kembali ke halaman utama dengan tombol back. Opsi di drawer (`widgets/left_drawer.dart`) memakai `Navigator.pushReplacement()`: opsi **Home** mengganti halaman yang sedang tampil (misalnya form Experience) dengan `MyHomePage` baru, sehingga pengguna kembali ke halaman utama tanpa form tertinggal di tumpukan. Karena itu, form yang dibuka dari drawer tidak bisa ditinggalkan dengan back seperti form yang dibuka dari kartu, dan opsi Home inilah jalan kembalinya.

2. Setiap halaman (`MyHomePage`, `ProjectFormPage`, dan `ExperienceFormPage`) memakai `Scaffold` sebagai kerangka yang sama: `AppBar` di atas, `body` di tengah, dan `drawer` di kiri. Ketiganya memasang widget drawer yang sama, `const LeftDrawer()`, sehingga isi dan urutan menu navigasi selalu sama di semua halaman, dan perubahan menu cukup dilakukan di satu berkas. `AppBar` juga otomatis menampilkan ikon ☰ untuk membuka drawer. Contoh warna tema yang dipakai di lebih dari satu halaman: `Theme.of(context).colorScheme.primary`, yaitu warna primer dari `ColorScheme.fromSeed(seedColor: Colors.indigo)` di `main.dart`, dipakai sebagai warna latar `AppBar` di halaman utama (`menu.dart`) dan di form Experience (`experience_form.dart`), dan juga untuk tombol **Simpan** di form Experience. Karena diambil dari tema, mengganti `seedColor` akan ikut mengubah warna AppBar kedua halaman itu. Namun AppBar dan tombol Save di form proyek (`project_form.dart`) serta header drawer (`left_drawer.dart`) masih memakai `Colors.indigo` yang ditulis langsung dari Tutorial 09, sehingga warnanya tidak ikut berubah. Agar seluruh aplikasi benar-benar konsisten, bagian-bagian tersebut juga perlu diubah agar mengambil warna dari tema.

3. Form Experience disusun sebagai satu kolom (`Column`) dengan satu field per baris dan lebar penuh, urutannya sama seperti `ExperienceForm` di Django, lalu tombol **Simpan** di bagian paling bawah. Susunan satu kolom ini paling mudah dibaca dan diisi di layar ponsel yang sempit. `Padding` (`EdgeInsets.all(8.0)` di setiap field dan di tepi `SingleChildScrollView`) mengatur jarak antarfield agar label, border, dan pesan error tidak saling menempel, sedangkan `Align` menaruh tombol Simpan di tengah bawah. Seluruh `Column` dibungkus `SingleChildScrollView`: ketika tinggi layar terbatas atau papan ketik muncul dan menutupi setengah layar, isi form bisa digulir sehingga semua field dan tombol Simpan tetap bisa dijangkau. Tanpa widget penggulir, isi yang melebihi tinggi layar akan terpotong dan Flutter menampilkan peringatan *overflow*. Prinsip yang sama juga saya terapkan pada halaman utama: setelah diuji di layar selebar 360 px dan 1280 px ternyata terjadi *overflow*, sehingga halaman utama dibungkus `SingleChildScrollView`, lebarnya dibatasi `ConstrainedBox`, dan kartu identitas dibagi rata dengan `Expanded`.

4. `GlobalKey<FormState>` (`_formKey`) adalah kunci yang dipasang di widget `Form` sehingga *state* form bisa diakses dari luar widget tersebut, misalnya dari fungsi tombol Simpan. Setiap field punya `validator`, yaitu fungsi yang menerima isian field dan mengembalikan pesan error (`String`) jika isian tidak valid, atau `null` jika valid. Saat tombol **Simpan** ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus, menampilkan pesan error di bawah setiap field yang gagal, lalu mengembalikan `true` hanya jika semuanya valid; dialog ringkasan baru dibuka jika hasilnya `true`. Contoh nilai yang ditolak: URL foto `abc` ditolak dengan pesan "Masukkan URL yang valid, diawali http:// atau https://". Field itu sudah memakai `keyboardType: TextInputType.url`, tetapi jenis papan ketik hanya mengubah tata letak tombol (misalnya menampilkan `/` dan `.com`) dan tidak mencegah pengguna mengetik teks apa pun atau menempelkan teks. Begitu juga nama kegiatan yang hanya berisi spasi tetap bisa diketik di `TextFormField`, dan *date picker* menjamin format tanggal tetapi tidak menjamin tanggal selesai berada setelah tanggal mulai. Aturan seperti isian wajib, batas panjang dari `max_length` model, format URL, dan urutan tanggal hanya bisa dijamin oleh validator.

#### Disclosure AI: Tugas 8

**Alat:** Claude

**Link Percakapan:** https://claude.ai/share/a0f17bf1-fff7-410a-8147-de5b377d8c90

**Cara pemakaian:** Saya meminta AI menjelaskan isi PDF tugas **tanpa memberikan jawaban**, lalu memandu urutan pengerjaan. Setiap kali satu langkah selesai, AI membaca berkas di `lib/` dan riwayat commit, mencocokkan aturan validasi dengan model `Experience` dan `ExperienceForm` di proyek Django `myportofolio`, lalu hanya menunjuk bagian yang belum sesuai tanpa menuliskan kode perbaikannya. Dalam sesi ini AI tidak menuliskan kode Dart maupun jawaban pertanyaan reflektif nomor 1–4. AI juga tidak menjalankan perintah Git; commit dan push saya lakukan sendiri.

#### Log Prompting AI: Tugas 8

| No | Prompt saya | Hasil |
|---|---|---|
| 1 | PDF Tugas 8 + "jelasin tugas ini ngapain, jangan kasih tau jawabannya" | Ringkasan checklist (form baru di `lib/screens/`, validasi, navigasi kartu dan drawer, dialog ringkasan, README) tanpa kode; disarankan memilih bagian Experience karena sesuai dengan bagian Django saya. |
| 2 | "pandu saya berdasarkan urutan buat ngerjain tugas ini" | Urutan 10 langkah (langkah 0–9) beserta petunjuk, cara mengecek hasil, dan contoh pesan commit per langkah, disesuaikan dengan struktur Tutorial 09 saya. |
| 3 | "saya udah ngerjain langkah 0 dan 1 coba cek" | Dikonfirmasi bahwa commit Tutorial 09 sudah ter-push pada 16 November, sebelum tenggat prasyarat. |
| 4 | "langkah 2 udah saya kerjain coba cek" + tangkapan layar | Kerangka form sudah benar; diingatkan bahwa `home: ExperienceFormPage()` di `main.dart` hanya jalan pintas sementara yang harus dikembalikan sebelum commit, karena membuat import `menu.dart` tidak terpakai. |
| 5 | "coba cek langkah 3 saya" | Validasi teks dicocokkan dengan `max_length` model Django dan dinyatakan sesuai; diberi catatan bahwa nilai di controller belum di-trim saat nanti ditampilkan. |
| 6 | "saya udah kerjain nomor 4 coba cek" | Kategori dan *date picker* sudah benar; diberi petunjuk untuk mengecek apakah `_category`, `_startDate`, dan `_endDate` ikut kembali ke nilai awal ketika form di-reset. |
| 7 | "coba cek langkah 5 saya apakah udah benar?" | Tombol Simpan, dialog, dan reset sudah benar; diberi tabel kasus uji validasi dan dua catatan opsional (judul dialog dan dialog yang bisa ditutup dengan klik di luar). |
| 8 | "saya udah kerjain langkah 6 coba cek" | Navigasi kartu dengan `push` sudah benar; dijelaskan bahwa AppBar menampilkan ikon ☰ (bukan panah back) karena halaman punya drawer, sehingga uji kembali memakai tombol back browser. |
| 9 | "saya udah kerjain langkah 7 coba cek" | Opsi Add Experience di drawer sudah benar; disarankan percobaan membandingkan `push` dan `pushReplacement` sebagai bahan jawaban nomor 1. |
| 10 | "saya udah ngerjain langkah sisanya coba cek" | Kode dinyatakan lengkap; AI menunjukkan bahwa commit Tugas 8 belum di-push, README belum di-commit, AI disclosure Tugas 8 belum ada, dan klaim di jawaban nomor 2 bahwa `seedColor` mengubah warna "semua halaman" tidak sesuai kode. |
| 11 | "coba cek yang jawaban itu" | Keempat jawaban dicocokkan dengan kode dan dinyatakan akurat setelah jawaban nomor 2 saya perbaiki. |

**Strategi prompting:** Saya meminta penjelasan dan pengecekan per langkah, bukan kode jadi, supaya form, validasi, navigasi, dan jawaban reflektif tetap saya kerjakan sendiri. Pengecekan per langkah membuat kesalahan ketahuan lebih awal dan setiap langkah bisa di-commit terpisah.

**Bagian yang dibantu AI:** penjelasan tugas, urutan pengerjaan, pengecekan kode di setiap langkah, pengecekan akurasi jawaban nomor 1–4.

**Keterbatasan AI dan yang saya periksa atau perbaiki sendiri:**

1. **AI tidak bisa menjalankan aplikasi Flutter.** AI hanya membaca kode, sehingga tidak bisa memastikan form, dialog, dan navigasi benar-benar berjalan. Semua kasus uji (field kosong, isian spasi, URL tidak valid, tanggal terbalik, dialog, kartu, drawer, dan tombol back) saya jalankan sendiri di Chrome.
2. **Masalah *overflow* di halaman utama saya temukan sendiri** saat menguji di layar selebar 360 px dan 1280 px, lalu saya perbaiki dengan `SingleChildScrollView`, `ConstrainedBox`, dan `Expanded`.
3. **Reset form:** dari petunjuk AI bahwa `reset()` tidak mengembalikan variabel *state*, saya menambahkan `_resetForm()` yang juga mengembalikan kategori dan tanggal ke nilai awal.
4. **Jawaban nomor 2 saya koreksi** setelah AI menunjukkan bahwa `project_form.dart` dan header drawer masih memakai `Colors.indigo` langsung, bukan warna tema.
5. **`flutter analyze` saya jalankan sendiri** di laptop dengan hasil *No issues found!*.
