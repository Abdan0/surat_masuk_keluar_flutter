import 'package:flutter/material.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_apppbar2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:surat_masuk_keluar_flutter/core/theme/app_pallete.dart';
import 'package:surat_masuk_keluar_flutter/presentation/widgets/my_detail_surat.dart';
import 'package:surat_masuk_keluar_flutter/data/models/surat.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:surat_masuk_keluar_flutter/data/services/surat_service.dart';
import 'package:surat_masuk_keluar_flutter/presentation/pages/transaksi_surat/edit_surat_page.dart';

class DetailSuratMasuk extends StatefulWidget {
  final Surat surat;
  
  const DetailSuratMasuk({super.key, required this.surat});

  @override
  State<DetailSuratMasuk> createState() => _DetailSuratMasukState();
}

class _DetailSuratMasukState extends State<DetailSuratMasuk> {
  late Surat _currentSurat;
  bool _isLoading = false;
  // Tambahkan variabel untuk agenda dan error
  dynamic _agenda;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _currentSurat = widget.surat;
    initializeDateFormatting('id_ID', null);
    // Panggil fungsi untuk memuat agenda surat
    _loadAgendaSurat();
  }

  // Function to handle edit
  void _handleEdit() async {
    print('Edit button tapped!'); // Debug print
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditSuratPage(surat: _currentSurat),
      ),
    );

    if (result != null && result is Surat) {
      setState(() {
        _currentSurat = result;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Surat berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Function to handle delete
  void _handleDelete() async {
    print('Delete button tapped!'); // Debug print
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Apakah Anda yakin ingin menghapus surat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (_currentSurat.id == null) {
          throw Exception('ID surat tidak valid');
        }
        
        final result = await SuratService.deleteSurat(_currentSurat.id!);
        
        setState(() {
          _isLoading = false;
        });
        
        if (result && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Surat berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Return to previous page with deletion status
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus surat: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Contoh penggunaan di halaman detail surat
  Future<void> _loadAgendaSurat() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Mendapatkan agenda yang terkait dengan surat
      final agenda = await _currentSurat.getAgenda();
      
      setState(() {
        _agenda = agenda;
        _isLoading = false;
      });
      
      // Jika tidak ada agenda, tampilkan opsi untuk membuat
      if (_agenda == null) {
        // Tampilkan dialog/button untuk membuat agenda
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data agenda: $_error')),
      );
    }
  }

  // Contoh membuat agenda baru dari halaman detail surat
  Future<void> _createAgendaForSurat() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final newAgenda = await _currentSurat.createAgendaFromSurat();
      
      setState(() {
        _agenda = newAgenda;
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agenda berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuat agenda: $_error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Contoh menampilkan data agenda
  Widget _buildAgendaInfo() {
    if (_agenda == null) {
      return const Text('Belum ada agenda untuk surat ini');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nomor Agenda: ${_agenda!.nomorAgenda}'),
        Text('Tanggal Agenda: ${DateFormat('dd MMMM yyyy').format(_agenda!.tanggalAgenda)}'),
        Text('Pengirim: ${_agenda!.namaPengirim}'),
        Text('Penerima: ${_agenda!.namaPenerima}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal
    String formattedDate;
    try {
      formattedDate = DateFormat('dd MMMM yyyy', 'id_ID').format(_currentSurat.tanggalSurat);
    } catch (e) {
      formattedDate = _currentSurat.tanggalSurat.toString().split(' ')[0];
    }
    
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //App Bar
                  const MyAppBar2(),

                  const SizedBox(height: 12),

                  // Judul Page
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Detail Surat Masuk',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: AppPallete.textColor,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left,
                    ),
                  ),

                  // Detail Surat menggunakan data dari model Surat
                  MyDetailSurat(
                    nomorSurat: _currentSurat.nomorSurat,
                    tanggalSurat: formattedDate,
                    pengirimSurat: _currentSurat.asalSurat,
                    tujuanSurat: _currentSurat.tujuanSurat ?? '-',
                    nomorAgenda: _agenda?.nomorAgenda ?? 'AGM-${_currentSurat.id}',
                    klasifikasiSurat: _currentSurat.kategori,
                    ringkasanSurat: _currentSurat.perihal,
                    keteranganSurat: _currentSurat.isi,
                    createByController: 'Admin',
                    createOnController: _currentSurat.createdAt ?? '-',
                    updateOnController: _currentSurat.updatedAt ?? '-',
                    onPdfTap: _currentSurat.file != null ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Membuka file: ${_currentSurat.file}')),
                      );
                    } : null,
                    // Tambahkan callbacks untuk edit dan delete
                    onEditTap: _handleEdit,
                    onDeleteTap: _handleDelete,
                  ),

                  const SizedBox(height: 20),

                  // Tampilkan informasi agenda
                  const Text(
                    'Informasi Agenda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Tampilkan data agenda atau tombol untuk membuat agenda baru
                  _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAgendaInfo(),

                  // Tombol untuk membuat agenda baru
                  if (_agenda == null) ...{
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _createAgendaForSurat,
                      child: const Text('Buat Agenda Baru'),
                    ),
                  },
                ],
              ),
            ),
          ),
          
          // Loading indicator overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
