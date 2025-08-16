// lib/views/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/login_viewmodel.dart'; // Impor ViewModel

/// LoginPage adalah View yang menampilkan antarmuka login.
/// Widget ini sekarang menjadi StatelessWidget yang berinteraksi dengan ViewModel.
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginViewModel>(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        body: Consumer<LoginViewModel>(
          builder: (context, viewModel, child) {
            return Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey.shade100, Colors.blueGrey.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 50),
                    Text(
                      'Selamat Datang di\nAplikasi Manajemen\nWarungKopi Ibadah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[800],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Silakan Masukkan Email & Kata Sandi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.blueGrey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _entryField('Email', viewModel.emailController, false, viewModel),
                    const SizedBox(height: 15),
                    _entryField('Kata Sandi', viewModel.passwordController, true, viewModel),
                    _rememberMeCheckbox(viewModel),
                    const SizedBox(height: 20),
                    if (viewModel.errorMessage != null)
                      Text(
                        'Terjadi Kesalahan: ${viewModel.errorMessage}',
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 20),
                    _submitButton(viewModel),
                    _loginButton(viewModel),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Widget pembangun untuk bidang input (email atau kata sandi).
  Widget _entryField(String title, TextEditingController controller, bool isPassword, LoginViewModel viewModel) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? viewModel.obscureText : false,
      keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  viewModel.obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: viewModel.togglePasswordVisibility,
              )
            : null,
      ),
    );
  }

  // Widget pembangun untuk checkbox "Ingat Saya".
  Widget _rememberMeCheckbox(LoginViewModel viewModel) {
    return CheckboxListTile(
      title: const Text('Ingat Saya'),
      value: viewModel.rememberMe,
      onChanged: viewModel.toggleRememberMe,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // Widget pembangun untuk tombol kirim (Login atau Register).
  Widget _submitButton(LoginViewModel viewModel) {
    return ElevatedButton(
      onPressed: viewModel.isLoading
          ? null
          : (viewModel.isLogin ? viewModel.signIn : viewModel.register),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: viewModel.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
              viewModel.isLogin ? 'Masuk' : 'Daftar',
              style: const TextStyle(fontSize: 18),
            ),
    );
  }

  // Widget pembangun untuk tombol beralih antara mode Login dan Register.
  Widget _loginButton(LoginViewModel viewModel) {
    return TextButton(
      onPressed: viewModel.toggleLoginMode,
      child: Text(
        viewModel.isLogin ? 'Daftar Sekarang' : 'Masuk Saja',
        style: const TextStyle(color: Colors.blueAccent),
      ),
    );
  }
}
