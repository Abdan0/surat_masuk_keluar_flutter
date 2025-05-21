import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'dart:math' as Math;
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/models/notifikasi.dart';
import 'package:surat_masuk_keluar_flutter/data/services/disposisi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/notifikasi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/pages/login_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_disposisi_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:http/http.dart' as http;

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  bool _isLoading = true;
  List<Disposisi> _disposisiList = [];
  List<Notifikasi> _notifikasiList = [];
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _forceRefreshUserData();
  }

// Method untuk refresh data user dan notifikasi
Future<void> _forceRefreshUserData() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // Refresh user data dahulu
    final userData = await UserService.refreshUserData();
    print('👤 User data refreshed: ${userData?.name ?? "null"}');
    
    // Lalu load notifikasi dan disposisi
    await Future.wait([
      _loadNotifikasi(), 
      _loadDisposisiNotifications()
    ]);
    
  } catch (e) {
    print('❌ Error refreshing data: $e');
    setState(() {
      _error = 'Gagal memperbarui data: $e';
      _isLoading = false;
    });
  }
}

Future<void> _refreshTokenAndCheckAuth() async {
  try {
    // Coba refresh token terlebih dahulu
    final refreshed = await UserService.refreshToken();
    print('Proactive token refresh attempt: ${refreshed ? "Successful" : "Failed/Not needed"}');
  } catch (e) {
    print('Error during proactive token refresh: $e');
  } finally {
    // Lanjut ke pengecekan auth reguler
    _checkUserAuthenticated();
  }
}

Future<void> _checkUserAuthenticated() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final token = await UserService.getToken();
    print('Token check in notifikasi_page: ${token.isEmpty ? "Empty" : "Token exists"}');
    
    // Coba dapatkan user data untuk verifikasi tambahan
    final userData = await UserService.getUserData();
    print('User data: ${userData != null ? "Found (${userData.name})" : "Not found"}');
    
    if (token.isEmpty) {
      // Token tidak ada, tampilkan error dan opsi untuk login
      setState(() {
        _isLoading = false;
        _error = 'Anda belum login. Silakan login terlebih dahulu.';
      });
    } else if (userData == null) {
      // Token ada tapi tidak bisa mendapatkan user data
      setState(() {
        _isLoading = false;
        _error = 'Sesi Anda mungkin telah berakhir. Silakan login kembali.';
      });
      
      // Coba refresh token
      final refreshed = await UserService.refreshToken();
      if (refreshed) {
        // Token berhasil di-refresh, coba load data
        _checkAuthAndLoadData();
      }
    } else {
      // Token dan user data valid, lanjutkan loading
      _checkAuthAndLoadData();
    }
  } catch (e) {
    print('❌ Error in _checkUserAuthenticated: $e');
    setState(() {
      _isLoading = false;
      _error = 'Terjadi kesalahan saat memeriksa autentikasi: $e';
    });
  }
}

// Tambahkan method untuk cek koneksi internet
Future<bool> _checkInternetConnection() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

// Fungsi untuk memeriksa autentikasi dan memuat data
Future<void> _checkAuthAndLoadData() async {
  try {
    // Cek koneksi internet
    final hasInternet = await _checkInternetConnection();
    if (!hasInternet) {
      setState(() {
        _isLoading = false;
        _error = 'Tidak dapat terhubung ke internet. Silakan periksa koneksi Anda.';
      });
      return;
    }
    
    // Cek token terlebih dahulu
    final token = await UserService.getToken();
    
    if (token.isEmpty) {
      // Token tidak ada, tampilkan error dan opsi untuk login
      setState(() {
        _isLoading = false;
        _error = 'Anda belum login. Silakan login terlebih dahulu.';
      });
      return;
    }
    
    // Coba muat data
    await Future.wait([
      _loadNotifikasi(),
      _loadDisposisiNotifications(),
    ]);
  } catch (e) {
    print('❌ Error in _checkAuthAndLoadData: $e');
    // Error fatal, tampilkan pesan error
    setState(() {
      _error = 'Terjadi kesalahan saat memuat data: $e';
      _isLoading = false;
    });
  }
}

// Navigasi ke halaman login
void _navigateToLogin() {
  if (!mounted) return;
  
  // Tampilkan snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Session Anda telah berakhir. Silakan login kembali.'),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    ),
  );
  
  // Navigasi ke login
  Future.delayed(const Duration(seconds: 2), () {
    if (!mounted) return;
    // Navigator.pushReplacementNamed(context, '/login');
    
    // Atau gunakan cara di bawah ini jika tidak menggunakan named routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  });
}

// Perbaikan _loadDisposisiNotifications
Future<void> _loadDisposisiNotifications() async {
  if (_isLoading) return;
  
  setState(() {
    _isLoading = true;
    _error = null;
  });
  
  try {
    // Ambil ID user yang login
    final userId = await UserService.getUserId();
    
    if (userId == null || userId == 0) {
      print('⚠️ User ID tidak valid: $userId');
      
      // Coba refresh user data
      final userData = await UserService.refreshUserData();
      final refreshedUserId = userData?.id ?? 0;
      
      if (refreshedUserId == 0) {
        throw Exception('Tidak dapat mendapatkan User ID yang valid');
      }
      
      // Gunakan ID yang sudah di-refresh
      final disposisiList = await DisposisiService.getDisposisiByKepadaUserId(refreshedUserId);
      
      setState(() {
        _disposisiList = disposisiList;
        _isLoading = false;
      });
    } else {
      // User ID valid, lanjutkan seperti biasa
      final disposisiList = await DisposisiService.getDisposisiByKepadaUserId(userId);
      
      setState(() {
        _disposisiList = disposisiList;
        _isLoading = false;
      });
    }
  } catch (e) {
    print('❌ Error loading disposisi: $e');
    
    // Jika error berkaitan dengan autentikasi, coba refresh token
    if (e.toString().contains('Unauthorized') || e.toString().contains('expired')) {
      // Coba refresh token
      final refreshSuccess = await UserService.refreshToken();
      
      if (refreshSuccess) {
        // Token berhasil direfresh, coba load ulang
        await _loadDisposisiNotifications();
      } else {
        // Refresh gagal, navigasi ke login
        _navigateToLogin();
      }
    } else {
      // Error lain, tampilkan pesan
      setState(() {
        _error = 'Gagal memuat notifikasi disposisi: $e';
        _isLoading = false;
      });
    }
  }
}

// Modifikasi metode _loadNotifikasi untuk menambahkan refresh dan debugging
Future<void> _loadNotifikasi() async {
  try {
    print('🔄 Mulai memuat notifikasi...');
    
    // Refresh token terlebih dahulu
    await UserService.refreshToken();
    
    // Ambil notifikasi dengan timeout
    final notifikasiList = await NotifikasiService.getNotifikasiUser().timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('⚠️ Timeout mengambil notifikasi');
        return [];
      },
    );
    
    if (!mounted) return;
    
    setState(() {
      _notifikasiList = notifikasiList;
      _isLoading = false;
    });
    
    print('✅ Berhasil memuat ${notifikasiList.length} notifikasi');
  } catch (e) {
    print('❌ Error loading notifikasi: $e');
    if (!mounted) return;
    
    setState(() {
      _notifikasiList = [];
      _error = 'Error loading notifications: $e';
      _isLoading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefreshUserData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _loadDisposisiNotifications(),
            _loadNotifikasi(),
          ]);
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content langsung, tanpa MyAppBar2 dan judul tambahan
              // yang mungkin menyebabkan overflow
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      
      // Tambahkan tombol debug di bagian bawah (visibel hanya dalam debug mode)
      bottomNavigationBar: kDebugMode ? Container(
        color: Colors.grey[200],
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton(
            //   onPressed: _debugTokenInfo,
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.indigo,
            //   ),
            //   child: const Text('Debug: Check Token'),
            // ),
            // const SizedBox(width: 12),
            // ElevatedButton(
            //   onPressed: () async {
            //     await UserService.refreshToken();
            //     _debugTokenInfo();
            //   },
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.teal,
            //   ),
            //   child: const Text('Debug: Refresh Token'),
            // ),
          ],
        ),
      ) : null,
      
      // Tambahkan button untuk debug notifikasi jika dalam mode debug
      // floatingActionButton: kDebugMode ? FloatingActionButton(
      //   onPressed: _debugNotifications,
      //   tooltip: 'Debug Notifications',
      //   child: const Icon(Icons.bug_report),
      // ) : null,
    );
  }
  
  // Ubah method _buildContent
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tampilkan tombol yang berbeda berdasarkan jenis error
            if (_error!.contains('login')) 
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: AppPallete.primaryColor,
                ),
                child: const Text('Login'),
              )
            else
              ElevatedButton(
                onPressed: () async {
                  await Future.wait([
                    _loadDisposisiNotifications(),
                    _loadNotifikasi(),
                  ]);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: AppPallete.primaryColor,
                ),
                child: const Text('Coba Lagi'),
              ),
          ],
        ),
      );
    }
    
    if (_disposisiList.isEmpty && _notifikasiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Belum ada notifikasi disposisi atau notifikasi lainnya',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar dengan ukuran yang lebih kecil
          Container(
            constraints: const BoxConstraints(maxHeight: 45),
            child: const TabBar(
              tabs: [
                Tab(text: 'Disposisi'),
                Tab(text: 'Notifikasi'),
              ],
              labelStyle: TextStyle(fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tab bar view
          Expanded(
            child: TabBarView(
              children: [
                // Disposisi tab
                _buildDisposisiList(),
                
                // Notifikasi tab
                _buildNotifikasiList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDisposisiList() {
    if (_disposisiList.isEmpty) {
      return Center(
        child: Text(
          'Belum ada notifikasi disposisi',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _disposisiList.length,
      itemBuilder: (context, index) {
        final disposisi = _disposisiList[index];
        return _buildNotificationCard(disposisi);
      },
    );
  }
  
  Widget _buildNotifikasiList() {
    if (_notifikasiList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada notifikasi',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: _notifikasiList.length,
      itemBuilder: (context, index) {
        final notifikasi = _notifikasiList[index];
        return _buildNotifikasiItem(notifikasi);
      },
    );
  }
  
  Widget _buildNotificationCard(Disposisi disposisi) {
    // Tambahkan warna berdasarkan status
    Color statusColor;
    switch (disposisi.status.toLowerCase()) {
      case 'diajukan':
        statusColor = Colors.blue;
        break;
      case 'ditindaklanjuti':
        statusColor = Colors.orange;
        break;
      case 'selesai':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: statusColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailDisposisiPage(disposisi: disposisi),
            ),
          ).then((value) {
            // Refresh after returning from detail page
            if (value == true) {
              _loadDisposisiNotifications();
            }
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan status - Perbaikan overflow di sini
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      disposisi.surat?.perihal ?? 'Disposisi',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2, // Tambahkan batas baris
                      overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika overflow
                    ),
                  ),
                  const SizedBox(width: 8), // Tambahkan jarak
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      disposisi.statusFormatted,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Detail surat dan disposisi
              Text(
                'No. Surat: ${disposisi.surat?.nomorSurat ?? '-'}',
                style: TextStyle(color: Colors.grey[700]),
                maxLines: 1, // Tambahkan batas baris
                overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika overflow
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Dari: ${disposisi.dariUserName}',
                      style: TextStyle(color: Colors.grey[700]),
                      maxLines: 1, // Tambahkan batas baris
                      overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika overflow
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy').format(disposisi.tanggalDisposisi)}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Instruksi disposisi - Perbaikan overflow
              if (disposisi.instruksi != null && disposisi.instruksi!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    disposisi.instruksi!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
              // Action buttons
              if (disposisi.status.toLowerCase() == 'diajukan')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => _updateDisposisiStatus(disposisi, 'ditindaklanjuti'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                          // Perbaikan overflow pada tombol
                          minimumSize: Size.zero, // Set minimum size ke nol
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Tindak Lanjuti'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ));
  }
  
  Widget _buildNotifikasiItem(Notifikasi notifikasi) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: notifikasi.dibaca ? Colors.grey.shade300 : Colors.blue.shade300,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _handleNotifikasiTap(notifikasi),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Perbaikan layout vertikal
                children: [
                  // Icon berdasarkan tipe notifikasi
                  Icon(
                    _getNotifikasiIcon(notifikasi.tipe),
                    color: notifikasi.dibaca ? Colors.grey : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notifikasi.judul,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: notifikasi.dibaca ? Colors.grey[700] : Colors.black,
                      ),
                      maxLines: 2, // Batasi menjadi 2 baris
                      overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika overflow
                    ),
                  ),
                  if (!notifikasi.dibaca)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                notifikasi.pesan,
                style: TextStyle(
                  fontSize: 14,
                  color: notifikasi.dibaca ? Colors.grey[600] : Colors.black87,
                ),
                maxLines: 3, // Batasi menjadi 3 baris
                overflow: TextOverflow.ellipsis, // Tambahkan ellipsis jika overflow
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeAgo(notifikasi.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ));
  }

  IconData _getNotifikasiIcon(String? tipe) {
    switch (tipe?.toLowerCase()) {
      case 'disposisi':
        return Icons.send;
      case 'surat':
        return Icons.email;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Future<void> _handleNotifikasiTap(Notifikasi notifikasi) async {
    // Tandai notifikasi sebagai dibaca jika belum dibaca
    if (!notifikasi.dibaca) {
      try {
        await NotifikasiService.markAsRead(notifikasi.id!);
        
        // Update tampilan
        setState(() {
          final index = _notifikasiList.indexWhere((n) => n.id == notifikasi.id);
          if (index >= 0) {
            _notifikasiList[index] = notifikasi.markAsRead();
          }
        });
      } catch (e) {
        print('Error marking notification as read: $e');
      }
    }
    
    // Navigasi ke halaman berdasarkan tipe notifikasi
    if (notifikasi.tipe?.toLowerCase() == 'disposisi' && notifikasi.referenceId != null) {
      try {
        final disposisi = await DisposisiService.getDisposisiById(notifikasi.referenceId!);
        
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDisposisiPage(disposisi: disposisi),
          ),
        ).then((_) {
          // Refresh data setelah kembali dari halaman detail
          _loadNotifikasi();
          _loadDisposisiNotifications();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat detail disposisi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _updateDisposisiStatus(Disposisi disposisi, String newStatus) async {
    try {
      setState(() => _isLoading = true);
      
      await DisposisiService.updateStatusDisposisi(disposisi.id!, newStatus);
      
      // Refresh list
      await _loadDisposisiNotifications();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status disposisi diubah menjadi ${newStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Gagal mengubah status: $e';
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  // Fungsi untuk menampilkan informasi token
Future<void> _debugTokenInfo() async {
  final token = await UserService.getToken();
  final userData = await UserService.getUserData();
  
  if (!mounted) return;
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Debug Token Info'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Token exists: ${token.isNotEmpty}'),
            const SizedBox(height: 8),
            Text('Token length: ${token.length}'),
            const SizedBox(height: 8),
            Text('User data: ${userData != null ? "${userData.name} (${userData.role})" : "null"}'),
            const SizedBox(height: 8),
            Text('User ID: ${userData?.id ?? "null"}'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
  
// Fungsi untuk debugging notifikasi
Future<void> _debugNotifications() async {
  try {
    // Cek status auth
    final token = await UserService.getToken();
    final userId = await UserService.getUserId();
    
    // Tampilkan dialog dengan info debug
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifikasi Debug Info'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User ID: $userId'),
              const SizedBox(height: 8),
              Text('Token valid: ${token.isNotEmpty}'),
              const SizedBox(height: 8),
              Text('Token prefix: ${token.length > 10 ? token.substring(0, 10) + '...' : token}'),
              const SizedBox(height: 16),
              Text('Notifikasi count: ${_notifikasiList.length}'),
              const SizedBox(height: 8),
              Text('Disposisi count: ${_disposisiList.length}'),
              const Divider(),
              const Text('Notifikasi detail:'),
              const SizedBox(height: 8),
              ..._notifikasiList.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('- ${n.judul}: ${n.pesan.substring(0, min(30, n.pesan.length))}...'),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _forceRefreshUserData();
            },
            child: const Text('Refresh'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Debug error: $e')),
    );
  }
}}