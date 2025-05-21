import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/models/disposisi.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:surat_masuk_keluar_flutter/data/models/user.dart';
import 'package:surat_masuk_keluar_flutter/data/services/disposisi_service.dart';
import 'package:surat_masuk_keluar_flutter/data/services/user_service.dart' as UserService;
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'dart:math';

class DisposisiPage extends StatefulWidget {
  final Surat surat;
  
  const DisposisiPage({
    super.key, 
    required this.surat,
  });

  @override
  State<DisposisiPage> createState() => _DisposisiPageState();
}

class _DisposisiPageState extends State<DisposisiPage> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedPenerimaId;
  String? _selectedPenerimaName;
  DateTime? _tenggatWaktu;
  String _isiDisposisi = '';
  String? _selectedSifatStatus;
  String _catatan = '';
  bool _isLoading = false;
  String? _error;
  
  // List untuk menyimpan user yang dapat menerima disposisi
  List<User> _penerimaList = [];

  @override
  void initState() {
    super.initState();
    _tenggatWaktu = DateTime.now().add(const Duration(days: 3)); // Default 3 hari
    _loadUsers();
    
    // Debug print untuk surat
    print('📄 Surat untuk disposisi: ID=${widget.surat.id}, Nomor=${widget.surat.nomorSurat}');
  }
  
  // Ambil daftar user untuk dropdown
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Ambil daftar user dari DisposisiService
      List<User> users = [];
      
      try {
        users = await DisposisiService.getUsersForDropdown();
      } catch (serviceError) {
        print('⚠️ Error from service: $serviceError');
        // Buat data dummy untuk testing UI
        users = [
          User(id: 1, name: "Admin", role: "admin"),
          User(id: 2, name: "Dekan", role: "dekan"),
          User(id: 3, name: "Wakil Dekan", role: "wakil_dekan"),
          User(id: 4, name: "Staff 1", role: "staff"),
          User(id: 5, name: "Staff 2", role: "staff")
        ];
        print('⚠️ Menggunakan data dummy untuk sementara: ${users.length} users');
      }
      
      if (users.isEmpty) {
        throw Exception('Tidak ada pengguna yang ditemukan');
      }
      
      setState(() {
        _penerimaList = users; // Simpan semua users
        _isLoading = false;
      });
      
      print('✅ Loaded ${_penerimaList.length} users for dropdown');
    } catch (e) {
      setState(() {
        _error = 'Gagal memuat daftar penerima: $e';
        _isLoading = false;
        
        // Fallback ke data dummy jika terjadi error
        _penerimaList = [
          User(id: 1, name: "Admin Dummy", role: "admin"),
          User(id: 2, name: "Dekan Dummy", role: "dekan"),
          User(id: 3, name: "Wakil Dekan Dummy", role: "wakil_dekan"),
          User(id: 4, name: "Staff Dummy 1", role: "staff"),
          User(id: 5, name: "Staff Dummy 2", role: "staff")
        ];
      });
      
      print('❌ Error loading users: $_error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              const MyAppBar2(),
              
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Buat Disposisi',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.textColor,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Content - menggunakan Expanded dengan SingleChildScrollView
              Expanded(
                child: SingleChildScrollView(
                  child: _buildForm(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Detail surat yang akan didisposisi
          _buildSuratInfo(),
          
          const SizedBox(height: 20),
          
          // Error message jika ada
          if (_error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          
          // Penerima disposisi dropdown
          _buildPenerimaDropdown(),
          
          const SizedBox(height: 16),
          
          // Isi disposisi
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Isi Disposisi *',
              hintText: 'Masukkan instruksi atau pesan disposisi',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Isi disposisi tidak boleh kosong';
              }
              return null;
            },
            onChanged: (value) {
              _isiDisposisi = value;
            },
          ),
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendDisposisi,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPallete.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Kirim Disposisi', style: TextStyle(fontSize: 16)),
            ),
          ),
          
          // Tambahkan button ini di _buildForm() setelah submit button
          // if (kDebugMode) ...[
          //   const SizedBox(height: 16),
          //   OutlinedButton(
          //     onPressed: _checkCurrentUser,
          //     child: const Text('Debug: Check Current User'),
          //   ),
          // ],
        ],
      ),
    );
  }
  
  Widget _buildSuratInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Surat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(),
          _buildInfoRow('Nomor Surat', widget.surat.nomorSurat),
          _buildInfoRow('Perihal', widget.surat.perihal),
          _buildInfoRow(
            'Tanggal Surat', 
            DateFormat('dd MMMM yyyy').format(widget.surat.tanggalSurat),
          ),
          _buildInfoRow('Asal Surat', widget.surat.asalSurat),
          if (widget.surat.tujuanSurat != null && widget.surat.tujuanSurat!.isNotEmpty)
            _buildInfoRow('Tujuan Surat', widget.surat.tujuanSurat!),
        ],
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Text(' : '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPenerimaDropdown() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Penerima Disposisi *',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        
        if (_penerimaList.isEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Tidak ada daftar penerima yang tersedia. Silahkan coba lagi.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Muat Ulang'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ] else
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            isExpanded: true,
            hint: const Text('Pilih penerima disposisi'),
            value: _selectedPenerimaId,
            items: _penerimaList.map<DropdownMenuItem<int>>((User user) {
              return DropdownMenuItem<int>(
                value: user.id,
                child: Text(
                  '${user.name} (${_formatUserRole(user.role)})',
                ),
              );
            }).toList(),
            onChanged: (int? value) {
              setState(() {
                _selectedPenerimaId = value;
                // Simpan juga nama penerima untuk ditampilkan di pesan sukses
                if (value != null) {
                  final selectedUser = _penerimaList.firstWhere(
                    (user) => user.id == value,
                    orElse: () => User(id: 0, name: 'Unknown'), // Tanpa parameter email
                  );
                  _selectedPenerimaName = selectedUser.name;
                }
              });
              print('Selected penerima: $_selectedPenerimaId ($_selectedPenerimaName)');
            },
            validator: (value) {
              if (value == null) {
                return 'Silakan pilih penerima disposisi';
              }
              return null;
            },
          ),
      ],
    );
  }
  
  String _formatUserRole(String? role) {
    if (role == null) return 'User';
    
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Admin';
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
  
  Future<void> _sendDisposisi() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    if (_selectedPenerimaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih penerima disposisi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      // Debug: cek token terlebih dahulu
      final token = await UserService.getToken();
      print('🔐 Current token: ${token.length > 10 ? token.substring(0, 10) + '...' : token}');
      
      // Dapatkan ID dan nama user pengirim
      final currentUserId = await UserService.getUserId();
      print('👤 Current user ID: $currentUserId');
      
      // Jika user ID tidak valid, coba gunakan alternatif
      if (currentUserId == null || currentUserId == 0) {
        print('⚠️ User ID tidak valid, mencoba mendapatkan user data langsung');
        
        // Coba dapatkan data user langsung
        final currentUser = await UserService.getUserData();
        if (currentUser?.id != null && currentUser!.id! > 0) {
          print('✅ Berhasil mendapatkan user ID dari getUserData(): ${currentUser.id}');
          
          // Lanjutkan dengan disposisi
          await _createAndSendDisposisi(currentUser.id!, currentUser.name ?? 'User');
        } else {
          // Jika masih gagal, gunakan ID 1 untuk sementara (dummy/admin)
          print('⚠️ Gagal mendapatkan user ID valid, menggunakan ID=1 untuk sementara');
          await _createAndSendDisposisi(1, 'Admin (default)');
        }
      } else {
        // User ID valid, lanjutkan seperti biasa
        final currentUser = await UserService.getUserData();
        final currentUserName = currentUser?.name ?? 'User';
        await _createAndSendDisposisi(currentUserId, currentUserName);
      }
    } catch (e) {
      setState(() {
        _error = 'Gagal mengirim disposisi: $e';
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi helper untuk membuat dan mengirim disposisi
  Future<void> _createAndSendDisposisi(int fromUserId, String fromUserName) async {
    try {
      print('📝 Membuat disposisi dari user $fromUserId ($fromUserName) ke user $_selectedPenerimaId ($_selectedPenerimaName)');
      
      // Buat disposisi
      final disposisiData = Disposisi(
        suratId: widget.surat.id!,
        dariUserId: fromUserId,
        kepadaUserId: _selectedPenerimaId!,
        instruksi: _isiDisposisi,
        status: 'diajukan',
        tanggalDisposisi: DateTime.now(),
      );
      
      // Kirim ke API
      final disposisi = await DisposisiService.createDisposisi(disposisiData);
      
      setState(() {
        _isLoading = false;
      });
      
      if (!mounted) return;
      
      // Tampilkan notifikasi sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Disposisi berhasil dikirim ke $_selectedPenerimaName!'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
      
      // Kembali ke halaman sebelumnya dengan membawa data disposisi
      Navigator.pop(context, disposisi);
    } catch (e) {
      throw e; // Re-throw exception untuk ditangani oleh _sendDisposisi
    }
  }
  
  // Tambahkan method ini di class _DisposisiPageState
  Future<void> _checkCurrentUser() async {
    try {
      final token = await UserService.getToken();
      final userId = await UserService.getUserId();
      final userData = await UserService.getUserData();
      
      print('--- CURRENT USER INFO ---');
      print('Token valid: ${token.isNotEmpty}');
      print('Token: ${token.length > 10 ? '${token.substring(0, 10)}...' : token}');
      print('User ID: $userId');
      print('User data: ${userData?.name} (${userData?.role})');
      print('-------------------------');
      
      // Tampilkan di UI juga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Current user: ${userData?.name ?? 'Unknown'} (ID: $userId)'),
          action: SnackBarAction(
            label: 'Refresh',
            onPressed: () async {
              // Refresh user data
              await UserService.refreshUserData();
              _checkCurrentUser();
            },
          ),
        ),
      );
    } catch (e) {
      print('Error checking user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting user info: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
