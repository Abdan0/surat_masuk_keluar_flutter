import 'package:flutter/material.dart';

// Hindari penggunaan duplikat /api/
const baseURL = 'http://192.168.1.10:8000';
const apiURL = '$baseURL/api';

const String loginURL = apiURL + '/login';
const String registerURL = apiURL + '/register';
const String logoutURL = apiURL + '/logout';
const String profileURL = apiURL + '/user-profile';
const String suratURL = apiURL + '/surat';
const String disposisiURL = apiURL + '/disposisi';
const String agendaURL = apiURL + '/agenda';
const String storageURL = '$baseURL/storage';
// Debug endpoint
const String debugRegisterURL = '$apiURL/debug-register';

// Error messages
const String serverError = 'Terjadi kesalahan pada server';
const String unauthorized = 'Sesi telah berakhir. Silakan login kembali';
const String somethingWentWrong = 'Terjadi kesalahan. Silakan coba lagi';

// Success messages
const String loginSuccess = 'Login berhasil';
const String registerSuccess = 'Registrasi berhasil';
const String logoutSuccess = 'Logout berhasil';

// Validation messages
const String emailRequired = 'NIDN tidak boleh kosong';
const String passwordRequired = 'Password tidak boleh kosong';
const String nameRequired = 'Nama tidak boleh kosong';
const String invalidEmail = 'Format email tidak valid';
const String passwordLength = 'Password minimal 6 karakter';
const String passwordNotMatch = 'Password tidak cocok';

// Payment Status
const String paymentPending = 'pending';
const String paymentSuccess = 'success';
const String paymentFailed = 'failed';

// Booking Status
const String bookingPending = 'pending';
const String bookingActive = 'active';
const String bookingCompleted = 'completed';
const String bookingCancelled = 'cancelled';

// input decoration
InputDecoration inputDecoration(String label) {
  return InputDecoration(
    labelText: label,
    border: OutlineInputBorder(),
  );
}

// Pastikan baseURL terdefinisi dengan benar

// Tambahkan helper method untuk memastikan format URL yang benar
String sanitizeUrl(String url) {
  // Menghilangkan duplikasi path /api/api
  url = url.replaceAll('/api/api/', '/api/');

  // Pastikan URL diakhiri dengan "/"
  if (!url.endsWith('/')) {
    url = '$url/';
  }

  return url;
}


