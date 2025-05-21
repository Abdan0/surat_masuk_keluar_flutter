import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/pages/login_page.dart';

class MyProfileCard extends StatefulWidget {
  const MyProfileCard({super.key});

  @override
  State<MyProfileCard> createState() => _MyProfileCardState();
}

class _MyProfileCardState extends State<MyProfileCard> {
  bool _isLoading = true;
  User? _userData;
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final userData = await UserService.getUserData();
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
      
      // Jika tidak ada data user, coba refresh
      if (userData == null) {
        _refreshUserData();
      } else {
        print('✅ User data loaded successfully: ${userData.name}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data profil';
        _isLoading = false;
      });
      print('❌ Error loading user data: $e');
    }
  }
  
  Future<void> _refreshUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userData = await UserService.refreshUserData();
      
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
      
      if (userData == null) {
        setState(() {
          _errorMessage = 'Tidak dapat memperbarui data pengguna';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memperbarui data profil';
        _isLoading = false;
      });
      print('Error refreshing user data: $e');
    }
  }
  
  // Fungsi untuk menangani proses logout
  Future<void> _handleLogout() async {
    // Simpan ScaffoldMessengerState dalam variabel lokal
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // tutup dialog konfirmasi
              
              // Tampilkan loading
              setState(() {
                _isLoading = true;
              });
              
              try {
                final success = await UserService.logout();
                
                if (success) {
                  // Navigasi ke halaman login dan hapus semua halaman sebelumnya
                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                    (route) => false,
                  );
                } else {
                  // Hanya update state jika widget masih mounted
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = 'Gagal logout, silakan coba lagi';
                    });
                    
                    // Gunakan scaffoldMessenger yang disimpan sebelumnya
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text('Gagal logout, silakan coba lagi'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              } catch (e) {
                // Hanya update state jika widget masih mounted
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Error: $e';
                  });
                  
                  // Gunakan scaffoldMessenger yang disimpan sebelumnya
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
  
  String _formatUserRole(String? role) {
    if (role == null) return 'Pengguna';
    
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'staff':
        return 'Staff';
      case 'dekan':
        return 'Dekan';
      case 'wakil_dekan':
        return 'Wakil Dekan';
      default:
        return role[0].toUpperCase() + role.substring(1);
    }
  }

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
                
                // Menampilkan loading indicator jika data belum tersedia
                _isLoading 
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      // Nama user
                      Text(
                        _userData?.name ?? 'Pengguna',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2D3E5F), // Warna biru tua untuk teks nama
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      // Role user
                      Text(
                        _formatUserRole(_userData?.role),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: const Color(0xFF2D3E5F).withOpacity(0.7), // Warna biru tua lebih transparan
                        ),
                      ),
                      
                      // Tampilkan error jika ada
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        TextButton.icon(
                          onPressed: _refreshUserData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          
          // Tombol-tombol aksi
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                // Tombol Logout
                ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Tombol Kembali
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppPallete.primaryColor,
                    minimumSize: const Size.fromHeight(50),
                    side: const BorderSide(color: AppPallete.primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Kembali',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
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