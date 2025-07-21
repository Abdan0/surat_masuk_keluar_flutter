import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Surat Masuk dan Keluar Fakultas',
      home: LoginPage(),
    );
  }
}
