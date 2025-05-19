import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_surat_card.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/tbh_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/detail_surat_masuk_page.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';

class TrSuratMasukPage extends StatefulWidget {
  const TrSuratMasukPage({super.key});

  @override
  State<TrSuratMasukPage> createState() => _TrSuratMasukPageState();
}

class _TrSuratMasukPageState extends State<TrSuratMasukPage> {
  bool _isLoading = true;
  String? _error;
  List<Surat> _suratList = [];

  @override
  void initState() {
    super.initState();
    _loadSuratMasuk();
  }

  Future<void> _loadSuratMasuk() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final suratList = await SuratService.getSuratMasuk();
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSuratMasuk,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                const MyAppBar2(),
                const SizedBox(height: 20),

                // Halaman
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'Surat Masuk',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppPallete.textColor,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                ),

                // Button Tambah
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context, 
                              MaterialPageRoute(
                                builder: (context) => const TambahSuratMasuk()
                              )
                            ).then((_) => _loadSuratMasuk());
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppPallete.primaryColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: const Text(
                            'Tambah',
                            style: TextStyle(
                              color: AppPallete.whiteColor,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          )),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tampilkan loading, error atau daftar surat
                _isLoading 
                  ? const Center(child: CircularProgressIndicator())
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
                              onPressed: _loadSuratMasuk,
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      )
                    : _suratList.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'Belum ada surat masuk',
                              style: TextStyle(
                                color: AppPallete.textColor,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _suratList.length,
                          itemBuilder: (context, index) {
                            final surat = _suratList[index];
                            final formattedDate = DateFormat('dd/MM/yyyy').format(surat.tanggalSurat);
                            
                            return MySuratCard(
                              nomorSurat: surat.nomorSurat,
                              tanggalSurat: formattedDate,
                              pengirimSurat: surat.asalSurat,
                              nomorAgenda: 'AG-${surat.id}',
                              klasifikasiSurat: surat.kategori,
                              ringkasanSurat: surat.perihal,
                              keteranganSurat: surat.isi,
                              onPdfTap: surat.file != null ? () {
                                // Implementasi buka PDF
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Membuka file: ${surat.file}')),
                                );
                              } : null,
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailSuratMasuk(surat: surat),
                                  ),
                                );
                                
                                // Refresh jika ada perubahan (edit/hapus)
                                if (result != null) {
                                  _loadSuratMasuk();
                                }
                              },
                            );
                          },
                        ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
