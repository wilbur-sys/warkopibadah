// lib/viewmodels/login_viewmodel.dart
import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

/// LoginViewModel mengelola state dan logika bisnis untuk LoginPage.
/// Ia berkomunikasi dengan AuthRepository untuk melakukan otentikasi.
class LoginViewModel with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLogin = true;
  bool _rememberMe = false;
  bool _obscureText = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLogin => _isLogin;
  bool get rememberMe => _rememberMe;
  bool get obscureText => _obscureText;

  LoginViewModel() {
    // Muat kredensial yang tersimpan saat ViewModel diinisialisasi.
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final credentials = await _authRepository.getRememberedCredentials();
    emailController.text = credentials['email'] ?? '';
    passwordController.text = credentials['password'] ?? '';
    if (emailController.text.isNotEmpty) {
      _rememberMe = true;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscureText = !_obscureText;
    notifyListeners();
  }

  void toggleLoginMode() {
    _isLogin = !_isLogin;
    _errorMessage = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  Future<void> signIn() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
        rememberMe: _rememberMe,
      );
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      _isLogin = true; // Kembali ke mode login setelah pendaftaran berhasil
      _errorMessage = 'Pendaftaran berhasil! Silakan masuk.';
    } on Exception catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
