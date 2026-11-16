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
