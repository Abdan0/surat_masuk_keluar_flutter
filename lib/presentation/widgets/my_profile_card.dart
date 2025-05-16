import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';

class MyProfileCard extends StatelessWidget {
  const MyProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas dengan background biru
          Container(
            height: 150,
            color: AppPallete.secondaryColor, // Warna biru muda seperti pada gambar
          ),
          // Stack untuk menumpuk gambar profil di atas kedua background
          Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Container putih sebagai background bawah
              Container(
                color: Colors.white,
                height: 100,
                width: double.infinity,
              ),
              // Foto profil yang menumpuk di kedua background
              Positioned(
                top: -75, // Posisi foto profil agar berada di tengah kedua background
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const CircleAvatar(
                        radius: 75,
                        backgroundImage: AssetImage('lib/assets/abdan.jpg'),
                      ),
                    ),
          
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Informasi profil
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 60), // Spasi untuk mengakomodasi foto profil
                const Text(
                  'Muhamad Abdan Syakur',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E5F), // Warna biru tua untuk teks nama
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 18,
                    color: const Color(0xFF2D3E5F).withOpacity(0.7), // Warna biru tua lebih transparan
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}