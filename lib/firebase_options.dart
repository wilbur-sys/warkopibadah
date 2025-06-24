// File ini dibuat secara otomatis oleh FlutterFire CLI.
// ignore_for_file: type=lint // Mengabaikan peringatan linting tertentu yang mungkin muncul pada file yang dibuat secara otomatis.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions; // Mengimpor kelas FirebaseOptions dari paket firebase_core.
import 'package:flutter/foundation.dart' // Mengimpor properti platform dari paket flutter/foundation.
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Opsi [FirebaseOptions] default untuk digunakan dengan aplikasi Firebase  .
///
/// Contoh Penggunaan:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform, // Menginisialisasi Firebase dengan opsi untuk platform saat ini.
/// );
/// ```
class DefaultFirebaseOptions {
  /// Getter statis yang mengembalikan [FirebaseOptions] yang sesuai
  /// untuk platform tempat aplikasi saat ini berjalan.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Jika aplikasi berjalan di web, kembalikan konfigurasi web.
      return web;
    }
    // Menggunakan switch-case untuk memilih konfigurasi Firebase berdasarkan platform target.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Untuk platform Android, kembalikan konfigurasi Android.
        return android;
      case TargetPlatform.iOS:
        // Melemparkan UnsupportedError jika konfigurasi iOS belum diatur.
        // Pengguna perlu menjalankan FlutterFire CLI lagi untuk mengonfigurasi ini.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk iOS - '
          '  dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.macOS:
        // Melemparkan UnsupportedError jika konfigurasi macOS belum diatur.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk macOS - '
          '  dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      case TargetPlatform.windows:
        // Untuk platform Windows, kembalikan konfigurasi Windows.
        return windows;
      case TargetPlatform.linux:
        // Melemparkan UnsupportedError jika konfigurasi Linux belum diatur.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk Linux - '
          '  dapat mengonfigurasi ulang ini dengan menjalankan FlutterFire CLI lagi.',
        );
      default:
        // Melemparkan UnsupportedError untuk platform lain yang tidak didukung.
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak didukung untuk platform ini.',
        );
    }
  }

  /// Konfigurasi [FirebaseOptions] khusus untuk platform web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDPLF1Clnv5JJUpcmY-naXmn6eO0eaLpg0', // Kunci API web  
    appId: '1:835510226203:web:901e2d5e387bdf637a17be', // ID Aplikasi web  
    messagingSenderId: '835510226203', // ID Pengirim Pesan Cloud
    projectId: 'warkopibadah-f91c9', // ID Proyek Firebase  
    authDomain: 'warkopibadah-f91c9.firebaseapp.com', // Domain otentikasi Firebase
    storageBucket: 'warkopibadah-f91c9.appspot.com', // Bucket penyimpanan Firebase
    measurementId: 'G-7FWRV5V0VC', // ID Pengukuran Google Analytics (opsional)
  );

  /// Konfigurasi [FirebaseOptions] khusus untuk platform Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyADNNacf03vLFkgPiKaMbbajI9RLG2dwgM', // Kunci API Android  
    appId: '1:835510226203:android:eb3aec5b618652b17a17be', // ID Aplikasi Android  
    messagingSenderId: '835510226203', // ID Pengirim Pesan Cloud
    projectId: 'warkopibadah-f91c9', // ID Proyek Firebase  
    storageBucket: 'warkopibadah-f91c9.appspot.com', // Bucket penyimpanan Firebase
  );

  /// Konfigurasi [FirebaseOptions] khusus untuk platform Windows.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDPLF1Clnv5JJUpcmY-naXmn6eO0eaLpg0', // Kunci API Windows  
    appId: '1:835510226203:web:29c5d985a5f335057a17be', // ID Aplikasi Windows   (seringkali sama dengan web)
    messagingSenderId: '835510226203', // ID Pengirim Pesan Cloud
    projectId: 'warkopibadah-f91c9', // ID Proyek Firebase  
    authDomain: 'warkopibadah-f91c9.firebaseapp.com', // Domain otentikasi Firebase
    storageBucket: 'warkopibadah-f91c9.appspot.com', // Bucket penyimpanan Firebase
    measurementId: 'G-S8PL1L13FM', // ID Pengukuran Google Analytics (opsional)
  );
}
