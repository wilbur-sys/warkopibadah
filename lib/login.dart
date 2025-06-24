import 'package:flutter/material.dart'; // Paket inti Flutter untuk membangun UI
import 'package:firebase_auth/firebase_auth.dart'; // Paket untuk otentikasi Firebase
import 'package:shared_preferences/shared_preferences.dart'; // Paket untuk menyimpan data sederhana secara lokal
import 'auth.dart'; // Mengimpor kelas 'Auth' kustom   untuk operasi otentikasi

/// Widget [StatefulWidget] yang merepresentasikan halaman login aplikasi.
/// Halaman ini memungkinkan pengguna untuk masuk atau mendaftar,
/// serta memiliki fungsionalitas "ingat saya" dan visibilitas kata sandi.
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState(); // Membuat State untuk widget ini.
}

/// State terkait dengan [LoginPage].
/// Ini mengelola status input pengguna, pesan kesalahan, mode login/daftar,
/// status "ingat saya", dan visibilitas kata sandi.
class _LoginPageState extends State<LoginPage> {
  String? errorMessage = ''; // Variabel untuk menyimpan pesan kesalahan, null jika tidak ada
  bool isLogin = true; // Status: true untuk mode login, false untuk mode daftar
  bool rememberMe = false; // Status checkbox "ingat saya"
  bool _obscureText = true; // Status visibilitas teks kata sandi (true: tersembunyi, false: terlihat)

  // Controller untuk bidang input email dan kata sandi
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRememberMe(); // Muat kredensial yang tersimpan saat state diinisialisasi
  }

  /// Memuat email dan kata sandi yang tersimpan dari SharedPreferences jika 'rememberMe' aktif.
  /// Jika ditemukan, bidang email dan kata sandi akan diisi dan checkbox 'rememberMe' dicentang.
  _loadRememberMe() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final password = prefs.getString('password');
      if (email != null && password != null) {
        setState(() {
          _controllerEmail.text = email;
          _controllerPassword.text = password;
          rememberMe = true; // Set rememberMe ke true jika kredensial ditemukan
        });
      }
    } catch (e) {
      print("Error saat memuat preferensi ingat saya: $e");
      // Tidak perlu menampilkan pesan ke pengguna di sini, ini adalah operasi latar belakang
    }
  }

  /// Mengganti status visibilitas teks kata sandi.
  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // Mengubah antara true dan false
    });
  }

  /// Fungsi asinkron untuk masuk (sign in) pengguna dengan email dan kata sandi.
  /// Menangani [FirebaseAuthException] dan menyimpan kredensial jika "ingat saya" dicentang.
  Future<void> signInWithEmailAndPassword() async {
    try {
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      if (rememberMe) {
        // Simpan email dan kata sandi ke SharedPreferences jika "ingat saya" dicentang
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', _controllerEmail.text);
        await prefs.setString('password', _controllerPassword.text);
      } else {
        // Hapus kredensial jika "ingat saya" tidak dicentang (misalnya, jika sebelumnya dicentang)
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('email');
        await prefs.remove('password');
      }
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan otentikasi Firebase
      setState(() {
        errorMessage = e.message; // Perbarui pesan kesalahan
      });
    } catch (e) {
      // Tangani kesalahan umum lainnya
      setState(() {
        errorMessage = 'Terjadi kesalahan tidak terduga: $e';
      });
    }
  }

  /// Fungsi asinkron untuk membuat pengguna baru dengan email dan kata sandi.
  /// Menangani [FirebaseAuthException] jika pendaftaran gagal.
  Future<void> createUserWithEmailAndPassword() async {
    try {
      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      // Setelah berhasil mendaftar, pengguna mungkin ingin langsung masuk
      // Atau   bisa secara otomatis mengarahkan mereka ke Home Screen.
    } on FirebaseAuthException catch (e) {
      // Tangani kesalahan pendaftaran Firebase
      setState(() {
        errorMessage = e.message; // Perbarui pesan kesalahan
      });
    } catch (e) {
      // Tangani kesalahan umum lainnya
      setState(() {
        errorMessage = 'Terjadi kesalahan tidak terduga: $e';
      });
    }
  }

  /// Widget pembangun untuk judul aplikasi.
  Widget _title() {
    return const Text(
      'Otentikasi Firebase',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  /// Widget pembangun untuk bidang input (email atau kata sandi).
  ///
  /// Parameter:
  /// - [title]: Label teks untuk bidang input.
  /// - [controller]: TextEditingController yang terkait dengan bidang input.
  /// - [isPassword]: Boolean, true jika ini adalah bidang kata sandi (untuk menyembunyikan teks dan ikon mata).
  Widget _entryField(String title, TextEditingController controller, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false, // Menyembunyikan teks jika field password dan _obscureText true
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress, // Tipe keyboard
      decoration: InputDecoration(
        labelText: title, // Label input
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), // Border input
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off, // Ikon mata untuk visibilitas kata sandi
                ),
                onPressed: _togglePasswordVisibility, // Memanggil fungsi toggle visibilitas
              )
            : null, // Tidak ada ikon jika bukan bidang kata sandi
      ),
    );
  }

  /// Widget pembangun untuk menampilkan pesan kesalahan.
  /// Pesan akan ditampilkan jika `errorMessage` tidak kosong.
  Widget _errorMessage() {
    if (errorMessage == null || errorMessage!.isEmpty) {
      return const SizedBox.shrink(); // Widget kosong jika tidak ada kesalahan
    }
    return Text(
      'Terjadi Kesalahan: $errorMessage', // Pesan kesalahan
      style: const TextStyle(color: Colors.red, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  /// Widget pembangun untuk tombol kirim (Login atau Register).
  /// Teks tombol dan aksi yang dipanggil akan bervariasi berdasarkan `isLogin`.
  Widget _submitButton() {
    return ElevatedButton(
      onPressed: isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent, // Warna latar belakang tombol
        foregroundColor: Colors.white, // Warna teks tombol
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        isLogin ? 'Masuk' : 'Daftar', // Teks tombol Login atau Daftar
        style: const TextStyle(fontSize: 18),
      ),
    );
  }

  /// Widget pembangun untuk tombol beralih antara mode Login dan Register.
  Widget _loginButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          isLogin = !isLogin; // Mengganti mode login/daftar
          errorMessage = ''; // Hapus pesan kesalahan saat beralih mode
          _controllerEmail.clear(); // Bersihkan input saat beralih mode
          _controllerPassword.clear(); // Bersihkan input saat beralih mode
        });
      },
      child: Text(
        isLogin ? 'Daftar Sekarang' : 'Masuk Saja', // Teks tombol beralih mode
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }

  /// Widget pembangun untuk checkbox "Ingat Saya".
  Widget _rememberMeCheckbox() {
    return CheckboxListTile(
      title: const Text('Ingat Saya'), // Teks checkbox
      value: rememberMe,
      onChanged: (value) {
        setState(() {
          rememberMe = value!; // Perbarui status checkbox
        });
      },
      controlAffinity: ListTileControlAffinity.leading, // Letakkan checkbox di awal
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20), // Padding di sekitar konten
        decoration: BoxDecoration(
          gradient: LinearGradient( // Latar belakang gradien
            colors: [Colors.blueGrey.shade100, Colors.blueGrey.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView( // Memungkinkan konten dapat digulir jika terlalu besar
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan children secara horizontal
            mainAxisAlignment: MainAxisAlignment.center, // Pusatkan children secara vertikal
            children: <Widget>[
              const SizedBox(height: 50), // Spasi di bagian atas
              Text(
                'Selamat Datang di\nAplikasi Manajemen\nWarungKopi Ibadah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28, // Ukuran font lebih besar
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[800], // Warna teks gelap
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Silakan Masukkan Email & Kata Sandi  ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                  color: Colors.blueGrey[600],
                ),
              ),
              const SizedBox(height: 20),
              _entryField('Email', _controllerEmail), // Bidang input Email
              const SizedBox(height: 15),
              _entryField('Kata Sandi', _controllerPassword, isPassword: true), // Bidang input Kata Sandi
              _rememberMeCheckbox(), // Checkbox "Ingat Saya"
              const SizedBox(height: 20),
              _errorMessage(), // Menampilkan pesan kesalahan
              const SizedBox(height: 20),
              _submitButton(), // Tombol Login/Daftar
              _loginButton(), // Tombol beralih mode
            ],
          ),
        ),
      ),
    );
  }
}
