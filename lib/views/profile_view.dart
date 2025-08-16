// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart'; // Impor ViewModel yang baru

/// ProfileScreen adalah View yang menampilkan antarmuka profil.
/// Ia sekarang adalah StatelessWidget dan berinteraksi dengan ViewModel.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan ChangeNotifierProvider untuk menyediakan ProfileViewModel
    // ke widget di bawahnya dalam hierarki widget.
    return ChangeNotifierProvider<ProfileViewModel>(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Pengguna'),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        body: Consumer<ProfileViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 20),
                  // Menggunakan viewModel untuk mengakses data pengguna
                  _userId(viewModel),
                  const SizedBox(height: 30),
                  // Memanggil metode signOut dari viewModel
                  _signOutButton(viewModel),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Widget untuk menampilkan email pengguna.
  Widget _userId(ProfileViewModel viewModel) {
    return Text(
      viewModel.currentUser?.email ?? 'Email Pengguna',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  /// Widget untuk tombol keluar.
  Widget _signOutButton(ProfileViewModel viewModel) {
    return ElevatedButton(
      onPressed: () async {
        await viewModel.signOut();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'Keluar',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
