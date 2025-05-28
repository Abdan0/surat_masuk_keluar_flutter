import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/disposisi_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/edit_surat_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_surat_card.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tbh_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_surat_keluar_page.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:url_launcher/url_launcher.dart';

class TrSuratKeluarPage extends StatefulWidget {
  const TrSuratKeluarPage({super.key});

  @override
  State<TrSuratKeluarPage> createState() => _TrSuratKeluarPageState();
}

class _TrSuratKeluarPageState extends State<TrSuratKeluarPage> {
  bool _isLoading = true;
  String? _error;
  List<Surat> _suratList = [];
  String _searchQuery = ''; // Tambahkan variabel untuk pencarian

  @override
  void initState() {
    super.initState();
    _loadSuratKeluar();
  }

  Future<void> _loadSuratKeluar() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final suratList = await SuratService.getSuratKeluar();
      
      setState(() {
        _suratList = suratList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmDelete(Surat surat) async {
    // Tampilkan dialog konfirmasi
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus surat "${surat.perihal}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    // Jika user mengkonfirmasi
    if (confirmed == true) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Panggil service untuk menghapus surat
        await SuratService.deleteSurat(surat.id!);

        // Refresh data
        await _loadSuratKeluar();

        if (!mounted) return;

        // Tampilkan notifikasi sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Surat berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Tampilkan pesan error
        if (!mounted) return;
        setState(() {
          _error = 'Gagal menghapus surat: $e';
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus surat: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Tambahkan fungsi untuk memperbarui status surat berdasarkan disposisi
  Future<void> _updateSuratStatusFromDisposisi(Surat surat) async {
    try {
      // Dapatkan semua disposisi terkait surat
      final disposisiList = await surat.getDisposisi();
      if (disposisiList.isEmpty) return; // Jika tidak ada disposisi, keluar
      
      // Cek prioritas status disposisi
      bool adaSelesai = false;
      bool adaTindaklanjut = false;
      
      for (final disposisi in disposisiList) {
        if (disposisi.status.toLowerCase() == 'selesai') {
          adaSelesai = true;
          break; // Prioritaskan status selesai
        } else if (disposisi.status.toLowerCase() == 'ditindaklanjuti') {
          adaTindaklanjut = true;
        }
      }
      
      // Update status surat berdasarkan prioritas
      String newStatus;
      if (adaSelesai) {
        newStatus = 'selesai';
      } else if (adaTindaklanjut) {
        newStatus = 'ditindaklanjuti';
      } else {
        return; // Tidak perlu update
      }
      
      // Hanya update jika status berbeda
      if (surat.status.toLowerCase() != newStatus) {
        print('ℹ️ Memperbarui status surat ${surat.id} dari ${surat.status} menjadi $newStatus');
        
        // Buat surat baru dengan status yang diperbarui
        final updatedSurat = Surat(
          id: surat.id,
          nomorSurat: surat.nomorSurat,
          tipe: surat.tipe,
          kategori: surat.kategori,
          asalSurat: surat.asalSurat,
          tujuanSurat: surat.tujuanSurat,
          tanggalSurat: surat.tanggalSurat,
          perihal: surat.perihal,
          isi: surat.isi,
          file: surat.file,
          status: newStatus, // Status baru disini
          userId: surat.userId,
          createdAt: surat.createdAt,
          updatedAt: surat.updatedAt,
        );
        
        // Update surat
        await SuratService.updateSuratWithFallback(surat.id!, updatedSurat);
        
        // Refresh data
        await _loadSuratKeluar();
      }
    } catch (e) {
      print('❌ Error updating surat status from disposisi: $e');
    }
  }

  // Tambahkan fungsi ini di dalam class _TrSuratKeluarPageState
  Future<void> _openFilePdf(Surat surat) async {
    try {
      if (surat.file == null || surat.file!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File tidak tersedia'), backgroundColor: Colors.red),
        );
        return;
      }
      
      // Tampilkan indikator loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      
      final fileUrl = await SuratService.getFileUrl(surat.file!);
      
      // Tutup dialog loading
      Navigator.pop(context);
      
      if (fileUrl.isEmpty) {
        throw Exception('URL file tidak valid');
      }
      
      print('🔗 Mencoba membuka file: $fileUrl');
      
      final uri = Uri.parse(fileUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('✅ File berhasil dibuka di browser');
      } else {
        print('❌ Tidak dapat membuka URL: $uri');
        throw Exception('Tidak dapat membuka file');
      }
    } catch (e) {
      print('❌ Error membuka file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSuratKeluar,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                const MyAppBar2(),
                
                const SizedBox(height: 16),
                
                // Search Bar - tambahkan search bar di sini
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari surat...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: const BorderSide(color: AppPallete.primaryColor),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Halaman dan Tombol Tambah baris yang sama
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Judul Halaman
                      Text(
                        'Surat Keluar',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: AppPallete.textColor,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      
                      // Button Tambah
                      SizedBox(
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const TambahSuratKeluar()
                              )
                            ).then((_) => _loadSuratKeluar());
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPallete.primaryColor,
                            foregroundColor: AppPallete.whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            )
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                
                // Implementasikan filter berdasarkan search query
                if (_searchQuery.isNotEmpty && !_isLoading && _error == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      'Hasil pencarian untuk "$_searchQuery"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppPallete.textColor,
                      ),
                    ),
                  ),

                // Tampilkan loading, error atau daftar surat
                _isLoading 
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(),
                      )
                    )
                  : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppPallete.errorColor),
                            const SizedBox(height: 16),
                            Text(
                              'Gagal memuat data: $_error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppPallete.errorColor),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadSuratKeluar,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : _buildSuratList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSuratList() {
    // Filter surat berdasarkan search query
    final filteredSuratList = _searchQuery.isEmpty 
      ? _suratList 
      : _suratList.where((surat) {
          final query = _searchQuery.toLowerCase();
          final nomorSurat = surat.nomorSurat?.toLowerCase() ?? '';
          final perihal = surat.perihal.toLowerCase();
          final asalSurat = surat.asalSurat?.toLowerCase() ?? '';
          final tujuanSurat = surat.tujuanSurat?.toLowerCase() ?? '';
          
          return nomorSurat.contains(query) || 
                 perihal.contains(query) ||
                 asalSurat.contains(query) ||
                 tujuanSurat.contains(query);
        }).toList();

    if (filteredSuratList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                _searchQuery.isEmpty ? Icons.mail_outline : Icons.search_off,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty 
                  ? 'Belum ada surat keluar' 
                  : 'Tidak ada hasil untuk "$_searchQuery"',
                style: TextStyle(
                  color: AppPallete.textColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredSuratList.length,
      itemBuilder: (context, index) {
        final surat = filteredSuratList[index];
        final formattedDate = DateFormat('dd/MM/yyyy').format(surat.tanggalSurat);
        
        return MySuratCard(
          tipeSurat: 'keluar',
          nomorSurat: surat.nomorSurat,
          tanggalSurat: formattedDate,
          pengirimSurat: surat.asalSurat,
          tujuanSurat: surat.tujuanSurat ?? '-',
          nomorAgenda: 'AGK-${surat.id}',
          klasifikasiSurat: surat.kategori,
          ringkasanSurat: surat.perihal,
          keteranganSurat: surat.isi,
          status: surat.status,
          onPdfTap: surat.file != null ? () {
            // Implementasi buka PDF
            _openFilePdf(surat);
          } : null,
          onDisposisiTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisposisiPage(surat: surat),
              ),
            ).then((createdDisposisi) async {
              if (createdDisposisi != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Disposisi berhasil dibuat'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // Update status surat dari disposisi
                await _updateSuratStatusFromDisposisi(surat);
                _loadSuratKeluar();
              }
            });
          },
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailSuratKeluar(surat: surat),
              ),
            );
            
            if (result != null) {
              // Update status surat dari disposisi
              await _updateSuratStatusFromDisposisi(surat);
              _loadSuratKeluar();
            }
          },
          onEditTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditSuratPage(surat: surat),
              ),
            ).then((result) {
              if (result != null) {
                _loadSuratKeluar();
              }
            });
          },
          onDeleteTap: () {
            _confirmDelete(surat);
          },
        );
      },
    );
  }
}